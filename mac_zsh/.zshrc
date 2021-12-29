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
export ZSH="/Users/juanjo/.oh-my-zsh"
ZSH_THEME="agnoster"

plugins=(git docker docker-compose docker-machine zsh-autosuggestions tmux)

source $ZSH/oh-my-zsh.sh
if [ ! "$TMUX" = "" ]; then export TERM=xterm-256color; fi

for i in `find -L $PERSONAL`; do
  source $i
done
source /usr/local/opt/fzf/shell/key-bindings.zsh
source /usr/local/opt/fzf/completion.zsh
bindkey -s ^f "tmux-sessionizer\n"

export NVM_DIR="$HOME/.nvm"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
export PATH="$PATH:$HOME/.local/bin"
export PATH="$PATH:$HOME/.rvm/bin"