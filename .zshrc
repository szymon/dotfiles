# from: http://zsh.sourceforge.net/Intro/intro_3.html
# this file (.zshenv) is read and executed on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment
# variables. .zshenv should not contain commands that produce output or assume that we are connected
# to tty when executing it.

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
if [ -f /etc/profile ]; then
    PATH=""
    source /etc/profile
fi

# Force the terminal language to be English
export LANG=en_US.UTF-8

# Path to your oh-my-zsh installation.
export ZSH="/Users/szymon/.oh-my-zsh"

# Add gnu man pages (from brew)
export MANPATH="/usr/local/man:$MANPATH"


# =======================================================================
# setup path (this goes from top to bottom, the files added at the top
# will be later in the path, and added at the end will be on top of path)
# This works as a reversed stack (or the one growing downwards), if we
# always add $PATH at the end.

# .local/bin is the installation folder for pip3 install --user
export PATH="$HOME/.local/bin:$PATH"
# add rust 
export PATH="$HOME/.cargo/bin:$PATH"
# add gnu implementation of some tools
export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
export PATH="/usr/local/opt/llvm/bin:$PATH"
# add custom python 3.8
export PATH="$HOME/.localpython/3.8.3/bin:$PATH"
# add local bin and bin/usr for my scripts, functions and programs
# this is where I'll install tools compiled from source
export PATH="$HOME/bin/:$HOME/bin/usr/:$PATH"

# =====================
# setup other variables

# setup rust paths
export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/src/

# force fzf to use ripgrep
export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'

# set the default python for mkvirtualenv
export VIRTUALENVWRAPPER_PYTHON="$HOME/.localpython/3.8.3/bin/python3"

# source the configuration for virtualenvwrapper
if [[ -r "$HOME/.localpython/3.8.3/bin/virtualenvwrapper.sh" ]]; then
    source "$HOME/.localpython/3.8.3/bin/virtualenvwrapper.sh"
else
    echo "WARNING: Can't find virtualenvwrapper.sh"
fi

# set the default directory for virtualenvs
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=""

# disable automatic titles for tmuxp
export DISABLE_AUTO_TITLE='true'

# Set the default editor
export EDITOR="nvim"

# this file is sourced in interactive shell. It should contain commands to set up aliases, functions
# options, key bindings, etc.

ZSH_THEME="robbyrussell"
plugins=(git python)

source $ZSH/oh-my-zsh.sh

alias vim='nvim'
alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias ga='git add'

alias config='/usr/local/bin/git --git-dir=/Users/szymon/.cfg --work-tree=/Users/szymon'

edit-ssh-config() { "$EDITOR" ~/.ssh/config }
edit-zshrc-config() { "$EDITOR" ~/.zshrc }
edit-nvim-config() { "$EDITOR" ~/.config/nvim/init.vim }
edit-oh-my-zsh-config() { "$EDITOR" ~/.oh-my-zsh }

# Add fzf zsh integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# add secrets
[ -f ~/.secrets ] && source ~/.secrets

# add function from .config/zsh/functions directory
__base_dir="$HOME/.config/zsh/functions"
for function_file in $(ls $__base_dir); do
    . "$__base_dir/$function_file"
done
unset function_file
unset __base_dir
