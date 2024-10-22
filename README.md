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
$ task nixos:sd host=adama
```

Flash SD card or USB stick with `sd.img` using [Raspberry Pi Imager](https://www.raspberrypi.com/software/), put in RPi and start attached to network.

Grab new ssh host key.

```shell
$ ssh-keyscan 192.168.1.195
```

Update host key in `secrets/secrets.nix` and rekey secrets.

```shell
$ cd secrets
$ agenix --rekey
```

Copy user secret decryption key to home dir.

```shell
$ scp ~/.ssh/id_ed25519 adama:.ssh/
```

Deploy refreshed secrets.

```shell
$ nixos-rebuild switch --flake . --target-host 192.168.1.195 --fast --use-remote-sudo
```

VM install

```
$ nixos-install --flake github:esselius/cfg#vm
```
