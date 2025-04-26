{ inputs, pkgs, ... }:

let
  unstable-pkgs = import inputs.nixpkgs-unstable { inherit (pkgs.stdenv) system; };
in
{
  imports = [ inputs.nixvim.homeManagerModules.nixvim ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    nixpkgs.pkgs = unstable-pkgs;

    vimAlias = true;

    globals.mapleader = " ";

    opts = {
      number = true;
      shiftwidth = 2;
      undofile = true;
    };


    editorconfig.enable = true;

    plugins = {
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
      plenary-nvim
      (pkgs.vimUtils.buildVimPlugin {
        name = "dbtpal.nvim";
        src = pkgs.fetchFromGitHub {
          owner = "PedramNavid";
          repo = "dbtpal";
          rev = "c526f65";
          hash = "sha256-qQZrfTUIhmYaXwNFnTudnapK41g7xww5VPfggLyrrew=";
        };
      })
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
      require("dbtpal").setup({
          path_to_dbt = "dbt",
          path_to_dbt_project = "src/dbt",
          path_to_dbt_profiles_dir = vim.fn.getcwd(),
          extended_path_search = true,
          protect_compiled_files = true,
          custom_dbt_syntax_enabled = true,
      })
      require("telescope").load_extension("dbtpal")
    '';

    colorschemes.gruvbox.enable = true;
  };

  programs.fish.shellAbbrs = {
    vim = "nvim";
  };
}
