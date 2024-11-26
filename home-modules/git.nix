{ pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Peter Esselius";

    aliases = {
      l = "log --graph --decorate --pretty=format:\"%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s %C(yellow)(%C(cyan)%ar%C(yellow), %C(blue)%an%C(yellow))%C(reset)\"";
      ll = "log --graph --decorate --stat --pretty=format:\"%C(yellow)%h%C(reset)%C(auto)%d%C(reset) %s%n %C(cyan)%ar%C(reset), %C(blue)%an%C(reset)%n\"";
      wc = "whatchanged -p --abbrev-commit --pretty=medium";
      dc = "diff --cached";
      unstage = "reset HEAD";
      uncommit = "reset --soft HEAD^";
    };

    ignores = [
      ".*.swp"
      ".DS_Store"
      ".metals/"
      ".bloop/"
      ".vscode/"
    ];

    extraConfig = {
      init = {
        defaultBranch = "main";
      };
      rebase = {
        autoSquash = true;
        autoStash = true;
      };
      rerere = {
        enabled = true;
        autoUpdate = true;
      };
      pull = {
        rebase = true;
      };
      push = {
        default = "simple";
      };
      color = {
        ui = "auto";
      };
      ghq = {
        root = "~/src";
      };
      url."git@github.com:pagero".insteadOf = "https://github.com/pagero";
      url."git@github.com:esselius".insteadOf = "https://github.com/esselius";
    };
  };

  programs.fish = {
    shellAliases = {
      gcb = "git checkout -b";
      gs = "git status -sb";
      "gcan!" = "git commit -v -a --no-edit --amend";
      gcam = "git commit -a -m";
      gl = "git pull";
      gp = "git push";
      gpsup = "git push --set-upstream origin (git rev-parse --abbrev-ref HEAD)";
      gpf = "git push --force-with-lease";
    };

    shellAbbrs = {
      gco = "git checkout";
    };

    functions = {
      glo.body = "cd (${pkgs.ghq}/bin/ghq root)/$argv";
      github-repos.body = ''${pkgs.gh}/bin/gh repo list "$argv" -L 1000 --json sshUrl -q ".[].sshUrl"'';
      github-starred.body = "${pkgs.gh}/bin/gh api /user/starred --paginate -q '.[].ssh_url'";
      github-get-all.body = ''
        github-starred | ${pkgs.ghq}/bin/ghq get -u -P
        github-repos (${pkgs.gh}/bin/gh api /user -q '.login') | ${pkgs.ghq}/bin/ghq get -u -P

        for org in (${pkgs.gh}/bin/gh api /user/orgs -q '.[].login')
          github-repos $org | ${pkgs.ghq}/bin/ghq get -u -P
        end
      '';
    };
  };

  xdg.configFile."fish/completions/glo.fish".text = "complete -f -c glo -a '(${pkgs.ghq}/bin/ghq list | sort)'";

  home.packages = with pkgs; [ gh ghq ];
}
