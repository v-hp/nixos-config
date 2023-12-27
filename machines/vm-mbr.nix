{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware/vm-mbr.nix ];

  boot = {
    loader = {
        grub.device = "/dev/vda";
        grub.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;
  };

  nix = {
    package = pkgs.nixUnstable;
    extraOptions = "experimental-features = nix-command flakes";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      monaspace
    ];
  };

  environment.systemPackages = with pkgs; [
    xclip
  ];

  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "America/Edmonton";

  security.sudo.wheelNeedsPassword = false;

  services.xserver = {
    enable = true;
    layout = "us";

    displayManager = {
      defaultSession = "none+i3";
      lightdm.enable = true;
    };

    windowManager = {
      i3.enable = true;
    };
  };

  users.mutableUsers = false;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PasswordAuthentication = true;
  services.openssh.settings.PermitRootLogin = "no";

  networking.hostName = "dev";
  networking.firewall.enable = false;

  system.stateVersion = "23.11";
}
