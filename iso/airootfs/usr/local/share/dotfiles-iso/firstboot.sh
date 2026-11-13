# /etc/profile.d/dotfiles-firstboot.sh — installed by the dotfiles ISO.
# On the first interactive TTY login, offer to set the desktop up from dotfiles
# (bootstrap.sh: GitHub login → clone → install.sh). Answering "n" stops asking.

case $- in *i*) ;; *) return 0 ;; esac
[ "$(id -u)" -ne 0 ] || return 0
[ -t 0 ] || return 0
[ -e "$HOME/.local/state/dotfiles-bootstrap.done" ] && return 0
[ -d "$HOME/dotfiles/.git" ] && return 0

printf '\nThis machine was installed from your dotfiles ISO.\n'
printf 'Set up the desktop now (GitHub login, clone dotfiles, install)? [Y/n] '
read -r _dotfiles_ans
case "$_dotfiles_ans" in
  [Nn]*)
    mkdir -p "$HOME/.local/state" && touch "$HOME/.local/state/dotfiles-bootstrap.done"
    printf 'Skipped. Run it any time: /usr/local/share/dotfiles/bootstrap.sh\n'
    ;;
  *)
    if ! curl -fsI --max-time 5 https://github.com >/dev/null 2>&1; then
      printf 'No internet yet. Connect (Wi-Fi: nmtui), then log in again or run:\n'
      printf '  /usr/local/share/dotfiles/bootstrap.sh\n'
    elif /usr/local/share/dotfiles/bootstrap.sh; then
      mkdir -p "$HOME/.local/state" && touch "$HOME/.local/state/dotfiles-bootstrap.done"
    fi
    ;;
esac
unset _dotfiles_ans
