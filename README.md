# 🚀 Cosmic Terminal no Ubuntu

Script automatizado para **compilar**, **instalar** e **configurar** o [COSMIC Terminal](https://github.com/pop-os/cosmic-term) como terminal padrão no Ubuntu.

---

## ✨ Recursos

- ✅ **Compilação automática** do código fonte oficial
- ✅ **Instalação** no sistema (`/usr/local/bin`)
- ✅ **Tema Phosphor Green** — terminal com visual verde fosforescente estilo CRT
- ✅ **Opacidade 75%** — transparência para melhor visualização
- ✅ **Atalhos simplificados** — `Ctrl+C` copiar / `Ctrl+V` colar
- ✅ **Terminal padrão** — configura alias e MIME types
- ✅ **Validações de segurança** — evita reprocessamento e quebras
- ✅ **Backups automáticos** — preserva configurações anteriores
- ✅ **Idempotente** — execute quantas vezes quiser sem problemas

---

## 🎨 Tema Phosphor Green

| Configuração | Valor |
|---|---|
| **Tema** | Phosphor Green |
| **Fonte** | JetBrainsMono Nerd Font (12px) |
| **Opacidade** | 75% |
| **Padding** | 8px |
| **Cor do cursor** | `#33ff33` |
| **Cor do fundo** | `#0a0a0a` |
| **Cor do texto** | `#33ff33` |

Paleta completa em tons de verde fosforescente para um visual retrô estilo CRT/terminal antigo.

---

## ⌨️ Atalhos Configurados

| Atalho | Ação |
|---|---|
| `Ctrl + C` | Copiar |
| `Ctrl + V` | Colar |
| `Ctrl + Shift + C` | Copiar ou enviar SIGINT |
| `Shift + Insert` | Colar seleção primária (X11) |

---

## 📋 Pré-requisitos

- **Ubuntu** (qualquer versão suportada)
- **Conexão com internet** (para clonar o repositório e instalar dependências)
- **Espaço em disco** (~2-3 GB para build)
- **Permissões sudo** (para instalar pacotes e copiar binários)

---

## 🚀 Instalação

### Clone o repositório

```bash
git clone https://github.com/SEU-USUARIO/CosmicTerminalNoUbuntu.git
cd CosmicTerminalNoUbuntu
```

### Execute o script

```bash
chmod +x CosmicTerminalNoUbuntu.sh
./CosmicTerminalNoUbuntu.sh
```

Ou diretamente:

```bash
bash CosmicTerminalNoUbuntu.sh
```

---

## 🔧 O que o script faz

1. **Validações iniciais**
   - Verifica se está rodando como root
   - Confirma que é Ubuntu
   - Checa conexão com internet
   - Detecta instalação pré-existente

2. **Instala dependências**
   - Rust/Cargo, GTK4, build-essential, e bibliotecas de desenvolvimento

3. **Clona e compila**
   - Clona o repositório oficial do COSMIC Terminal
   - Build em modo release com `cargo build --release`

4. **Instala no sistema**
   - Copia binário para `/usr/local/bin`
   - Instala arquivo `.desktop` e ícones

5. **Configura atalhos**
   - Cria `~/.config/cosmic/com.system76.CosmicTerm.Shortcuts/v1/custom`
   - Define `Ctrl+C` para copiar e `Ctrl+V` para colar

6. **Configura tema**
   - Cria `~/.config/cosmic/com.system76.CosmicTerm/v1/custom.toml`
   - Aplica tema Phosphor Green com 75% de opacidade

7. **Define como terminal padrão**
   - Configura `xdg-settings`
   - Adiciona alias no `.bashrc`
   - Configura `mimeapps.list`
   - Cria link para `x-terminal-emulator`

---

## 📂 Estrutura do Projeto

```
CosmicTerminalNoUbuntu/
├── CosmicTerminalNoUbuntu.sh   # Script principal
├── .gitignore                  # Arquivos ignorados
└── README.md                   # Esta documentação
```

---

## 🔄 Reexecução

O script é **idempotente** — você pode executá-lo múltiplas vezes sem problemas:

- Se o terminal já está instalado, **pula a compilação**
- Se os atalhos já estão configurados, **pula a configuração**
- Se o tema já existe, **pula a criação**
- **Faz backup** de arquivos existentes antes de modificar

```bash
./CosmicTerminalNoUbuntu.sh
# Pode executar novamente sem medo!
```

---

## 🗑️ Desinstalação

Para remover o COSMIC Terminal:

```bash
sudo rm /usr/local/bin/cosmic-term
sudo rm /usr/share/applications/com.system76.CosmicTerm.desktop
rm -rf ~/.config/cosmic/com.system76.CosmicTerm*/
```

E remova o alias do `~/.bashrc` se desejar.

---

## 📝 Arquivos de Configuração Criados

| Arquivo | Descrição |
|---|---|
| `~/.config/cosmic/com.system76.CosmicTerm/v1/custom.toml` | Tema e configurações visuais |
| `~/.config/cosmic/com.system76.CosmicTerm.Shortcuts/v1/custom` | Atalhos de teclado |
| `~/.bashrc` | Alias `terminal='cosmic-term'` |
| `~/.config/mimeapps.list` | Associação de terminal padrão |

---

## ⚠️ Notas

- O primeiro build pode demorar **10-20 minutos** dependendo do hardware
- Reinicie o Cosmic Terminal após a execução para aplicar as configurações
- Se estiver usando GNOME, pode ser necessário configurar o terminal padrão nas configurações do sistema manualmente

---

## 🤝 Contribuindo

Sinta-se à vontade para abrir issues e pull requests!

---

## 📄 Licença

Este script é fornecido "como está" para facilitar a instalação do COSMIC Terminal no Ubuntu. O COSMIC Terminal é um projeto da [System76](https://github.com/pop-os/cosmic-term).

---

Feito com ❤️ para a comunidade Linux
