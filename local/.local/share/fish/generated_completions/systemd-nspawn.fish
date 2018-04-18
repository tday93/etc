# systemd-nspawn
# Autogenerated from man page /usr/share/man/man1/systemd-nspawn.1.gz
# using Deroffing man parser
complete -c systemd-nspawn -s D -l directory --description 'Directory to use as file system root for the container.'
complete -c systemd-nspawn -l template --description 'Directory or "btrfs" subvolume to use as templa… [See Man Page]'
complete -c systemd-nspawn -s x -l ephemeral --description 'If specified, the container is run with a tempo… [See Man Page]'
complete -c systemd-nspawn -s i -l image --description 'Disk image to mount the root directory for the container from.'
complete -c systemd-nspawn -s a -l as-pid2 --description 'Invoke the shell or specified program as proces… [See Man Page]'
complete -c systemd-nspawn -s b -l boot --description 'Automatically search for an init binary and inv… [See Man Page]'
complete -c systemd-nspawn -l chdir --description 'Change to the specified working directory befor… [See Man Page]'
complete -c systemd-nspawn -s u -l user --description 'After transitioning into the container, change … [See Man Page]'
complete -c systemd-nspawn -s M -l machine --description 'Sets the machine name for this container.'
complete -c systemd-nspawn -l uuid --description 'Set the specified UUID for the container.'
complete -c systemd-nspawn -l slice --description 'Make the container part of the specified slice,… [See Man Page]'
complete -c systemd-nspawn -l property --description 'Set a unit property on the scope unit to regist… [See Man Page]'
complete -c systemd-nspawn -l private-users --description 'Controls user namespacing.'
complete -c systemd-nspawn -s U --description 'If the kernel supports the user namespaces feat… [See Man Page]'
complete -c systemd-nspawn -l private-users-chown --description 'If specified, all files and directories in the … [See Man Page]'
complete -c systemd-nspawn -l private-network --description 'Disconnect networking of the container from the host.'
complete -c systemd-nspawn -l network-interface --description 'Assign the specified network interface to the container.'
complete -c systemd-nspawn -l network-macvlan --description 'Create a "macvlan" interface of the specified E… [See Man Page]'
complete -c systemd-nspawn -l network-ipvlan --description 'Create an "ipvlan" interface of the specified E… [See Man Page]'
complete -c systemd-nspawn -s n -l network-veth --description 'Create a virtual Ethernet link ("veth") between… [See Man Page]'
complete -c systemd-nspawn -l network-veth-extra --description 'Adds an additional virtual Ethernet link betwee… [See Man Page]'
complete -c systemd-nspawn -l network-bridge --description 'Adds the host side of the Ethernet link created… [See Man Page]'
complete -c systemd-nspawn -l network-zone --description 'Creates a virtual Ethernet link ("veth") to the… [See Man Page]'
complete -c systemd-nspawn -s p -l port --description 'If private networking is enabled, maps an IP po… [See Man Page]'
complete -c systemd-nspawn -s Z -l selinux-context --description 'Sets the SELinux security context to be used to… [See Man Page]'
complete -c systemd-nspawn -s L -l selinux-apifs-context --description 'Sets the SELinux security context to be used to… [See Man Page]'
complete -c systemd-nspawn -l capability --description 'List one or more additional capabilities to gra… [See Man Page]'
complete -c systemd-nspawn -l drop-capability --description 'Specify one or more additional capabilities to … [See Man Page]'
complete -c systemd-nspawn -l kill-signal --description 'Specify the process signal to send to the conta… [See Man Page]'
complete -c systemd-nspawn -l link-journal --description 'Control whether the container\\*(Aqs journal sha… [See Man Page]'
complete -c systemd-nspawn -s j --description 'Equivalent to --link-journal=try-guest.'
complete -c systemd-nspawn -l read-only --description 'Mount the root file system read-only for the container.'
complete -c systemd-nspawn -l bind -l bind-ro --description 'Bind mount a file or directory from the host in… [See Man Page]'
complete -c systemd-nspawn -l tmpfs --description 'Mount a tmpfs file system into the container.'
complete -c systemd-nspawn -l overlay -l overlay-ro --description 'Combine multiple directory trees into one overl… [See Man Page]'
complete -c systemd-nspawn -s E -l setenv --description 'Specifies an environment variable assignment to… [See Man Page]'
complete -c systemd-nspawn -l share-system --description 'Allows the container to share certain system fa… [See Man Page]'
complete -c systemd-nspawn -l register --description 'Controls whether the container is registered wi… [See Man Page]'
complete -c systemd-nspawn -l keep-unit --description 'Instead of creating a transient scope unit to r… [See Man Page]'
complete -c systemd-nspawn -l personality --description 'Control the architecture ("personality") report… [See Man Page]'
complete -c systemd-nspawn -s q -l quiet --description 'Turns off any status output by the tool itself.'
complete -c systemd-nspawn -l volatile -l volatile --description 'Boots the container in volatile mode.'
complete -c systemd-nspawn -l settings --description 'Controls whether systemd-nspawn shall search fo… [See Man Page]'
complete -c systemd-nspawn -l notify-ready --description 'Configures support for notifications from the c… [See Man Page]'
complete -c systemd-nspawn -s h -l help --description 'Print a short help text and exit.'
complete -c systemd-nspawn -l version --description 'Print a short version string and exit.'
complete -c systemd-nspawn -l 'ephemeral.' --description '.'
complete -c systemd-nspawn -l 'share-system.' --description '.'
complete -c systemd-nspawn -l 'network-veth.' --description '.'
complete -c systemd-nspawn -l 'private-network.' --description '.'
complete -c systemd-nspawn -l network-zones --description 'switch of the various concurrently running cont… [See Man Page]'
complete -c systemd-nspawn -l 'read-only.' --description '"\\:" may be used to embed colons in the path.'
complete -c systemd-nspawn -l 'boot.' --description '.'

