# Usage

## Local darwin config

Install nix with the [DeterminateSystems nix-installer](https://github.com/DeterminateSystems/nix-installer)

```shell
$ nix-installer plan macos --case-sensitive --extra-conf "use-case-hack = false" --encrypt true > plan.json
$ nix-installer install plan.json

$ sudo mv /etc/nix/nix.conf{,.before-nix-darwin}
$ nix  --extra-experimental-features 'flakes nix-command' run nix-darwin -- switch --flake .
```

## Raspberry Pi bootstrap

Generate SD card image

```shell
$ nix build .#nixosConfigurations.adama.config.system.build.sdImage
$ unzstd result/sd-image/nixos-sd-image-24.05.20240706.49ee0e9-aarch64-linux.img.zst -o x.img
```

Flash SD card or USB stick with `x.img` using [Raspberry Pi Imager](https://www.raspberrypi.com/software/), put in RPi and start attached to network.

Grab new ssh host key.

```shell
$ ssh-keyscan 192.168.1.195
```

Update host key in `secrets/secrets.nix` and rekey secrets.

```shell
$ cd secrets
$ agenix --rekey
```

Deploy refreshed secrets.

```shell
$ nixos-rebuild switch --flake . --target-host 192.168.1.195 --fast --use-remote-sudo
```