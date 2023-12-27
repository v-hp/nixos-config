{ config, pkgs, ... }:
{
  xdg = {
    enable = true;
    configFile = {
      "i3/config".text = builtins.readFile ./i3;
    };
  };

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
