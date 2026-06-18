# bootonce

`bootonce` is a small Raspberry Pi 5 and Compute Module 5 recovery helper.

It gives technicians one short command interface for:

* one-time USB boot override
* one-time NVMe boot override
* restoring `bootonce` into an offline OS
* preparing Raspberry Pi Connect on an offline OS
* setting hostname and basic network configuration on an offline OS
* imaging SD, eMMC, USB, or NVMe storage
* optional PiShrink post-processing

The tool is intentionally verbose by default. It prints what it is doing, which command or path is affected, and whether each step succeeded or failed.

## Supported devices

* Raspberry Pi 5
* Raspberry Pi Compute Module 5

## Not supported

* Raspberry Pi 4
* Raspberry Pi Compute Module 4

Raspberry Pi 4 and Compute Module 4 do not support the same clean Pi 5 style one-time boot order override used by this tool.

## Install from GitHub Release

```bash
cd /tmp

wget https://github.com/fishieststick/bootonce/releases/download/v1.5.3/bootonce_1.5.3_all.deb
wget https://github.com/fishieststick/bootonce/releases/download/v1.5.3/bootonce_1.5.3_SHA256SUMS.txt

sha256sum -c bootonce_1.5.3_SHA256SUMS.txt --ignore-missing

sudo apt install ./bootonce_1.5.3_all.deb
```

Check the installation:

```bash
sudo bootonce version
sudo bootonce help
```

## Install from local file

Download the `.deb` from the release page or use the package from `dist/`:

```bash
sudo apt install ./bootonce_1.5.3_all.deb
```

## Commands

```text
sudo bootonce help                  Show all commands
sudo bootonce version               Show installed version
sudo bootonce status                Show boot and storage state
sudo bootonce doctor                Run readiness checks

sudo bootonce usb on                Set next boot to USB, then reboot manually
sudo bootonce nvme on               Set next boot to NVMe, then reboot manually

sudo bootonce restore               Restore bootonce to a selected offline OS
sudo bootonce verify                Verify bootonce on a selected offline OS
sudo bootonce connect               Prepare hostname, Connect key, and network on a selected offline OS

sudo bootonce makeimage sd          Image SD storage
sudo bootonce makeimage emmc        Image eMMC storage
sudo bootonce makeimage usb         Image USB storage
sudo bootonce makeimage nvme        Image NVMe storage
sudo bootonce makeimage pishrink    Shrink an existing .img with PiShrink
```

## Typical workflow

### Prepare USB recovery OS from eMMC

Boot into the normal eMMC OS, then run:

```bash
sudo bootonce connect
sudo bootonce restore
sudo bootonce usb on
sudo reboot
```

The next boot goes to USB once. After that, the normal boot order is used again.

### Prepare eMMC from USB recovery OS

Boot into the USB recovery OS, then run:

```bash
sudo bootonce connect
sudo bootonce restore
sudo reboot
```

### Create an image

Example for eMMC:

```bash
sudo bootonce makeimage emmc
```

After the raw image is created, `bootonce` asks whether PiShrink should be used.

### Shrink an existing image later

```bash
sudo bootonce makeimage pishrink
```

If PiShrink is missing, `bootonce` can recheck, ask for a manual path, skip shrinking, or download PiShrink from the official Drewsif/PiShrink GitHub source.

## Design goals

* one public command: `bootonce`
* short and memorable subcommands
* no automatic reboot behavior
* verbose output by default
* no hidden destructive actions
* refuse to modify the currently running root filesystem
* redact Raspberry Pi Connect auth keys in logs and summaries
* log actions to `/var/log/bootonce.log`

## Build package

From the repository root:

```bash
./build-deb.sh
```

The built package appears in `dist/`.

## Release files

A release should include:

```text
bootonce_1.5.3_all.deb
bootonce_1.5.3_SHA256SUMS.txt
```

## License

MIT. See `LICENSE`.
