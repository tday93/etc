# sysctl
# Autogenerated from man page /usr/share/man/man8/sysctl.8.gz
# using Deroffing man parser
complete -c sysctl -s w --description 'parameter to use.'
complete -c sysctl -s n -l values --description 'Use this option to disable printing of the key … [See Man Page]'
complete -c sysctl -s e -l ignore --description 'Use this option to ignore errors about unknown keys.'
complete -c sysctl -s N -l names --description 'Use this option to only print the names.'
complete -c sysctl -s q -l quiet --description 'Use this option to not display the values set to stdout.'
complete -c sysctl -l write --description 'Use this option when you want to change a sysctl setting.'
complete -c sysctl -o 'p[FILE]' -l 'load[' --description 'Load in sysctl settings from the file specified or /etc/sysctl.'
complete -c sysctl -s a -l all --description 'Display all values currently available.'
complete -c sysctl -l deprecated --description 'Include deprecated parameters to.'
complete -c sysctl -s b -l binary --description 'Print value without new line.'
complete -c sysctl -l system --description 'Load settings from all system configuration files.'
complete -c sysctl -s r -l pattern --description 'Only apply settings that match pattern .'
complete -c sysctl -s A --description 'Alias of -a.'
complete -c sysctl -s d --description 'Alias of -h.'
complete -c sysctl -s f --description 'Alias of -p.'
complete -c sysctl -s X --description 'Alias of -a.'
complete -c sysctl -s o --description 'Does nothing, exists for BSD compatibility.'
complete -c sysctl -s x --description 'Does nothing, exists for BSD compatibility.'
complete -c sysctl -s h -l help --description 'Display help text and exit.'
complete -c sysctl -s V -l version --description 'Display version information and exit.'

