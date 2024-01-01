{ config, pkgs, inputs, ... }:
{
  home.stateVersion = "23.11";
  home.username = "vsevolodp";
  home.homeDirectory = "/home/vsevolodp";

  nixpkgs = {
    overlays = [
      (final: prev: {
        vimPlugins = prev.vimPlugins // {
          fugitive = prev.vimUtils.buildVimPlugin {
            name = "fugitive";
            src = inputs.fugitive;
          };
        };
      })
    ];
  };

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

  programs.tmux = {
    enable = true;
    terminal = "screen-256color";
    mouse = true;
    shortcut = "a";

    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.resurrect;
        extraConfig = "set -g @resurrect-capture-pane-contents 'on'";
      }
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
      {
        plugin = tmuxPlugins.power-theme;
        extraConfig = "set -g @tmux_power_theme '#2495db'";
      }
    ];
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    plugins = with pkgs.vimPlugins; [
      {
        plugin = gruvbox-nvim;
        config = "colorscheme gruvbox";
      }
      {
        plugin = comment-nvim;
        config = "lua << EOF\nrequire(\"Comment\").setup()\nEOF\n";
      }
      auto-pairs
      {
      	plugin = fugitive;
        config = "lua << EOF\n${builtins.readFile ./nvim/plugins/fugitive.lua}\nEOF\n";
      }
      {
        plugin = lualine-nvim;
        config = "lua << EOF\n${builtins.readFile ./nvim/plugins/lualine.lua}\nEOF\n";
      }
      vim-tmux-navigator
      {
        plugin = undotree;
        config = "lua << EOF\nvim.keymap.set(\"n\", \"<leader>u\", vim.cmd.UndotreeToggle)\nEOF\n";
      }
      {
        plugin = lsp-zero-nvim;
        config = "lua<< EOF\n${builtins.readFile ./nvim/plugins/lsp.lua}\nEOF\n";
      }
      mason-nvim
      mason-lspconfig-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-buffer
      cmp-path
      cmp_luasnip
      cmp-nvim-lsp
      cmp-nvim-lua
    ];

    extraLuaConfig = ''
    	${builtins.readFile ./nvim/remap.lua}
    '';
  };

  programs.gpg.enable = true;

  programs.go = {
    enable = true;
    goPath = "code/go";
  };

  services.gpg-agent = {
    enable = true;
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
