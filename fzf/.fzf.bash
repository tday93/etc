# Setup fzf
# ---------
if [[ ! "$PATH" == */home/tday/etc/fzf/.fzf/bin* ]]; then
  export PATH="$PATH:/home/tday/etc/fzf/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "/home/tday/etc/fzf/.fzf/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "/home/tday/etc/fzf/.fzf/shell/key-bindings.bash"

