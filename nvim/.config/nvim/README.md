# Modern Neovim Configuration

A comprehensive, modern Neovim configuration built with [Lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager. Features LSP, completion, AI assistance, and productivity tools optimized for development workflows.

## 🚀 Complete Setup Guide

This guide will help you get Neovim up and running with this configuration on a fresh system.

### System Requirements

- **Operating System:** Arch Linux or macOS
- **Terminal:** A modern terminal with true color support (Alacritty, Kitty, WezTerm, iTerm2)
- **Internet Connection:** Required for initial plugin and LSP server downloads
- **Package Manager:** pacman/yay (Arch) or Homebrew (macOS)

### Step 1: Install Neovim

#### Arch Linux

```bash
# Install from official repositories
sudo pacman -S neovim

# Alternative: Install latest from AUR (neovim-git)
yay -S neovim-git
# or with paru
paru -S neovim-git
```

#### macOS

```bash
# Using Homebrew (recommended)
brew install neovim

# Install latest HEAD version
brew install --HEAD neovim

# Alternative: MacPorts
sudo port install neovim
```

### Step 2: Install Essential Dependencies

#### Git (Required)

```bash
# Arch Linux
sudo pacman -S git

# macOS (usually pre-installed with Xcode command line tools)
brew install git  # if needed
xcode-select --install  # install command line tools
```

#### Node.js and npm (Required for many LSP servers)

```bash
# Using Node Version Manager (recommended for both systems)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc  # or restart terminal
nvm install --lts
nvm use --lts

# Alternative: Package manager installation
# Arch Linux
sudo pacman -S nodejs npm

# macOS
brew install node npm
```

#### Python and pip (Required for some LSP servers)

```bash
# Arch Linux (usually pre-installed)
sudo pacman -S python python-pip

# macOS (Python 3 via Homebrew recommended)
brew install python
# Note: macOS comes with Python 2.7, install Python 3 via Homebrew
```

#### Additional Language Tools

**Ruby Development:**

```bash
# rbenv (recommended)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc
rbenv install 3.2.0  # or latest stable
rbenv global 3.2.0

# Install Ruby gems for LSP
gem install standardrb solargraph

# Alternative: asdf (multi-language version manager)
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.13.1
echo '. "$HOME/.asdf/asdf.sh"' >> ~/.bashrc
echo '. "$HOME/.asdf/completions/asdf.bash"' >> ~/.bashrc
source ~/.bashrc
asdf plugin add ruby
asdf install ruby 3.2.0
asdf global ruby 3.2.0
```

**Docker (Optional - for containerized testing):**

```bash
# Arch Linux
sudo pacman -S docker docker-compose
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo usermod -aG docker $USER  # logout/login required

# Alternative: Podman (Docker alternative)
sudo pacman -S podman podman-compose

# macOS
brew install --cask docker
# Or install Docker Desktop from docker.com
```

### Step 3: Install a Nerd Font

Nerd Fonts provide the icons used throughout the interface.

#### Automatic Installation

**Arch Linux:**

```bash
# Install from official repositories
sudo pacman -S ttf-jetbrains-mono-nerd

# Alternative: Install all Nerd Fonts from AUR
yay -S nerd-fonts-complete
# or specific fonts
yay -S ttf-jetbrains-mono-nerd ttf-firacode-nerd

# Refresh font cache
fc-cache -fv
```

**macOS:**

```bash
# Using Homebrew
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font

# Install multiple nerd fonts
brew install --cask font-fira-code-nerd-font font-hack-nerd-font
```

#### Manual Installation (if needed)

```bash
# Download and install JetBrains Mono Nerd Font
mkdir -p ~/.local/share/fonts  # Linux
cd ~/.local/share/fonts
curl -fLo "JetBrains Mono Regular Nerd Font Complete.ttf" \
  https://github.com/ryanoasis/nerd-fonts/raw/HEAD/patched-fonts/JetBrainsMono/Ligatures/Regular/complete/JetBrains%20Mono%20Regular%20Nerd%20Font%20Complete.ttf
fc-cache -fv  # Linux only
```

#### Verify Font Installation

Test if Nerd Font is working:

```bash
echo -e "\ue0b0 \ue0b2 \uf427 \uf11c \uf1c1 \uf1c4 \uf1c7 \uf1c0"
# Should display various arrow and file icons
```

#### Popular Nerd Font Options

- **JetBrains Mono** - Excellent for coding with ligatures
- **Fira Code** - Popular with good ligature support
- **Hack** - Clean and readable
- **Source Code Pro** - Adobe's developer font

### Step 4: Terminal Configuration

Ensure your terminal supports true color and modern features:

#### Recommended Terminals

**Arch Linux:**

```bash
# Alacritty (GPU-accelerated, fast)
sudo pacman -S alacritty

# Kitty (feature-rich, GPU-accelerated)
sudo pacman -S kitty

# WezTerm (Rust-based, highly configurable)
yay -S wezterm

# Foot (minimal, Wayland-native)
sudo pacman -S foot
```

**macOS:**

```bash
# iTerm2 (most popular macOS terminal)
brew install --cask iterm2

# Alacritty (cross-platform, fast)
brew install --cask alacritty

# Kitty (feature-rich)
brew install --cask kitty

# WezTerm (highly configurable)
brew install --cask wezterm
```

#### Test True Color Support

```bash
curl -s https://gist.githubusercontent.com/lifepillar/09a44b8cf0f9397465614e622979107f/raw/24-bit-color.sh | bash
```

#### Terminal Configuration Tips

- Enable true color support in your terminal
- Set `TERM=xterm-256color` or `TERM=screen-256color` if needed
- Configure your shell (zsh/bash) for optimal experience

### Step 5: Install This Neovim Configuration

```bash
# 1. Backup existing configuration (if any)
[ -d ~/.config/nvim ] && mv ~/.config/nvim ~/.config/nvim.backup.$(date +%Y%m%d_%H%M%S)
[ -d ~/.local/share/nvim ] && mv ~/.local/share/nvim ~/.local/share/nvim.backup.$(date +%Y%m%d_%H%M%S)
[ -d ~/.cache/nvim ] && mv ~/.cache/nvim ~/.cache/nvim.backup.$(date +%Y%m%d_%H%M%S)

# 2. Clone this configuration
git clone <your-repo-url> ~/.config/nvim

# 3. Start Neovim - plugins will auto-install
nvim
```

### Step 6: First Launch Setup

When you first launch Neovim:

1. **Plugin Installation** - Lazy.nvim will automatically install all plugins (this may take a few minutes)
2. **Treesitter Parsers** - Language parsers will be downloaded automatically
3. **LSP Servers** - Mason will prompt to install language servers as needed

#### Initial Commands to Run

```vim
" In Neovim command mode:
:Lazy sync                " Update all plugins
:TSUpdate                 " Update Treesitter parsers
:Mason                    " Open Mason to install LSP servers
:checkhealth              " Check for any issues
```

### Step 7: Configure External Tools

#### AI Features Setup

**Codeium (Free AI completions):**

1. Visit [codeium.com](https://codeium.com) and create account
2. In Neovim, run `:Codeium Auth`
3. Follow the authentication flow

**ChatGPT Integration:**

1. Get OpenAI API key from [platform.openai.com](https://platform.openai.com)
2. Set environment variable: `export OPENAI_API_KEY="your-key-here"`
3. Add to your shell's rc file (`~/.bashrc`, `~/.zshrc`)

#### GitHub Integration

```bash
# Install GitHub CLI for Octo.nvim
# Arch Linux
sudo pacman -S github-cli
# or from AUR
yay -S github-cli

# macOS
brew install gh

# Authenticate
gh auth login
```

#### WakaTime Setup (Optional)

1. Create account at [wakatime.com](https://wakatime.com)
2. Get your API key from dashboard
3. In Neovim, you'll be prompted for the key on first use

### Step 8: Language-Specific Setup

#### Ruby Development

```bash
# Install Ruby gems for better development experience
gem install rubocop standardrb solargraph

# For Rails projects
gem install rails
```

#### JavaScript/TypeScript

```bash
# Install global packages for better LSP experience
npm install -g typescript typescript-language-server
npm install -g @tailwindcss/language-server  # if using Tailwind
npm install -g prettier eslint  # code formatting and linting
```

#### Go Development

```bash
# Install Go tools manually (Mason installation often fails)
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest

# Verify installation
which gopls
gopls version
```

#### Python

```bash
# Arch Linux - prefer system packages when available
sudo pacman -S python-lsp-server python-black python-isort
# or via pip
pip install python-lsp-server[all] black isort

# macOS
pip3 install python-lsp-server[all] black isort ruff
```

### Step 9: Verify Installation

Run these health checks in Neovim:

```vim
:checkhealth                    " Overall health
:checkhealth lazy               " Plugin manager
:checkhealth lsp                " Language servers
:checkhealth treesitter         " Syntax highlighting
:checkhealth telescope          " Fuzzy finder
```

### Common First-Time Issues

#### Plugin Installation Fails

```bash
# Clear Neovim data and retry
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
nvim  # Will reinstall everything
```

#### LSP Servers Not Working

```vim
:Mason              " Install missing servers manually
:LspInfo            " Check server status
:LspRestart         " Restart language server
```

#### Font Icons Not Showing

1. Verify Nerd Font is installed and selected in terminal
2. Test with: `echo "\ue0b0 \ue0b2 \uf427 \uf11c"`
3. Should display arrow and file icons

#### Treesitter Errors

```vim
:TSInstallInfo      " Check parser status
:TSUpdate all       " Update all parsers
```

### Performance Optimization

#### Arch Linux Optimizations

```bash
# Use faster alternatives
sudo pacman -S ripgrep fd bat exa  # faster grep, find, cat, ls
yay -S bottom  # better htop alternative

# For better Neovim performance
echo 'export NVIM_APPNAME="nvim"' >> ~/.zshrc  # or ~/.bashrc
```

#### macOS Optimizations

```bash
# Install faster CLI tools via Homebrew
brew install ripgrep fd bat exa bottom
brew install coreutils findutils gnu-sed  # GNU tools
```

#### General Performance Tuning

1. **Reduce Treesitter Languages**: Edit `lua/plugins/nvim-treesitter.lua` and remove unused languages
2. **Disable Heavy Plugins**: Comment out resource-intensive plugins in their respective files
3. **Adjust Settings**: Modify `updatetime` and `timeout` values in `lua/user/settings.lua`
4. **Use System Package Managers**: Prefer pacman/brew over language-specific package managers when possible

### Next Steps

After successful installation:

1. Read through the [Key Bindings](#-key-bindings) section
2. Explore the [Plugin Features](#-table-of-contents)
3. Customize settings in `lua/user/` directory
4. Add your own plugins in `lua/plugins/`

### Platform-Specific Tips

#### Arch Linux

- **AUR Helpers**: Use `yay` or `paru` for AUR packages
- **System Updates**: Run `sudo pacman -Syu` regularly
- **Dotfiles**: Consider using GNU Stow for dotfile management
- **Shell**: zsh with oh-my-zsh or starship prompt recommended

#### macOS

- **Homebrew**: Keep updated with `brew update && brew upgrade`
- **Xcode Tools**: Ensure command line tools are current
- **Shell**: Default zsh is fine, consider iTerm2 + oh-my-zsh
- **Permissions**: Some LSP servers may need System Preferences → Privacy permissions

---

_The initial setup may take 10-15 minutes depending on your internet connection. Once complete, you'll have a fully-featured development environment optimized for Arch Linux and macOS!_

## 📋 Table of Contents

- [Core Features](#-core-features)
- [Key Bindings](#-key-bindings)
- [Language Support](#-language-support)
- [AI & Completion](#-ai--completion)
- [Navigation & Search](#-navigation--search)
- [Git Integration](#-git-integration)
- [UI & Appearance](#-ui--appearance)
- [Testing](#-testing)
- [Productivity Tools](#-productivity-tools)
- [Configuration Structure](#-configuration-structure)

## ⚡ Core Features

### Plugin Manager

- **[Lazy.nvim](https://github.com/folke/lazy.nvim)** - Modern plugin manager with lazy loading
- Auto-installs missing plugins on startup
- `:Lazy` - Open plugin manager interface

### 🧠 Intelligent LSP System

This configuration features a **context-aware LSP system** that automatically detects your project type and configures the appropriate language servers with optimal settings.

#### **Automatic Project Detection**

The system scans your project for specific files and automatically enables relevant language servers:

```bash
# Ruby/Rails Projects
Gemfile, config.ru, app/, bin/rails → Ruby + Rails LSP servers

# JavaScript/TypeScript Projects
package.json, tsconfig.json → TSServer + ESLint + Prettier

# React Projects
src/App.jsx, public/index.html + React in package.json → Full React stack

# Go Projects
go.mod, go.sum, *.go → gopls with Go tooling

# Elixir Projects
mix.exs, config/config.exs → ElixirLS + Mix integration

# C++ Projects
CMakeLists.txt, *.cpp, *.hpp → Clangd with modern C++ features
```

#### **Language Server Configurations**

**Ruby & Rails Development:**

- **[Solargraph](https://github.com/castwide/solargraph)** - Primary Ruby LSP with comprehensive features
- **[Ruby LS](https://github.com/Shopify/ruby-lsp)** - Shopify's faster Ruby LSP (auto-detected)
- **[Standardrb](https://github.com/testdouble/standard)** - Ruby formatter/linter (rbenv/asdf aware)
- **Rails Enhancements** - Special keyword support and Rails-specific settings

**JavaScript/TypeScript/React/Node.js:**

- **[TSServer](https://github.com/typescript-language-server/typescript-language-server)** - Official TypeScript/JavaScript LSP
- **[ESLint](https://github.com/hrsh7th/vscode-langservers-extracted)** - Real-time linting with auto-fix
- **[HTML](https://github.com/hrsh7th/vscode-langservers-extracted)** - HTML support with JSX integration
- **[CSS](https://github.com/hrsh7th/vscode-langservers-extracted)** - CSS/SCSS with modern features
- **[Tailwind CSS](https://github.com/tailwindlabs/tailwindcss-intellisense)** - Auto-detected if config exists
- **[Emmet](https://github.com/aca/emmet-ls)** - HTML/JSX expansion support
- **[Prettier](https://prettier.io/)** - Consistent code formatting

**Go Development:**

- **[gopls](https://github.com/golang/tools/tree/master/gopls)** - Official Go LSP
- **[gofumpt](https://github.com/mvdan/gofumpt)** - Enhanced Go formatting
- **Static Analysis** - Built-in staticcheck and advanced diagnostics

**Elixir Development:**

- **[ElixirLS](https://github.com/elixir-lsp/elixir-ls)** - Complete Elixir/Phoenix support
- **[Mix Integration](https://hexdocs.pm/mix/)** - Project-aware compilation and testing

**C++ Development:**

- **[Clangd](https://clangd.llvm.org/)** - Modern C++ LSP with Clang-tidy
- **Advanced Features** - Header insertion, completion, static analysis
- **Compilation Database** - CMake and Makefile integration

**Universal Language Servers:**

- **JSON** - Schema validation with [SchemaStore](https://github.com/b0o/schemastore.nvim)
- **YAML** - Kubernetes, GitHub Actions, and other schema support
- **Markdown** - [Marksman](https://github.com/artempyanykh/marksman) LSP
- **Bash** - Shell script analysis and completion
- **Docker** - Dockerfile syntax and best practices

#### **LSP Key Bindings**

- `K` - Hover documentation
- `gd` - Go to definition
- `gD` - Go to declaration
- `gi` - Go to implementation
- `go` - Go to type definition
- `gr` - Show references
- `gs` - Signature help
- `gpp` - Preview definition in floating window
- `<F2>` - Rename symbol
- `<F3>` - Format code (project-aware)
- `<F4>` - Code actions
- `<leader>wa/wr/wl` - Workspace folder management

#### **Smart Formatting System**

- **[Conform.nvim](https://github.com/stevearc/conform.nvim)** - Universal formatter with project detection
- **Context-Aware** - Uses project-specific formatters (standardrb vs rubocop)
- **Format on Save** - Only in version-controlled projects
- **Language-Specific Chains** - Optimal formatter combinations per language
- **LSP Fallback** - Uses LSP formatting when dedicated formatters unavailable

#### **Project-Specific Configuration Priority**

Create `.nvim.lua` in your project root to override global settings:

```lua
-- Example: .nvim.lua in project root
return {
  lsp = {
    -- Disable specific servers for this project
    disable = { "solargraph" },

    -- Override server configurations
    tsserver = {
      settings = {
        typescript = {
          preferences = {
            includePackageJsonAutoImports = "off"
          }
        }
      }
    }
  }
}
```

**Use Cases:**

- Zero-configuration LSP setup for supported project types
- Automatic tool detection across version managers (rbenv, asdf, system)
- Project-specific overrides without touching global configuration
- Consistent development experience across different project types
- Smart formatting that respects project conventions

### Syntax Highlighting

- **[nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)** - Advanced syntax highlighting
- **Languages Supported:** C, Lua, Vim, Ruby, JavaScript, TypeScript, HTML, CSS, Dockerfile, Markdown, Rust, Svelte
- Automatic parser installation and updates

## 🎯 AI & Completion

### Code Completion

- **[nvim-cmp](https://github.com/hrsh7th/nvim-cmp)** - Completion engine
- **[codeium.vim](https://github.com/Exafunction/codeium.vim)** - AI-powered completions
- **Sources:** LSP, file paths, buffer text, AI suggestions

**Use Cases:**

- Real-time code suggestions as you type
- Context-aware completions based on your codebase
- AI-powered code generation and completion

### AI Assistance

- **[ChatGPT.nvim](https://github.com/jackMort/ChatGPT.nvim)** - Direct ChatGPT integration
- **[Avante.nvim](https://github.com/yetone/avante.nvim)** - Advanced AI coding assistant
- **[Gen.lua](https://github.com/David-Kunz/gen.nvim)** - Local AI model integration

**Key Bindings:**

- `<leader>cc` - Open Gen AI interface
- `<leader>ce` (visual mode) - Explain selected code with AI

**Use Cases:**

- Generate code from natural language descriptions
- Explain complex code sections
- Refactor and optimize existing code
- Debug assistance and problem-solving

## 🧭 Navigation & Search

### File Navigation

- **[nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)** - File explorer sidebar
- **[Telescope](https://github.com/nvim-telescope/telescope.nvim)** - Fuzzy finder for files, text, and more

**Use Cases:**

- Browse project structure with file tree
- Quick file opening with fuzzy search
- Search across entire codebase
- Find and replace operations

### Window Management

- **[vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)** - Seamless Tmux integration
- **[bufferline.nvim](https://github.com/akinsho/bufferline.nvim)** - Enhanced buffer/tab management

**Key Bindings:**

- `<C-h/j/k/l>` - Navigate between vim/tmux panes
- `<leader>ve` - Edit init.lua
- `<leader>vr` - Reload configuration

**Use Cases:**

- Work with multiple files simultaneously
- Navigate between terminal and editor seamlessly
- Organize and switch between project files

### Text Objects & Motion

- **[vim-surround](https://github.com/tpope/vim-surround)** - Manipulate surrounding characters
- **[vim-repeat](https://github.com/tpope/vim-repeat)** - Repeat plugin actions with `.`
- **[neoscroll.nvim](https://github.com/karb94/neoscroll.nvim)** - Smooth scrolling

**Use Cases:**

- Quickly change quotes: `cs"'` changes "hello" to 'hello'
- Add surroundings: `ysiw"` surrounds word with quotes
- Smooth, animated scrolling for better readability

## 📝 Git Integration

### Git Operations

- **[vim-fugitive](https://github.com/tpope/vim-fugitive)** - Comprehensive Git integration
- **[gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)** - Git decorations and blame info
- **[octo.nvim](https://github.com/pwntester/octo.nvim)** - GitHub integration

**Use Cases:**

- View git blame, diffs, and history within editor
- Stage, commit, and push changes without leaving Neovim
- Review and manage GitHub issues and PRs
- Track changes with inline git indicators

## 🎨 UI & Appearance

### Theme & Aesthetics

- **[catppuccin](https://github.com/catppuccin/nvim)** - Modern, eye-friendly colorscheme
- **[lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)** - Customizable statusline
- **[indent-blankline.nvim](https://github.com/lukas-reineke/indent-blankline.nvim)** - Indentation guides

### Enhanced UI

- **[noice.nvim](https://github.com/folke/noice.nvim)** - Better command line and notifications
- **[which-key.nvim](https://github.com/folke/which-key.nvim)** - Keybinding hints
- **[nvim-colorizer.lua](https://github.com/norcalli/nvim-colorizer.lua)** - Color highlighting

**Use Cases:**

- Visual feedback for code structure with indent guides
- Clear status information with enhanced statusline
- Discoverable keybindings with which-key popups
- Color preview for hex codes and CSS colors

## 🧪 Testing

### Test Integration

- **[vim-test](https://github.com/vim-test/vim-test)** - Universal test runner

**Key Bindings:**

- `<Leader>tn` - Test nearest
- `<Leader>tf` - Test file
- `<Leader>ts` - Test suite
- `<Leader>tl` - Test last
- `<Leader>tv` - Test visit

**Docker Support:**

- Automatically detects `docker-compose.yml` or `compose.yml`
- Wraps test commands with `docker compose run --rm app`
- Supports Ruby (RSpec, Minitest) with bundle exec

**Use Cases:**

- Run individual tests while developing
- Execute test suites for entire projects
- Containerized testing for consistent environments
- Language-specific test framework integration

## 🛠️ Productivity Tools

### Code Quality

- **[trouble.nvim](https://github.com/folke/trouble.nvim)** - Diagnostics and error management
- **[Comment.nvim](https://github.com/numToStr/Comment.nvim)** - Smart commenting with Treesitter

**Key Bindings (Trouble):**

- `<leader>xx` - Toggle diagnostics
- `<leader>xX` - Buffer diagnostics
- `<leader>cs` - Symbols
- `<leader>cl` - LSP definitions/references

**Use Cases:**

- Centralized view of all project errors and warnings
- Context-aware commenting for different file types
- Quick navigation to problematic code sections

### Rails Development

- **[vim-rails](https://github.com/tpope/vim-rails)** - Ruby on Rails integration
- **[vim-projectionist](https://github.com/tpope/vim-projectionist)** - Project navigation patterns

**Use Cases:**

- Navigate between models, views, and controllers
- Generate Rails files and boilerplate
- Run Rails-specific commands and generators

### Note Taking

- **[obsidian.nvim](https://github.com/epwalsh/obsidian.nvim)** - Obsidian vault integration

**Configuration:**

- Workspace: `~/Documents/obsidian-notes`
- Templates supported with custom frontmatter
- Checkbox toggling and note linking

**Key Bindings:**

- `<leader>of` - Follow obsidian links
- `<leader>od` - Toggle checkboxes

**Use Cases:**

- Seamless note-taking workflow within Neovim
- Link between code and documentation
- Task management with checkbox support

### Time Management

- **[pomodoro.nvim](https://github.com/epwalsh/pomodoro.nvim)** - Built-in Pomodoro timer

**Use Cases:**

- Time-boxed coding sessions
- Productivity tracking and focus management

### Utility Plugins

- **[vim-eunuch](https://github.com/tpope/vim-eunuch)** - UNIX commands in Vim
- **[vim-sleuth](https://github.com/tpope/vim-sleuth)** - Automatic indentation detection
- **[nvim-autopairs](https://github.com/windwp/nvim-autopairs)** - Auto-close brackets and quotes
- **[augment.vim](https://github.com/kana/vim-augment)** - Enhanced text manipulation

**Use Cases:**

- File system operations (move, delete, rename) from within editor
- Consistent indentation across different projects
- Automatic bracket and quote pairing
- Advanced text transformation operations

### Markdown & Documentation

- **[markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim)** - Live markdown preview
- **[image.nvim](https://github.com/3rd/image.nvim)** - Image display in terminal
- **[diagram.nvim](https://github.com/3rd/diagram.nvim)** - ASCII diagram generation

**Use Cases:**

- Real-time markdown rendering for documentation
- Visual feedback for diagrams and images
- Documentation writing with live preview

### Tracking & Analytics

- **[vim-wakatime](https://github.com/wakatime/vim-wakatime)** - Automatic time tracking

**Use Cases:**

- Track coding time and productivity metrics
- Language and project usage analytics

## 📁 Configuration Structure

```
~/.config/nvim/
├── init.lua                 # Main entry point
├── lazy-lock.json          # Plugin version lock file
├── CLAUDE.md               # AI assistant guidance
├── README.md               # This file
├── lua/
│   ├── config/             # Core configurations
│   │   ├── lazy.lua        # Lazy.nvim setup
│   │   ├── lspconfig.lua   # LSP configuration
│   │   └── mason.lua       # Mason setup
│   ├── plugins/            # Plugin specifications
│   │   ├── *.lua          # Individual plugin configs
│   └── user/               # User customizations
│       ├── keymaps.lua     # Custom key bindings
│       ├── settings.lua    # Vim options and settings
│       └── misc.lua        # Miscellaneous utilities
└── after/                  # After-load configurations
    └── plugins/            # Plugin-specific overrides
```

### Key Configuration Files

- **`init.lua`**: Main entry point, loads user settings and plugins
- **`lua/user/settings.lua`**: Core Vim options (tabs, numbers, clipboard, etc.)
- **`lua/user/keymaps.lua`**: Custom key bindings and shortcuts
- **`lua/config/lazy.lua`**: Plugin manager configuration
- **`lua/plugins/*.lua`**: Individual plugin specifications

## 🔧 Customization

### Adding New Plugins

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  config = function()
    -- Plugin configuration here
  end
}
```

### Custom Key Bindings

Edit `lua/user/keymaps.lua`:

```lua
-- Add your custom keymaps
vim.keymap.set('n', '<leader>my', ':MyCommand<cr>', { desc = 'My custom command' })
```

### LSP Server Configuration

Language servers are automatically installed via Mason. To add a new language server, it will be detected and configured automatically when you open a file of that type.

## 🔧 Project-Specific Configuration Examples

### Ruby/Rails Project Override

```lua
-- .nvim.lua in Rails project root
return {
  lsp = {
    -- Use only Solargraph, disable Ruby LS for this project
    disable = { "ruby_ls" },

    solargraph = {
      settings = {
        solargraph = {
          -- Enable more detailed diagnostics for this large codebase
          diagnostics = true,
          completion = true,
          -- Disable formatting to use RuboCop instead of Standardrb
          formatting = false,
        }
      }
    }
  },

  -- Custom formatters for this project
  formatters = {
    ruby = { "rubocop" }  -- Override default standardrb
  }
}
```

### React/TypeScript Project Override

```lua
-- .nvim.lua in React project root
return {
  lsp = {
    tsserver = {
      settings = {
        typescript = {
          preferences = {
            -- Disable auto-imports for this project (performance)
            includePackageJsonAutoImports = "off"
          }
        }
      }
    },

    eslint = {
      settings = {
        format = false,  -- Disable ESLint formatting, use Prettier only
        codeActionOnSave = {
          enable = true,
          mode = "all"
        }
      }
    }
  }
}
```

### Go Project Override

```lua
-- .nvim.lua in Go project root
return {
  lsp = {
    gopls = {
      settings = {
        gopls = {
          -- Enable experimental features for this project
          experimentalPostfixCompletions = true,
          analyses = {
            unusedparams = true,
            shadow = true,
          },
          -- Custom build flags for this project
          buildFlags = {"-tags=integration"},
        }
      }
    }
  }
}
```

### Multi-Language Project (Go + React)

```lua
-- .nvim.lua for full-stack project
return {
  lsp = {
    -- Backend Go configuration
    gopls = {
      root_dir = require('lspconfig').util.root_pattern("go.mod", "backend/go.mod"),
      settings = {
        gopls = {
          buildFlags = {"-tags=docker"}
        }
      }
    },

    -- Frontend TypeScript configuration
    tsserver = {
      root_dir = require('lspconfig').util.root_pattern("frontend/package.json"),
      settings = {
        typescript = {
          preferences = {
            includePackageJsonAutoImports = "auto"
          }
        }
      }
    }
  },

  -- Project-specific settings
  is_fullstack = true,
  backend_path = "backend/",
  frontend_path = "frontend/"
}
```

## 🐛 Troubleshooting

### LSP Issues

**LSP Server Not Starting:**

```vim
:LspInfo                    " Check active servers
:Mason                      " Verify server installation
:checkhealth lsp            " Diagnose LSP issues
```

**Project Detection Problems:**

```lua
-- Debug project detection in Neovim
:lua print(vim.inspect(require('user.project_utils').get_project_config()))
```

**Performance Issues with LSP:**

```lua
-- .nvim.lua to disable heavy features
return {
  lsp = {
    solargraph = {
      settings = {
        solargraph = {
          diagnostics = false,  -- Disable if too slow
        }
      }
    }
  }
}
```

**Formatting Not Working:**

```vim
:ConformInfo                " Check formatter status
:lua print(vim.inspect(require('conform').list_formatters()))
```

### Common Issues

1. **Plugins not loading**: Run `:Lazy sync` to update plugins
2. **LSP not working**: Check `:Mason` for server installation status
3. **Treesitter errors**: Run `:TSUpdate` to update parsers
4. **Key bindings not working**: Check for conflicts with `:WhichKey`
5. **Project config not loading**: Ensure `.nvim.lua` returns a table
6. **Formatters not found**: Check tool availability with `:Mason`
7. **Mason package errors**: Some packages may not be available in Mason registry

### Mason Package Issues

**"Cannot find package" errors:**
```vim
:Mason                      " Check available packages
:MasonUpdate               " Update Mason registry
:MasonUninstallAll         " Reset if needed
:MasonInstall <package>    " Manual installation
```

**Alternative installation for missing tools:**
```bash
# C++ tools (if Mason fails)
# Arch Linux
sudo pacman -S clang llvm cppcheck

# macOS  
brew install llvm cppcheck

# Ruby tools (manual gem installation)
gem install ruby-lsp sorbet

# Go tools (manual installation - required)
go install golang.org/x/tools/gopls@latest
go install mvdan.cc/gofumpt@latest  
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
```

### LSP Server-Specific Troubleshooting

**Ruby/Rails Issues:**

```bash
# Check Ruby version manager setup
which standardrb
which rubocop
gem list | grep solargraph
```

**JavaScript/TypeScript Issues:**

```bash
# Verify Node.js setup
npm list -g typescript
which prettier
which eslint
```

**Go Issues:**

```bash
# Check Go installation
go version
which gopls
go mod download  # Ensure dependencies are available
```

**C++ Issues:**

```bash
# Verify Clang setup
which clangd
clang --version
# Generate compile_commands.json for better analysis
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=1
```

### Health Checks

- `:checkhealth` - General Neovim health
- `:checkhealth lazy` - Plugin manager health
- `:checkhealth lsp` - LSP configuration health
- `:checkhealth treesitter` - Treesitter health
- `:checkhealth mason` - LSP server installation health

## 📚 Learning Resources

- [Neovim Documentation](https://neovim.io/doc/)
- [Lazy.nvim Usage](https://github.com/folke/lazy.nvim#-usage)
- [LSP Configuration Guide](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)
- [Lua for Neovim](https://github.com/nanotee/nvim-lua-guide)

---

_This configuration is designed to be a comprehensive development environment while remaining fast and efficient. Each plugin serves a specific purpose and contributes to a cohesive workflow._

