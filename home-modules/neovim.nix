{ inputs, pkgs, ... }:

let
  unstable-pkgs = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    nixpkgs.pkgs = unstable-pkgs;

    vimAlias = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      shiftwidth = 2;
      undofile = true;
    };

    plugins = {
      web-devicons.enable = true;

      auto-save.enable = true;

      airline.enable = true;

      bufferline.enable = true;

      telescope.enable = true;

      treesitter.enable = true;

      gitblame.enable = true;

      indent-o-matic.enable = true;

      which-key.enable = true;

      neo-tree.enable = true;

      noice.enable = true;
      lazy.enable = true;

      lsp = {
        enable = true;

        servers = {
          nixd.enable = true;
          metals.enable = true;
          dockerls.enable = true;
          tilt_ls.enable = true;
          protols = { enable = true; package = null; };
          pylsp.enable = true;
        };
      };

      lsp-status.enable = true;

      lsp-format = {
        enable = true;
      };

      cmp = {
        enable = true;
        autoEnableSources = true;
        settings.sources = [
          { name = "nvim_lsp"; }
          { name = "path"; }
          { name = "buffer"; }
        ];
      };
    };

    colorschemes.catppuccin.enable = true;
  };
}
