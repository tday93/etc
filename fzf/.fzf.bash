# Setup fzf
# ---------
if [[ ! "$PATH" == */home/tday/.fzf/bin* ]]; then
  export PATH="$PATH:/home/tday/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/tday/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/tday/.fzf/shell/key-bindings.bash"

