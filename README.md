# IA-OS

Sistema Operacional bare-metal desenvolvido do zero em **Rust** (`#![no_std]`, `#![no_main]`) para a arquitetura **`x86_64`**, utilizando o bootloader moderno **Limine** sobre firmware **UEFI**.

---

## 🚀 Status da Versão: `v0.1.0-alpha.1`

- [x] Estrutura do projeto bare-metal em Rust configurada.
- [x] Protocolo de inicialização do Limine v5+ integrado.
- [x] Ponto de entrada `_start()` com `#[panic_handler]` bare-metal.
- [x] Detecção, configuração e desenho direto no Framebuffer linear (32 bpp).
- [x] Renderização de texto e caracteres bitmap na tela.
- [x] Pipeline automatizado de compilação, montagem de imagem ISO UEFI e emulação com QEMU (`build_and_run.sh`).

---

## 🛠️ Requisitos de Ambiente

Para compilar e executar o IA-OS, certifique-se de ter os seguintes pacotes instalados:

### 1. Pacotes do Sistema (Debian / Ubuntu):
```bash
sudo apt update && sudo apt install -y qemu-system-x86 ovmf mtools xorriso
```

### 2. Ferramentas Rust:
O projeto utiliza a toolchain **Rust Nightly** com o target `x86_64-unknown-none` e o componente `rust-src`:
```bash
rustup toolchain install nightly
rustup component add rust-src --toolchain nightly
rustup target add x86_64-unknown-none --toolchain nightly
```

---

## 📦 Compilação e Execução

Para compilar o kernel, gerar a ISO bootável com suporte UEFI e executar automaticamente no QEMU:

```bash
./build_and_run.sh
```

Ou execute apenas a compilação do binário ELF bare-metal:
```bash
cargo build
```

---

## 📁 Estrutura do Projeto

```text
IA-OS/
├── .cargo/
│   └── config.toml           # Configurações de compilação bare-metal (no-redzone, pic, code-model=kernel)
├── context-dev/              # Documentos de especificação e ciclo de desenvolvimento
│   ├── ARCHITECTURE.md       # Arquitetura técnica e decisões de design
│   ├── ROADMAP.md            # Régua de lançamento (Alpha 1 a 5, Beta 1 a 5, v0.1.0 Estável)
│   └── changelog/            # Notas de versão
│       └── v0.1.0-alpha.1.md # Changelog da versão inicial
├── src/
│   └── main.rs               # Kernel entrypoint (_start), framebuffer e panic handler
├── Cargo.toml                # Manifesto do pacote Rust e dependências
├── rust-toolchain.toml       # Fixação da toolchain e componentes
├── limine.conf               # Menu de inicialização e configuração do Limine
├── build_and_run.sh          # Script de automação do build, geração da ISO e QEMU
└── README.md                 # Visão geral e documentação do projeto
```

---

## 📄 Licença

Distribuído sob a licença **Apache License 2.0**. Consulte o arquivo de licença para mais informações.

