# Usage

## Local darwin config

Install nix with the [DeterminateSystems nix-installer](https://github.com/DeterminateSystems/nix-installer)

```shell
curl -sL -o nix-installer https://install.determinate.systems/nix/nix-installer-aarch64-darwin
chmod +x nix-installer
./nix-installer plan macos --case-sensitive --extra-conf "use-case-hack = false" --encrypt true > plan.json
./nix-installer install plan.json
```

For macos defaults to work, you need to [grant full disk access to the terminal](https://www.alfredapp.com/help/troubleshooting/indexing/terminal-full-disk-access/).

```shell
sudo nix run nix-darwin -- switch --flake .
nix run home-manager -- switch --flake .
```
