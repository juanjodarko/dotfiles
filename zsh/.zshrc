############################
#        ZSH config        #
# Basic main configuration #
# Juan Jo Ruiz Ferrer      #
############################

# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================
export LC_ALL='en_US.UTF-8'
export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim"
PERSONAL=$XDG_CONFIG_HOME/personal
HISTSIZE=100000000
SAVEHIST=100000000
HISTFILE=~/.histfile

# ============================================================================
# ZSH OPTIONS
# ============================================================================

# History
setopt EXTENDED_HISTORY          # Write timestamp to history
setopt SHARE_HISTORY             # Share history between sessions
setopt HIST_IGNORE_DUPS          # Don't record duplicates
setopt HIST_IGNORE_ALL_DUPS      # Delete old duplicates
setopt HIST_FIND_NO_DUPS         # Don't display duplicates in search
setopt HIST_IGNORE_SPACE         # Don't record commands starting with space
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks
setopt HIST_VERIFY               # Don't execute immediately on history expansion

# Navigation
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Push directories onto stack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print directory stack

# Globbing
setopt EXTENDED_GLOB             # Use extended globbing syntax
setopt NOMATCH                   # Print error if pattern has no matches

# Other
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
setopt NO_BEEP                   # Disable beep
setopt PROMPT_SUBST              # Enable prompt substitution

# ============================================================================
# COMPLETION SYSTEM (Optimized)
# ============================================================================
autoload -Uz compinit

# Only regenerate compdump once per day for speed
if [[ -n ${HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# Enhanced completion options
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Group completions
zstyle ':completion:*' group-name ''
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'

# ============================================================================
# PROMPT & TERMINAL SETUP
# ============================================================================
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

if [ ! "$TMUX" = "" ]; then export TERM=tmux-256color; fi

# ============================================================================
# LOAD PERSONAL CONFIGURATION FILES
# ============================================================================
# Load all .zsh files from personal config directory
for file in $PERSONAL/*.zsh(N); do
  [[ -r "$file" ]] && source "$file"
done

# ============================================================================
# FZF CONFIGURATION
# ============================================================================
if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
  source /usr/share/fzf/key-bindings.zsh
fi

if [[ -f /usr/share/fzf/completion.zsh ]]; then
  source /usr/share/fzf/completion.zsh
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--layout=reverse \
--info=inline \
--height=80% \
--multi \
--preview-window=:hidden \
--preview '([[ -f {} ]] && (bat --style=numbers --color=always {} || cat {})) || ([[ -d {} ]] && (tree -C {} | less)) || echo {} 2> /dev/null | head -200' \
--bind='?:toggle-preview' \
--bind='ctrl-a:select-all' \
--bind='ctrl-y:execute-silent(echo {+} | xclip -selection clipboard)'"

# FZF functions
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ============================================================================
# VERSION MANAGERS
# ============================================================================

# mise - Polyglot version manager (replaces nvm, pyenv, rvm)
# Manages Node.js, Python, Ruby, and 100+ other tools
# Configuration: ~/.config/mise/config.toml (tracked in dotfiles)
eval "$(mise activate zsh)"

# Direnv - Load immediately (it's fast)
eval "$(direnv hook zsh)"

# ============================================================================
# PATH MANAGEMENT
# ============================================================================
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

# ============================================================================
# KEY BINDINGS
# ============================================================================

# Vi mode
bindkey -v
export KEYTIMEOUT=1

# Better history search with arrow keys
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^[[A" history-beginning-search-backward-end
bindkey "^[[B" history-beginning-search-forward-end

# Word navigation (Ctrl+arrows)
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Custom bindings
bindkey -s "^f" "tmux-sessionizer\n"

# Edit command in $EDITOR with Ctrl+E
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^e" edit-command-line

# Vi mode cursor shape
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select

# Start with beam cursor
echo -ne '\e[5 q'
precmd() { echo -ne '\e[5 q' ;}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

# Create directory and cd into it
mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Go up N directories
up() {
  local d=""
  local limit="$1"

  if [ -z "$limit" ] || [ "$limit" -le 0 ]; then
    limit=1
  fi

  for ((i=1; i<=limit; i++)); do
    d="../$d"
  done

  cd "$d" || return
}

# Extract any archive
extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar x "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Quick GitHub clone
gh-clone() {
  if [[ $1 =~ ^https?:// ]]; then
    git clone "$1"
  else
    git clone "https://github.com/$1.git"
  fi
}

# FZF Git branch switcher
fgb() {
  local branches branch
  branches=$(git branch -a) &&
  branch=$(echo "$branches" | fzf +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# FZF process killer
fkill() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    echo "$pid" | xargs kill -"${1:-9}"
  fi
}

# ============================================================================
# ZSH PLUGINS (Load syntax-highlighting LAST)
# ============================================================================
if [[ -f /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
fi

# IMPORTANT: syntax-highlighting must be sourced LAST
if [[ -f /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
  source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
fi

# ============================================================================
# APPLICATION SPECIFIC ALIASES
# ============================================================================
# Task Master aliases
alias tm='task-master'
alias taskmaster='task-master'
