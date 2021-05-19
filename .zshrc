# vim: set ts=4 sw=4 et ai :
# from: http://zsh.sourceforge.net/Intro/intro_3.html
# this file (.zshenv) is read and executed on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment
# variables. .zshenv should not contain commands that produce output or assume that we are connected
# to tty when executing it.

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH
if [[ $(uname) == 'Darwin' ]] && [ -f /etc/profile ]; then
    PATH=""
    source /etc/profile
fi

# Force the terminal language to be English
export LANG=en_US.UTF-8

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Add gnu man pages (from brew)
if [[ $(uname) == 'Darwin' ]]; then
    export MANPATH="/usr/local/man:$MANPATH"
fi


# =======================================================================
# setup path (this goes from top to bottom, the files added at the top
# will be later in the path, and added at the end will be on top of path)
# This works as a reversed stack (or the one growing downwards), if we
# always add $PATH at the end.

# .local/bin is the installation folder for pip3 install --user
[ -d "$HOME/.local" ] && export PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.cargo" ] && export PATH="$HOME/.cargo/bin:$PATH"
[ -d "$HOME/go"     ] && export PATH="$HOME/go/bin/:$PATH"

# add pyenv
if [[ -d "$HOME/.pyenv" ]]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
fi


# FIXME: is there better option to do this?
if [[ $(uname) == 'Darwin' ]]; then
    # add gnu implementation of some tools
    export PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
    export PATH="/usr/local/opt/llvm/bin:$PATH"
    # add custom python 3.8
    export PATH="$HOME/.localpython/3.8.3/bin:$PATH"
fi

# add custom cuda installs, /usr/bin/cuda can be
# managed by update-alternatives and point to the correct version of cuda
export PATH="/usr/local/cuda/bin:$PATH"
export CUDADIR=/usr/loca/cuda
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"

# add local bin and bin/usr for my scripts, functions and programs
# this is where I'll install tools compiled from source
export PATH="$HOME/bin/:$HOME/bin/usr/:$PATH"
export PATH="/home/szymon/.local/bin:$PATH"


# =====================
# setup other variables

# setup rust paths
if command -v rustc 2>&1 >/dev/null; then
    export RUST_SRC_PATH=$(rustc --print sysroot)/lib/rustlib/src/rust/src/
fi

# force fzf to use ripgrep
if command -v rg 2>&1 >/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
fi

if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init -)"
fi

if [ -d "$HOME/.nvm" ]; then
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
fi

export PYTHONBREAKPOINT=ipdb.set_trace
# set the default directory for virtualenvs
export WORKON_HOME="$HOME/.virtualenvs"
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS=""

if [[ -f "$HOME/.local/bin/virtualenvwrapper.sh" ]]; then
    source "$HOME/.local/bin/virtualenvwrapper.sh"
fi

# disable automatic titles for tmuxp
export DISABLE_AUTO_TITLE='true'

# Set the default editor
export EDITOR="/usr/local/bin/nvim"

# this file is sourced in interactive shell. It should contain commands to set up aliases, functions
# options, key bindings, etc.

ZSH_THEME="robbyrussell"
plugins=(git python)

# override default history expansion where pressing <cr> wouldn't execute the command
# just replace current command with expanded history
#
#     $ mkdir build<cr>
#     $ cd !$<cr>  # this would not be executed
#     $ cd build   # it will be replaced by this, by default
unsetopt HIST_VERIFY

source $ZSH/oh-my-zsh.sh

alias gs='git status'
alias gd='git diff'
alias gc='git commit'
alias ga='git add'
alias sr="cd $HOME/code/serenity"
alias tmux-hyper="tmuxp load hyper"
alias tmux-hyper-old="tmuxp load hyper-old"

if [[ $(uname) != 'Darwin' ]]; then
    alias open="xdg-open"
fi

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
if [[ -r $__base_dir ]]; then
for function_file in $(ls $__base_dir); do
    . "$__base_dir/$function_file"
done
unset function_file
fi
unset __base_dir

if [[ $(uname) != 'Darwin' ]]; then
    autoload -U +X bashcompinit && bashcompinit
    complete -o nospace -C /home/szymon/go/bin/terraform terraform
    eval "$(register-python-argcomplete pipx)"

    # Scaleway CLI autocomplete initialization.
    eval "$(scw autocomplete script shell=zsh)"

    function init_pyenv_conda() {
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/szymon/.pyenv/versions/miniconda3-latest/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/szymon/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh" ]; then
            . "/home/szymon/.pyenv/versions/miniconda3-latest/etc/profile.d/conda.sh"
        else
            export PATH="/home/szymon/.pyenv/versions/miniconda3-latest/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
    }
fi
