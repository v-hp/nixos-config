# Some config values
NIXUSER ?= vsevolodp
# just from mitchelh
NIXPORT ?= 22
NIXADDR ?= unset

# SSH options that are used. These aren't meant to be overridden but are
# reused a lot so we just store them up here.
SSH_OPTIONS = -o PubkeyAuthentication=no -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no

# Get the path to this Makefile and directory
MAKEFILE_DIR := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# bootstrap a brand new VM. The VM should have NixOS ISO on the CD drive
# and just set the password of the root user to "root". This will install
# NixOS. After installing NixOS, you must reboot and set the root password
# for the next step.
#
# This configuration uses Bios (MBR), not UEFI (GPT). The disk is vda (not sda), since
# we're using KVM

# added users.users.${NIXUSER} to set up my user
# requires extra step on vm, with -> sudo passwd ${NIXUSER} and setting the pass
vm/bootstrap-mbr:
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
			users.users.${NIXUSER}=\{\n \
				isNormalUser = true; \n \
				extraGroups = [\"wheel\"];\n \
			\}; \
		' /mnt/etc/nixos/configuration.nix; \
		nixos-install --no-root-passwd && reboot; \
	"

vm/bootstrap-base:
	NIXUSER=root ${MAKE} vm/copy-config
	NIXUSER=root ${MAKE} vm/copy-secrets

vm/copy-config:
	rsync -av -e 'ssh ${SSH_OPTIONS} -p ${NIXPORT}' \
		--exclude='.git/' \
		--rsync-path="sudo rsync" \
		${MAKEFILE_DIR}/ ${NIXUSER}@${NIXADDR}:/nix-config

vm/copy-secrets:
	rsync -av -e 'ssh ${SSH_OPTIONS} -p ${NIXPORT}' \
	${HOME}/.ssh/ ${NIXUSER}@${NIXADDR}:~/.ssh

