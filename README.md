# bootonce

`bootonce` is a small Raspberry Pi 5 / Compute Module 5 recovery helper.

It provides one short command interface for:

- one-time USB or NVMe boot override
- restoring `bootonce` into an offline OS
- preparing Raspberry Pi Connect on an offline OS
- imaging SD/eMMC, USB, or NVMe storage
- optional PiShrink post-processing

It is intentionally verbose by default. It prints what it is doing, what command or path is affected, and whether each step succeeded or failed.

## Supported

- Raspberry Pi 5
- Compute Module 5

## Not supported

- Raspberry Pi 4 / Compute Module 4 one-time boot override

The Pi 4 / CM4 do not support the same clean Pi 5 style one-time boot-order override.

## Install

Download the `.deb` from Releases or from `dist/` and run:

```bash
sudo apt install ./bootonce_1.5.3_all.deb
```

Check:

```bash
sudo bootonce version
sudo bootonce help
```

## Short command list

```text
sudo bootonce help                  Show all commands
sudo bootonce version               Show installed version
sudo bootonce status                Show boot/storage state
sudo bootonce doctor                Run readiness checks

sudo bootonce usb on                Set next boot to USB, reboot manually
sudo bootonce nvme on               Set next boot to NVMe, reboot manually

sudo bootonce restore               Restore bootonce to a selected offline OS
sudo bootonce verify                Verify bootonce on a selected offline OS
sudo bootonce connect               Set hostname, Connect key and network on a selected offline OS

sudo bootonce makeimage sd          Image SD/eMMC storage
sudo bootonce makeimage emmc        Image SD/eMMC storage
sudo bootonce makeimage usb         Image USB storage
sudo bootonce makeimage nvme        Image NVMe storage
sudo bootonce makeimage pishrink    Shrink an existing .img with PiShrink
```

## Typical workflow

Prepare USB recovery OS from eMMC:

```bash
sudo bootonce connect
sudo bootonce restore
sudo bootonce usb on
sudo reboot
```

From USB recovery OS, prepare eMMC again:

```bash
sudo bootonce connect
sudo bootonce restore
sudo reboot
```

Create an image:

```bash
sudo bootonce makeimage emmc
```

Shrink an existing image later:

```bash
sudo bootonce makeimage pishrink
```

## Install from GitHub

```bash
cd /tmp

wget https://github.com/fishieststick/bootonce/releases/download/v1.5.3/bootonce_1.5.3_all.deb
wget https://github.com/fishieststick/bootonce/releases/download/v1.5.3/bootonce_1.5.3_SHA256SUMS.txt

sha256sum -c bootonce_1.5.3_SHA256SUMS.txt --ignore-missing

sudo apt install ./bootonce_1.5.3_all.deb

## Design rules

- one public command: `bootonce`
- short memorable subcommands
- no automatic reboot
- verbose by default
- no hidden destructive actions
- refuse to modify the currently running root filesystem
- redacts Raspberry Pi Connect auth keys in logs and summaries
- logs to `/var/log/bootonce.log`

## Build package

```bash
./build-deb.sh
```

The built package appears in `dist/`.

## License

MIT
