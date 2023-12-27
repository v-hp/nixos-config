{ config, pkgs, ... }:
{

  home.stateVersion = "23.11";
  home.username = "vsevolodp";
  home.homeDirectory = "/home/vsevolodp";

  programs.git = {
    enable = true;

    userName = "Vsevolod Palahuta";
    userEmail = "vsevolod.h.p@gmail.com";
  };

  home.packages = with pkgs; [
    neovim
    ripgrep
    fzf
    rofi
  ];

  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable = true;
      plugins = [ "git" "zsh-autosuggestions" ];
      theme = "robbyrussell";
    };
  };

  programs.kitty = {
    enable = true;
  };

  xdg = {
    enable = true;
    configFile = {
      "i3/config".text = builtins.readFile ./i3;
    };
  };

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
