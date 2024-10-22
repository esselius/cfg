{ inputs, ... }:

{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    vimAlias = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      shiftwidth = 2;
      undofile = true;
    };

    plugins = {
      auto-save.enable = true;

      airline.enable = true;

      bufferline.enable = true;

      telescope.enable = true;

      treesitter.enable = true;

      gitblame.enable = true;

      indent-o-matic.enable = true;

      which-key.enable = true;

      neo-tree.enable = true;

      lsp = {
        enable = true;

        servers = {
          nixd.enable = true;
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
