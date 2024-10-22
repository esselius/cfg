{ inputs, ... }:

{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;

    vimAlias = true;

    opts = {
      number = true;
      shiftwidth = 2;
    };

    plugins = {
      airline.enable = true;

      bufferline.enable = true;

      telescope.enable = true;

      treesitter.enable = true;

      lsp = {
        enable = true;

        servers = {
          nixd.enable = true;
        };
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
    colorschemes.vscode.enable = true;
  };
}
