# Arquitetura do IA-OS

Este documento descreve as decisões de design, arquitetura de hardware, protocolo de inicialização e convenções do **IA-OS**.

---

## 1. Visão Geral

O **IA-OS** é um sistema operacional bare-metal escrito em **Rust**, projetado para rodar em hardware x86_64 moderno inicializado via firmware UEFI através do protocolo Limine.

- **Nome do Projeto:** IA-OS (Intelligent Architecture Operating System)
- **Linguagem Principal:** Rust (`#![no_std]`, `#![no_main]`)
- **Arquitetura Alvo:** `x86_64` (`x86_64-unknown-none`)
- **Bootloader:** [Limine Bootloader](https://github.com/limine-bootloader/limine) (Protocolo de Boot Limine v5+)
- **Firmware Alvo:** UEFI (x86_64 UEFI firmware, OVMF no QEMU)
- **Licença:** Apache License 2.0

---

## 2. Decisões de Arquitetura

### 2.1 Linguagem e Runtime
- O kernel roda estritamente sem a biblioteca padrão (`#![no_std]`), confiando exclusivamente nas crates fundamentais `core` e `compiler_builtins`.
- O ponto de entrada padrão da libc (`main`) é desativado (`#![no_main]`), com a execução iniciando no símbolo `_start` exportado com convenção C (`extern "C"`).
- O tratamento de pânico (`#[panic_handler]`) é customizado: no estágio inicial, trava a CPU em um loop com instrução `hlt` (`core::arch::asm!("cli; hlt")`).

### 2.2 Protocolo de Boot: Limine
O IA-OS adota o **Limine Bootloader** por suas vantagens:
1. **Transição Limpa:** Entrega a máquina diretamente em modo Longo de 64 bits (Long Mode / Ring 0) com paginação ativa e paginação de identidade/HHDM configurada.
2. **Protocolo Baseado em Tags/Requisições:** O kernel declara estruturas estáticas (`FramebufferRequest`, `HhdmRequest`, `MemoryMapRequest`, etc.) em seções ELF reconhecidas pelo bootloader.
3. **Firmware Agnóstico:** O mesmo protocolo de requisição funciona de forma uniforme se o Limine foi iniciado via UEFI ou BIOS, padronizando o estado inicial da máquina.
4. **Framebuffer Linear:** Entrega buffers de vídeo no modo nativo (RGB/BGR de 32 bits), eliminando a necessidade de lidar com modos de vídeo VGA legados.

### 2.3 Modelo de Memória (Long Mode x86_64)
- **Higher-Half Kernel:** O kernel é carregado na metade superior do espaço de endereçamento virtual (`0xFFFF_8000_0000_0000` em diante ou conforme mapeado pelo HHDM do Limine).
- **HHDM (Higher Half Direct Map):** Mapeamento direto de toda a memória física na metade superior, permitindo que o kernel acesse estruturas físicas manipulando ponteiros com offset.

### 2.4 Subsistema Gráfico e Renderização
- **Framebuffers Lineares:** O bootloader configura a resolução nativa da tela e fornece ponteiro base, largura, altura, stride (pitch) e formato de cores (bpp, máscaras de canais).
- **Driver de Framebuffer Primário:** O kernel acessa o buffer via ponteiro bruto `*mut u32` ou `*mut u8`, escrevendo diretamente na memória de vídeo mapeada.
- **Renderização de Texto:** Renderizador de bitmap minimalista para fontes 8x16 monocromáticas incorporadas diretamente na imagem binária.

---

## 3. Estrutura do Repositório

```text
IA-OS/
├── .cargo/
│   └── config.toml           # Configurações do compilador e target bare-metal
├── context-dev/              # Arquivos de persistência de contexto e design
│   ├── ARCHITECTURE.md       # Este documento de arquitetura
│   ├── ROADMAP.md            # Cronograma e régua de releases
│   └── changelog/            # Changelogs versionados
│       └── v0.1.0-alpha.1.md # Release notes do Alpha 1
├── src/
│   └── main.rs               # Ponto de entrada (_start), framebuffer e panic handler
├── Cargo.toml                # Metadados do pacote e dependências
├── rust-toolchain.toml       # Versão do toolchain e componentes
├── limine.conf               # Configuração do menu e opções de boot do Limine
├── build_and_run.sh          # Pipeline de build, geração de ISO e emulação no QEMU
└── README.md                 # Documentação geral e guia rápido
```

---

## 4. Requisitos de Ambiente

- **Rust:** Canal `nightly` (ou estável com suporte a target bare-metal `x86_64-unknown-none` e `rust-src`).
- **Target:** `x86_64-unknown-none`.
- **Emulador:** `qemu-system-x86_64`.
- **Firmware UEFI:** Arquivos OVMF (`OVMF_CODE.fd`, `OVMF_VARS.fd` ou `OVMF.fd`).
- **Ferramentas de Criação de Imagem:** `xorriso`, `mtools` (opcional para FAT).

