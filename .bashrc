if [ -f /etc/profile ]; then 
  PATH=""
  source /etc/profile
fi

export LANG=en_US.UTF-8

alias ls='ls --color'
export PS1='\u@\h:\[\e[33m\]\w\[\e[0m\]\$ '
export EDITOR='vim'


export PATH="/usr/local/opt/llvm/bin:$PATH"
