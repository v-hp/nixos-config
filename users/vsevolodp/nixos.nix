{ pkgs, inputs, ... }:
{
  environment.localBinInPath = true;

  programs.zsh.enable = true;

  users.users.vsevolodp = {
    isNormalUser = true;
    home = "/home/vsevolodp";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    hashedPassword = "$6$7ylt6Y57b4ke37Iy$qt9dNvV0UGEQhVTBEK0Zhq7JrmyZoAC//yGGv9FUEvlkXJYtCr/xKcqaWmoSZwCDVAvWHp.yP9aeEvbkIDK4B1";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINwupKvCiLtuEnWTgI2kBYoxYqyWe/pXVopMjnxLQFbu vhp@fedora"
    ];
  };
}
