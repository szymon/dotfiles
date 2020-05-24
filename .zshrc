if [ -f /etc/profile ]; then
  PATH=""
  source /etc/profile
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/szymon/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(git python)

source $ZSH/oh-my-zsh.sh

# User configuration

export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

alias zshconfig="vim ~/.zshrc"
alias ohmyzsh="vim ~/.oh-my-zsh"

# user config
export VIRTUALENVWRAPPER_PYTHON="$HOME/.localpython/3.8.3/bin/python3"
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=""

if [[ -r "$HOME/.localpython/3.8.3/bin/virtualenvwrapper.sh" ]]; then
  source "$HOME/.localpython/3.8.3/bin/virtualenvwrapper.sh"
else
  echo "WARNING: Can't find virtualenvwrapper.sh"
fi

export EDITOR='nvim'
alias vim=nvim

export PATH="$HOME/.localpython/3.8.3/bin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"

alias config='/usr/local/bin/git --git-dir=/Users/szymon/.cfg --work-tree=/Users/szymon'
