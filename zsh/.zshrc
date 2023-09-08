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

# Path to your oh-my-zsh installation.
export ZSH="/home/juanjo/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(git docker docker-compose docker-machine zsh-autosuggestions tmux)

source $ZSH/oh-my-zsh.sh
if [ ! "$TMUX" = "" ]; then export TERM=tmux-256color; fi

for i in `find -L $PERSONAL | sort `; do
  source $i
done
source /usr/share/fzf/key-bindings.zsh
source /usr/share/fzf/completion.zsh
bindkey -s ^f "tmux-sessionizer\n"

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.rvm/bin"
eval "$(direnv hook zsh)"
eval "$(pyenv init -)"
source /usr/share/nvm/init-nvm.sh
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"
