# zsh-syntax-highlighting styles — make valid vs invalid commands obvious.
# Sourced during main load (via zshrc-personal.sh's ~/.config/zsh/*.zsh loop),
# before the plugin loads. The plugin sets its defaults with := (only-if-unset),
# so these values win.
#   valid command / builtin / alias / function -> bold green
#   unknown command                            -> bold red
typeset -gA ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=blue,underline'
