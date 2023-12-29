{ config, pkgs, ... }:
{
  home.stateVersion = "23.11";
  home.username = "vsevolodp";
  home.homeDirectory = "/home/vsevolodp";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    userName = "Vsevolod Palahuta";
    userEmail = "vsevolod.h.p@gmail.com";
    signing = {
      signByDefault = true;
      key = "7C3A4C5612A61938";
    };
  };

  home.packages = with pkgs; [
    neovim
    ripgrep
    fzf
    rofi
    chromium
    gopls
    nodejs
  ];

  programs.zsh = {
    enable = true;
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };

  programs.kitty = {
    enable = true;
    extraConfig = builtins.readFile ./kitty;
  };

  programs.gpg.enable = true;

  programs.go = {
    enable = true;
    goPath = "code/go";
  };

  services.gpg-agent = {
    enable = isLinux;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  xdg = {
    enable = true;
    configFile = {
      "i3/config".text = builtins.readFile ./i3;
    };
  };
}
