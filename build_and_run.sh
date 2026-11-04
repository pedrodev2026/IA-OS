#!/usr/bin/env bash
set -euo pipefail

echo "=========================================================="
echo "          IA-OS - Pipeline de Build e Execução UEFI       "
echo "=========================================================="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

ISO_DIR="$SCRIPT_DIR/build/iso_root"
LIMINE_DIR="$SCRIPT_DIR/limine-bin/limine"
KERNEL_BIN="$SCRIPT_DIR/target/x86_64-unknown-none/debug/ia-os"
IMAGE_ISO="$SCRIPT_DIR/build/ia-os.iso"

# 1. Compilação do Kernel
echo "[1/4] Compilando o kernel IA-OS com Cargo..."
cargo build

# 2. Obtenção do Limine (se necessário)
if [ ! -d "$LIMINE_DIR" ]; then
    echo "[2/4] Clonando repositório binário do Limine..."
    mkdir -p "$SCRIPT_DIR/limine-bin"
    git clone https://github.com/limine-bootloader/limine.git --branch=v8.x-binary --depth=1 "$LIMINE_DIR"
fi

if [ ! -f "$LIMINE_DIR/limine" ]; then
    echo "Compilando ferramenta host do Limine..."
    make -C "$LIMINE_DIR" limine
fi

# 3. Preparação da estrutura de arquivos da ISO
echo "[3/4] Preparando raiz da ISO..."
rm -rf "$SCRIPT_DIR/build"
mkdir -p "$ISO_DIR/boot"
mkdir -p "$ISO_DIR/EFI/BOOT"

# Copia kernel e configuração
cp "$KERNEL_BIN" "$ISO_DIR/boot/ia-os"
cp "$SCRIPT_DIR/limine.conf" "$ISO_DIR/boot/limine.conf"
cp "$SCRIPT_DIR/limine.conf" "$ISO_DIR/limine.conf"

# Copia arquivos do Limine para UEFI e BIOS
cp "$LIMINE_DIR/limine-bios.sys" "$ISO_DIR/boot/"
cp "$LIMINE_DIR/limine-bios-cd.bin" "$ISO_DIR/boot/"
cp "$LIMINE_DIR/limine-uefi-cd.bin" "$ISO_DIR/boot/"
cp "$LIMINE_DIR/BOOTX64.EFI" "$ISO_DIR/EFI/BOOT/BOOTX64.EFI"

echo "Gerando ISO bootável compatível com UEFI..."
xorriso -as mkisofs \
    -b boot/limine-bios-cd.bin \
    -no-emul-boot -boot-load-size 4 -boot-info-table \
    --efi-boot boot/limine-uefi-cd.bin \
    -efi-boot-part --efi-boot-image --protective-msdos-label \
    "$ISO_DIR" -o "$IMAGE_ISO" > /dev/null 2>&1

"$LIMINE_DIR/limine" bios-install "$IMAGE_ISO" > /dev/null 2>&1 || true

echo "Imagem criada com sucesso em: $IMAGE_ISO"

# 4. Execução no QEMU
OVMF_PATH=""
if [ -f "/usr/share/ovmf/OVMF.fd" ]; then
    OVMF_PATH="/usr/share/ovmf/OVMF.fd"
elif [ -f "/usr/share/OVMF/OVMF_CODE_4M.fd" ]; then
    OVMF_PATH="/usr/share/OVMF/OVMF_CODE_4M.fd"
fi

if [ -z "$OVMF_PATH" ]; then
    echo "AVISO: Firmware OVMF não encontrado em locais padrão. Rodando com boot padrão."
    OVMF_ARG=""
else
    echo "Utilizando firmware UEFI: $OVMF_PATH"
    OVMF_ARG="-bios $OVMF_PATH"
fi

echo "[4/4] Iniciando QEMU com suporte UEFI..."
qemu-system-x86_64 \
    -M q35 \
    -m 256M \
    $OVMF_ARG \
    -cdrom "$IMAGE_ISO" \
    -boot d \
    -serial stdio \
    "$@"

