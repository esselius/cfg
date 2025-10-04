{ pkgs, ... }:

{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    vimAlias = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      shiftwidth = 2;
      undofile = true;
    };
    nixpkgs.pkgs = pkgs;


    editorconfig.enable = true;

    plugins = {
      avante.enable = true;
      copilot-vim.enable = true;
      clangd-extensions.enable = true;
      web-devicons.enable = true;

      auto-save.enable = true;

      airline.enable = true;

      bufferline.enable = true;

      telescope.enable = true;

      treesitter.enable = true;

      gitblame.enable = true;

      gitgutter.enable = true;

      indent-o-matic.enable = true;

      which-key.enable = true;

      neo-tree.enable = true;

      noice.enable = true;

      lsp = {
        enable = true;

        servers = {
          nixd.enable = true;
          metals = {
            enable = true;
            filetypes = [ "sc" "scala" "java" ];
          };
          dockerls.enable = true;
          tilt_ls.enable = true;
          protols = { enable = true; package = null; };
          pylsp.enable = true;
          gopls.enable = true;
          clangd.enable = true;
          regols = {
            enable = true;
            filetypes = [ "rego" ];
          };
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

    extraPlugins = with pkgs.vimPlugins; [
      nvim-metals
    ];

    extraConfigLua = ''
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "scala", "sbt" },
        callback = function()
          require("metals").initialize_or_attach({})
        end,
        group = nvim_metals_group,
      })
      require("telescope")
    '';

    colorschemes.gruvbox.enable = true;
  };

  programs.fish.shellAbbrs = {
    vim = "nvim";
  };
}
