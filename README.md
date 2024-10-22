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
$ parted /dev/sda -- mklabel gpt
$ parted /dev/sda -- mkpart root ext4 512MB -8GB
$ parted /dev/sda -- mkpart swap linux-swap -8GB 100%
$ parted /dev/sda -- mkpart ESP fat32 1MB 512MB
$ parted /dev/sda -- set 3 esp on

$ mkfs.ext4 -L nixos /dev/sda1
$ mkswap -L swap /dev/sda2
$ mkfs.fat -F 32 -n boot /dev/sda3

$ mount /dev/disk/by-label/nixos /mnt
$ mkdir -p /mnt/boot
$ mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
$ swapon /dev/sda2

$ nixos-install --flake github:esselius/cfg#vm
```
