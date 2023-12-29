NIXUSER ?= vsevolodp
NIXPORT ?= 22
NIXADDR ?= unset

SSH_OPTIONS = -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

vm/bootstrap-gnome-boxes:
	ssh $(SSH_OPTIONS) -p$(NIXPORT) root@$(NIXADDR) " \
		parted /dev/vda -- mklabel msdos; \
		parted /dev/vda -- mkpart primary 1MB -8GB; \
		parted /dev/vda -- set 1 boot on; \
		parted /dev/vda -- mkpart primary linux-swap -8GB 100\%; \
		sleep 1; \
		mkfs.ext4 -L nixos /dev/vda1; \
		mkswap -L swap /dev/vda2; \
		sleep 1; \
		mount /dev/disk/by-label/nixos /mnt; \
		nixos-generate-config --root /mnt; \
		sed --in-place '/system\.stateVersion = .*/a \
			nix.package = pkgs.nixUnstable;\n \
			nix.extraOptions = \"experimental-features = nix-command flakes\";\n \
			services.openssh.enable = true;\n \
			services.openssh.settings.PasswordAuthentication = true;\n \
			services.openssh.settings.PermitRootLogin = \"yes\";\n \
			users.users.root.initialPassword = \"root\";\n \
			boot.loader.grub.device = \"/dev/vda\";\n \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

vm/bootstrap-base:
	NIXUSER=root ${MAKE} vm/copy-config
	NIXUSER=root ${MAKE} vm/switch
	${MAKE} vm/copy-secrets
	ssh ${SSH_OPTIONS} -p ${NIXPORT} ${NIXUSER}@${NIXADDR} " \
		sudo reboot; \
	"

vm/copy-config:
	rsync -av -e 'ssh ${SSH_OPTIONS} -p ${NIXPORT}' \
		--exclude='.git/' \
		--rsync-path="sudo rsync" \
		${MAKEFILE_DIR}/ ${NIXUSER}@${NIXADDR}:/nixos-config

vm/copy-secrets:
	rsync -av -e 'ssh ${SSH_OPTIONS} -p ${NIXPORT}' \
	${HOME}/.ssh/ ${NIXUSER}@${NIXADDR}:~/.ssh
	rsync -av -e 'ssh ${SSH_OPTIONS} -p ${NIXPORT}' \
		--exclude='.#*' \
		${HOME}/.gnupg/ ${NIXUSER}@${NIXADDR}:~/.gnupg


vm/switch:
	ssh ${SSH_OPTIONS} -p ${NIXPORT} ${NIXUSER}@${NIXADDR} " \
		nixos-rebuild switch --flake \"/nixos-config#vm-gnome-boxes\" \
	"
