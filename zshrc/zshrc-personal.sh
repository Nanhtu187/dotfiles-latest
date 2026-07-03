# Filename: ~/github/dotfiles-latest/zshrc/zshrc-personal.sh
# Personal zsh config (committed). Sourced from ~/.zshrc_local/env-setup.sh,
# which the framework loads (zshrc-macos.sh). Secrets stay in that local stub.

# ---- Oh My Zsh + Powerlevel10k prompt (replaces starship) ----
# Starship init in zshrc-macos.sh is disabled; p10k provides the prompt.
# Run `p10k configure` once to generate ~/.p10k.zsh (interactive wizard).
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git)
source "$ZSH/oh-my-zsh.sh"
# ~/.p10k.zsh is sourced at the end of zshrc-file.sh (added by `p10k configure`)

# ---- personal environment (go/nvm/sdkman/conda/android/ssh/tokens/PATH) ----
[[ -s "/Users/nanhtu/.gvm/scripts/gvm" ]] && source "/Users/nanhtu/.gvm/scripts/gvm"
export GOPRIVATE="git.teko.vn,go.tekoapis.com,rpc.tekoapis.com"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
eval "$(direnv hook zsh)"
export PATH="/Users/nanhtu/.aiken/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

# Source all files in .config/zsh
for file in ~/.config/zsh/*.zsh; do
	[ -r "$file" ] && source "$file"
done
export PATH=$PATH:$(go env GOPATH)/bin

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
ssh-add ~/.ssh/tu.na
ssh-add ~/.ssh/nanhtu
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:/Users/nanhtu/.local/bin
export PATH="/opt/homebrew/opt/llvm/bin:$PATH"

# OpenClaw Completion
source "/Users/nanhtu/.openclaw/completions/openclaw.zsh"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/nanhtu/anaconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/nanhtu/anaconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/nanhtu/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/nanhtu/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<



# Added by Antigravity CLI installer
export PATH="/Users/nanhtu/.local/bin:$PATH"

# ---- late init: runs on first precmd, AFTER the framework finishes ----
# Needed because the framework (a) hardcodes STARSHIP_CONFIG after our overlay
# loads, and (b) syntax-highlighting must be sourced last (after autosuggestions).
autoload -Uz add-zsh-hook
_my_late_init() {
  # zsh-syntax-highlighting must load last
  local shl="$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  [ -f "$shl" ] && source "$shl"
  # Personal aliases (override linkarzu's ls/ll/lla/cat defaults)
  alias c="clear"
  alias nv="nvim"
  alias cat="bat"
  alias ls="eza --tree --level=2 --icons --color=always --git --group-directories-first"
  alias ll="ls -l"
  alias la="ls -a"
  alias lla="ls -la"
  alias kctl="kubectl"
  add-zsh-hook -d precmd _my_late_init
}
add-zsh-hook precmd _my_late_init
