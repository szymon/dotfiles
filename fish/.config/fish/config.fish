# vim: set sw=2 :
umask 0022

set -Ua fish_user_paths \
  /opt/homebrew/bin \
  $HOME/.vector \
  $HOME/.local/bin \
  $HOME/go/bin \
  $HOME/.cargo/bin \
  /usr/local/go/bin \
  /usr/local/bin

set -Ua LD_LIBRARY_PATH /usr/local/lib

set -Ux DOCKER_HOST "unix://$HOME/.colima/docker.sock"
set -Ux SSH_AUTH_SOCK "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

if test -e ~/.cloudferro.fish
  source ~/.cloudferro.fish
end

if test -e ~/.macos.fish
  source ~/.macos.fish
end

if status is-interactive
  # Do not show any greeting
  set -Ue fish_greeting

  set -U fish_cursor_default block
  set -U fish_cursor_insert block
  set -U fish_cursor_visual block

  set -Ux hydro_symbol_prompt ";"

  set -U EDITOR nvim
  set -U GIT_EDITOR $EDITOR
  set -U nvm_default_version v18.1.0
  set -U FZF_DEFAULT_COMMAND 'rg --files --hidden --follow'
  set -U FZF_DEFAULT_OPTIONS '--bind c-f:preview-page-down,c-b:preview-page-up,ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up --preview # \'bat --color=always {}\''
  set -U DISABLE_AUTO_TITLE true

  if command -v direnv >/dev/null
    direnv export fish | source
    function __direnv_export_eval --on-event fish_postexec; direnv export fish | source; end
  end

  if command -v kubectl >/dev/null
    kubectl completion fish | source
    function k --wraps kubectl; kubectl $argv; end
  end


  function s3prod --wraps s5cmd; s5cmd --endpoint-url https://s3rw.apps.cole.intra.cloudferro.com --credentials-file ~/.s3prod-credentials $argv; end
  function s3code --wraps s5cmd; s5cmd --endpoint-url https://data-pub.cloud.code-de.org --credentials-file ~/.s3code-credentials $argv; end

  bind \co 'tmux-sessionizer'
end

# pnpm
set -gx PNPM_HOME "/Users/srams/Library/pnpm"
if not string match -q -- $PNPM_HOME $PATH
  set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end
