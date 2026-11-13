#!/usr/bin/env bash
#
# Live ISO entry point on tty1 (sourced by releng's .zlogin).
# Keeps archiso's `script=` boot parameter working; otherwise starts the
# dotfiles installer. Leaving the installer drops to the normal root shell.

[[ $(tty) == "/dev/tty1" ]] || return 0 2>/dev/null || exit 0

script_cmdline() {
    local param
    for param in $(</proc/cmdline); do
        case "${param}" in script=*) echo "${param#*=}"; return 0 ;; esac
    done
}

script="$(script_cmdline)"
if [[ -n "${script}" && ! -x /tmp/startup_script ]]; then
    if [[ "${script}" =~ ^((http|https|ftp|tftp)://) ]]; then
        systemd-run --pty --quiet -p Wants=network-online.target -p After=network-online.target \
            curl "${script}" --location --retry-connrefused --retry 10 --fail -s -o /tmp/startup_script
    else
        cp "${script}" /tmp/startup_script
    fi && chmod +x /tmp/startup_script && /tmp/startup_script
elif [[ ! -e /tmp/dotfiles-installer.ran ]]; then
    touch /tmp/dotfiles-installer.ran
    /usr/local/bin/dotfiles-installer
fi
