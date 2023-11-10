xset r rate 200 40

umask 0022

# Do not show any greeting
set --universal --erase fish_greeting

set -x EDITOR nvim
set -x GIT_EDITOR $EDITOR
set --universal nvm_default_version v18.1.0

function fd --wraps fdfind; fdfind $args; end
function bat --wraps batcat; batcat $args; end


contains $HOME/.vector $fish_user_paths; or set -Ua fish_user_paths $HOME/.vector
contains $HOME/.local/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/.local/bin
contains $HOME/.krew/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/.krew/bin
contains $HOME/go/bin $fish_user_paths; or set -Ua fish_user_paths $HOME/go/bin
contains /usr/local/go/bin $fish_user_paths; or set -Ua fish_user_paths /usr/local/go/bin
contains /usr/local/bin $fish_user_paths; or set -Ua fish_user_paths /usr/local/bin
contains /usr/local/lib $LD_LIBRARY_PATH; or set -Ua LD_LIBRARY_PATH /usr/local/lib

set -x FZF_DEFAULT_COMMAND 'rg --files --hidden --follow'
set -x DISABLE_AUTO_TITLE true

kubectl completion fish | source

function k --wraps kubectl; kubectl $argv; end
function __direnv_export_eval --on-event fish_postexec; "/usr/bin/direnv" export fish | source; end

if test -f ~/.cloudferro.fish
    source ~/.cloudferro.fish
end

function urlencode
    jq -rn --arg v "$argv" '$v|@uri'
end

if status --is-interactive
    # set -g theme_color_scheme gruvbox
    theme_gruvbox dark

    set __fish_git_prompt_showdirtystate 'yes'
    set __fish_git_prompt_showstashstate 'yes'
    set __fish_git_prompt_showuntrackedfiles 'yes'
    set __fish_git_prompt_show_informative_status 'yes'
    set __fish_git_prompt_showupstream 'yes'


    fzf_configure_bindings

    bind \e\cf 'tmux-sessionizer'
end
