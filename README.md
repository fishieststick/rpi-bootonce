# bootonce

`bootonce` is a small Raspberry Pi 5 and Compute Module 5 recovery helper.

## Why this exists

`bootonce` was built for Raspberry Pi 5 and CM5 field recovery.

The goal is to let a technician boot once into a USB or NVMe recovery OS, repair or reflash the internal OS, and then return to the normal boot path without permanently changing the EEPROM boot order.

This is especially useful for CM5 systems with eMMC, remote Raspberry Pi Connect access, and recovery USB images.

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

Raspberry Pi 4 and Compute Module 4 do not support the same clean Raspberry Pi 5 style one-time boot order override used by this tool.

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

## Raspberry Pi Connect support

`bootonce connect` prepares an offline Raspberry Pi OS installation for Raspberry Pi Connect.

This is useful when you are booted into a recovery OS and want to prepare another OS installation, for example an eMMC installation or USB recovery installation, before booting into it.

`bootonce connect` can configure:

* hostname
* Raspberry Pi Connect auth key
* DHCP or static network configuration
* optional VLAN configuration

The command can be started interactively:

```bash
sudo bootonce connect
```

Or with a target:

```bash
sudo bootonce connect emmc
sudo bootonce connect usb
sudo bootonce connect nvme
sudo bootonce connect sd
```

If no target is provided, `bootonce` asks which detected OS installation should be configured.

## Raspberry Pi Connect auth keys

A Raspberry Pi Connect auth key is a temporary key used to link a Raspberry Pi device to a Raspberry Pi Connect account without manually opening the browser sign-in flow on that device.

Important behavior:

* auth keys are single-use
* personal auth keys expire after 6 hours
* organisation auth keys can expire between 1 and 90 days
* personal accounts can only have one active auth key at a time
* each device or prepared OS install needs its own unused auth key
* the target Raspberry Pi must boot and reach the internet before the key expires

Because of this, generate the auth key shortly before running `bootonce connect`.

## How to create a Raspberry Pi Connect auth key

1. Open Raspberry Pi Connect in your browser.
2. Sign in with your Raspberry Pi ID.
3. Open the account menu or settings area.
4. For a personal account, go to the Settings tab.
5. Find the Auth keys section.
6. Select Create new auth key.
7. Copy the generated key.
8. Paste it into `bootonce connect` when asked.

The key usually starts with something like:

```text
rpuak_
```

Organisation keys may use a different prefix.

When `bootonce connect` asks for the auth key, the input is intentionally visible. This makes it easier for a technician to verify that the copied key is complete. The key is still redacted in logs and summaries.

## How `bootonce connect` uses the auth key

Raspberry Pi Connect can automatically detect an auth key if it is saved inside the target user profile at:

```text
.config/com.raspberrypi.connect/auth.key
```

`bootonce connect` prepares the selected offline OS so that Raspberry Pi Connect can consume the auth key when that OS is booted.

After the target OS boots and reaches the internet, Raspberry Pi Connect exchanges the auth key for a persistent sign-in token. The original auth key is then no longer reusable.

If the target OS does not boot and connect to the internet before the auth key expires, create a new auth key and run `bootonce connect` again.

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
