# IA-OS Roadmap de Desenvolvimento

Este documento define o ciclo de vida de lançamentos do **IA-OS** até a versão estável `v0.1.0`.

---

## Régua de Lançamentos

| Versão | Descrição do Marco | Status |
| :--- | :--- | :--- |
| **`v0.1.0-alpha.1`** | **Estrutura base, bootloader Limine UEFI, Framebuffer linear e Panic Handler inicial** | 🚀 **EM ANDAMENTO** |
| `v0.1.0-alpha.2` | Configuração de GDT (Global Descriptor Table), IDT (Interrupt Descriptor Table) e ISRs básicas | 📋 Planejado |
| `v0.1.0-alpha.3` | Tratamento de Exceções x86_64, Timer PIT/APIC e driver serial UART 16550 para logging | 📋 Planejado |
| `v0.1.0-alpha.4` | Gerenciamento de Memória Física (PMM - Physical Memory Manager / Bitmap Allocator via Limine MemMap) | 📋 Planejado |
| `v0.1.0-alpha.5` | Gerenciamento de Memória Virtual (VMM - Paging 4-level) e Alocador de Heap do Kernel (`alloc`) | 📋 Planejado |
| `v0.1.0-beta.1` | Multitarefa cooperativa, Estruturas de Threads/Processos e Context Switching | 📋 Planejado |
| `v0.1.0-beta.2` | Scheduler preemptivo com interrupções de relógio (APIC Timer) e Primitivas de Sincronização (Spinlocks/Mutexes) | 📋 Planejado |
| `v0.1.0-beta.3` | Interface VFS (Virtual File System) e suporte a sistema de arquivos em RAM (RamFS/Initrd) | 📋 Planejado |
| `v0.1.0-beta.4` | Transição para Userspace (Ring 3), Syscalls (`syscall`/`sysret`) e isolamento de processos | 📋 Planejado |
| `v0.1.0-beta.5` | Driver de teclado PS/2 / USB HID básico e Terminal/Shell de linha de comando inicial | 📋 Planejado |
| **`v0.1.0`** | **Release Estável:** Kernel funcional multitarefa, shell interativo, gerenciamento de memória completo e estabilidade consolidada | 🎯 Meta Final |

---

## Detalhes do Marco Atual: `v0.1.0-alpha.1`

### Metas do Alpha 1:
- [x] Definição de arquitetura e padrões do repositório.
- [x] Configuração da toolchain Rust bare-metal (`x86_64-unknown-none`).
- [x] Integração da crate e protocolo do bootloader Limine (v5+).
- [x] Criação do ponto de entrada `_start()` com `#[panic_handler]`.
- [x] Requisição e aquisição de framebuffer linear de vídeo.
- [x] Desenho na tela e exibição de identificação "IA-OS v0.1.0-alpha.1".
- [x] Script de compilação automatizada, empacotamento com Limine e emulação com QEMU (UEFI).

