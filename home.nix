{ config, pkgs, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "ale";
  home.homeDirectory = "/home/ale";
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
  
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    pkgs.nushell 
    pkgs.fzf
    pkgs.bat
    pkgs.zoxide

    (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {};

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  xdg.mimeApps.defaultApplications = { "text/plain" = [ "neovide.desktop" ];
    "application/pdf" = [ "zathura.desktop" ];
    "image/*" = [ "sxiv.desktop" ];
    "video/png" = [ "mpv.desktop" ];
    "video/jpg" = [ "mpv.desktop" ];
    "video/*" = [ "mpv.desktop" ];
  };

  programs = { 
    git = {
      enable = true;
      userName = "mifsud.aleandro";
      userEmail = "mifsud.aleandro@gmail.com";
    };

    nushell = {
      enable = true;
      package = pkgs.nushell;

      shellAliases = {
        ll = "ls -la";
        cat = "bat";
        z = "zoxide";
      };
    };

    starship = {
      enable = true;
         settings = {
           add_newline = true;
           character = { 
           success_symbol = "[➜](bold green)";
           error_symbol = "[➜](bold red)";
         };
      };
    };

    neovim = 
      let
        toLua = str: "lua << EOF\n${str}\nEOF\n";
        toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
      in
      {
      enable = true;
      
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraPackages = with pkgs; [
        lua-language-server
        xclip
        wl-clipboard
      ];

      plugins = with pkgs.vimPlugins; [
      {
        plugin = neo-tree-nvim;
        config = toLuaFile ./nvim/plugin/neo-tree.lua; 
      }    

      {
        plugin = which-key-nvim;
        config = toLuaFile ./nvim/plugin/which-key.lua; 
      }

      {
        plugin = barbar-nvim;
        type = "lua";
        config = ''
          local bufferline = require('bufferline')
          bufferline.setup{}
        ''; 
      }
      {
        plugin = comment-nvim;
        config = toLua "require(\"Comment\").setup()";
      }


      {
        plugin = telescope-nvim;
        config = toLuaFile ./nvim/plugin/telescope.lua;
      }

      
      {
        plugin = lualine-nvim;
        type = "lua";
        config = ''
          require('lualine').setup{}
        '';
      }

      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = ''
          require('gitsigns').setup{}
        '';
      }


      telescope-fzf-native-nvim
      # cmp-nvim-lsp
      friendly-snippets
      nvim-web-devicons
      neodev-nvim
      vim-nix

      {
        plugin = (nvim-treesitter.withPlugins (p: [
          p.tree-sitter-nix
          p.tree-sitter-vim
          p.tree-sitter-bash
          p.tree-sitter-lua
          p.tree-sitter-python
          p.tree-sitter-json
        ]));
        config = toLuaFile ./nvim/plugin/treesitter.lua;
      }

    ];

      extraLuaConfig = ''
       ${builtins.readFile ./nvim/options.lua}
      '';
    };

    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };
}
