# Usage

Install nix with the DeterminateSystems nix-installer

```shell
$ nix-installer plan macos --case-sensitive --extra-conf "use-case-hack = false" --encrypt true > plan.json
$ nix-installer install plan.json
```

Switch darwin config

```shell
$ sudo mv /etc/nix/nix.conf{,.before-nix-darwin}
$ nix  --extra-experimental-features 'flakes nix-command' run nix-darwin -- switch --flake .
```