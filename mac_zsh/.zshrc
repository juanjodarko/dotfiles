############################
#        ZSH config        #
# Basic main configuration #
# Juan Jo Ruiz Ferrer      #
############################

export LC_ALL='en_US.UTF-8'
export XDG_CONFIG_HOME=$HOME/.config
VIM="nvim"
PERSONAL=$XDG_CONFIG_HOME/personal
HISTSIZE=100000000
SAVEHIST=100000000

eval "$(starship init zsh)"
autoload -Uz compinit && compinit


if [ ! "$TMUX" = "" ]; then export TERM=screen-256color; fi
bindkey -s ^f "tmux-sessionizer\n"

export PATH="$PATH:$HOME/.local/bin"
PATH=$(brew --prefix)/opt/findutils/libexec/gnubin:$PATH
PATH=$(brew --prefix)/opt/lua-language-server/bin:$PATH

# eval "$(direnv hook zsh)"
# eval "$(rbenv init - zsh)"
# eval "$(nodenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"
eval "$(mise activate zsh)"

# Add Python user bin to PATH for pip-installed tools like isort
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# DIRENV_WARN_TIMEOUT="30s"

# [[ -f .direnv/.direnvrc ]] && source .direnv/direnvrc
source <(fzf --zsh)
for i in `find -L $PERSONAL | sort`; do
  source $i
done

source <(kubectl completion zsh)  # setup autocomplete in zsh into the current shell
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
export PATH="/opt/homebrew/opt/postgresql@12/bin:$PATH"
export BAT_THEME="Catppuccin Mocha"

export FZF_DEFAULT_COMMAND='fd --hidden --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude ".git" . "$1"
}

_fzf_compgen_dir() {
  fd --type d --hidden --exclude ".git" . "$1"
}

# source ~/Applications/fzf-git.sh/fzf-git.sh

export FREEDESKTOP_MIME_TYPES_PATH=/opt/homebrew/share/mime/packages/freedesktop.org.xml

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf "$@" --preview 'eza --tree --color=always {} | head -200' ;;
    export|unset) fzf "$@" --preview "eval 'echo \$'{}" ;;
    ssh)          fzf "$@" --preview 'dig {}' ;;
    *)            fzf "$@" --preview "--preview 'bat -b -color=always --line-range :500 {}'";;
  esac
}
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
eval "$(zoxide init zsh)"
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--multi"

export KITTY_CONFIG_DIRECTORY=$HOME/.config/kitty
export WORKDIR=~/workspace

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Added by change/development_environment script
export WORKDIR="/Users/juanjo/workspace"
export PATH="$WORKDIR/development_environment/bin:$PATH"

# Task Master aliases added on 9/10/2025
alias tm='task-master'
alias taskmaster='task-master'

alias corgi-front-lint-fix="./node_modules/.bin/eslint --fix --quiet $1"
alias corgi-front-check="pnpm typecheck && pnpm test:coverage:branch"
alias corgi-middle-check="pnpm typecheck && pnpm lint:fix --quiet && pnpm test"

export CHANGE_USERNAME=jjruiz@change.org
# place this after nvm initialization!
autoload -U add-zsh-hook

# fnm
FNM_PATH="/opt/homebrew/opt/fnm/bin"
if [ -d "$FNM_PATH" ]; then
  eval "`fnm env`"
fi
export CHANGE_USERNAME="jjruiz@change.org"


# setup-env: runs commands queued by project scripts in the parent terminal
_setup_env_deferred_run() {
  [ -f "${HOME}/.setup-env-deferred" ] || return 0
  . "${HOME}/.setup-env-deferred" 2>/dev/null
  rm -f "${HOME}/.setup-env-deferred"
}
autoload -Uz add-zsh-hook 2>/dev/null && add-zsh-hook precmd _setup_env_deferred_run
