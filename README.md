# bootonce

`bootonce` is a lightweight Raspberry Pi 5 and Compute Module 5 recovery helper.

It was built for field recovery workflows where a technician needs to boot once into a USB or NVMe recovery OS, repair or reflash the internal OS, and then return to the normal boot path without permanently changing the EEPROM boot order.

## What it does

`bootonce` provides one short command interface for:

* one-time USB boot override
* one-time NVMe boot override
* restoring `bootonce` into an offline OS
* preparing Raspberry Pi Connect on an offline OS
* setting hostname and basic network configuration on an offline OS
* imaging SD, eMMC, USB, or NVMe storage
* optional PiShrink post-processing

The tool is intentionally verbose by default. It prints what it is doing, which command or path is affected, and whether each step succeeded or failed.

## Why this exists

`bootonce` was built for Raspberry Pi 5 and CM5 field recovery.

The main goal is simple:

1. Boot the normal OS.
2. Set a one-time USB or NVMe recovery boot.
3. Reboot manually.
4. Repair, reflash, image, or prepare the internal OS from the recovery OS.
5. Reboot again and return to the normal boot path.

This is especially useful for CM5 systems with eMMC, remote Raspberry Pi Connect access, and recovery USB images.

## Supported devices

* Raspberry Pi 5
* Raspberry Pi Compute Module 5

## Not supported

* Raspberry Pi 4
* Raspberry Pi Compute Module 4

Raspberry Pi 4 and Compute Module 4 do not support the same clean Raspberry Pi 5 style one-time boot order override used by this tool.

## Lightweight by design

`bootonce` is intentionally small and boring.

It is a single Bash script packaged as a `.deb`.

It does not use:

* Python
* Node.js
* Docker
* a database
* a web server
* a background management service
* a custom daemon

It relies on standard Raspberry Pi OS and Linux tools instead.

The package declares normal system dependencies such as Bash, coreutils, util-linux, systemd, awk, grep, sed, findutils, and wget or curl. These are already present on most Raspberry Pi OS installations.

PiShrink is optional. If PiShrink is missing, `bootonce` can recheck, ask for a manual path, skip shrinking, or download PiShrink from the official Drewsif/PiShrink GitHub source when the user explicitly chooses that option.

Raspberry Pi Connect support requires Raspberry Pi Connect to be present in the target OS. `bootonce connect` prepares the offline OS for Connect sign-in, but it is not meant to replace the Raspberry Pi Connect package itself.

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

This is useful when you are booted into one OS, for example a recovery USB system, and want to prepare another OS installation, for example eMMC, before booting into it.

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
* organisations can have multiple active auth keys
* each device or prepared OS install needs its own unused auth key
* the target Raspberry Pi must boot and reach the internet before the key expires

Because of this, generate the auth key shortly before running `bootonce connect`.

## How to create a Raspberry Pi Connect auth key

1. Open Raspberry Pi Connect in your browser.
2. Sign in with your Raspberry Pi ID.
3. Select your personal account or organisation.
4. For a personal account, open the Settings tab.
5. For an organisation, open the Provisioning tab.
6. Find the Auth keys section.
7. Create a new auth key.
8. Copy the generated key.
9. Paste it into `bootonce connect` when asked.

Personal auth keys usually start with:

```text
rpuak_
```

Organisation auth keys may use a different prefix, for example:

```text
rpoak_
```

When `bootonce connect` asks for the auth key, the input is intentionally visible. This makes it easier for a technician to verify that the copied key is complete. The key is still redacted in logs and summaries.

## How `bootonce connect` uses the auth key

Raspberry Pi Connect can automatically detect an auth key if it is saved inside the target user profile at:

```text
.config/com.raspberrypi.connect/auth.key
```

`bootonce connect` writes the key into the selected offline OS so that Raspberry Pi Connect can consume it when that OS boots.

After the target OS boots and reaches the internet, Raspberry Pi Connect exchanges the auth key for a persistent sign-in token. The original auth key is then consumed and cannot be reused.

If the target OS does not boot and connect to the internet before the auth key expires, create a new auth key and run `bootonce connect` again.

## Example field workflow: CM5 eMMC with USB recovery OS

This is the workflow `bootonce` was originally designed for.

### Situation

* CM5 has the normal operating system on eMMC.
* A USB stick contains a Raspberry Pi OS recovery system.
* The technician wants remote recovery access through Raspberry Pi Connect.
* The technician wants to boot into USB once, work on eMMC, then return to normal eMMC boot.

### Step 1: Boot normal eMMC OS

Boot the CM5 normally from eMMC.

Install `bootonce` if it is not already installed:

```bash
cd /tmp

wget https://github.com/fishieststick/bootonce/releases/download/v1.5.3/bootonce_1.5.3_all.deb
wget https://github.com/fishieststick/bootonce/releases/download/v1.5.3/bootonce_1.5.3_SHA256SUMS.txt

sha256sum -c bootonce_1.5.3_SHA256SUMS.txt --ignore-missing

sudo apt install ./bootonce_1.5.3_all.deb
```

Check it:

```bash
sudo bootonce version
sudo bootonce doctor
```

### Step 2: Prepare the USB recovery OS

Create a fresh Raspberry Pi Connect auth key for the USB recovery OS.

Then run:

```bash
sudo bootonce connect usb
```

During the wizard:

* select or confirm the USB target
* set the recovery hostname
* paste the fresh Raspberry Pi Connect auth key
* choose DHCP or configure static networking
* optionally configure VLAN

Then restore `bootonce` into the USB recovery OS:

```bash
sudo bootonce restore
```

Select the USB OS when asked.

### Step 3: Boot once into USB recovery

Set the one-time USB boot override:

```bash
sudo bootonce usb on
```

Then reboot manually:

```bash
sudo reboot
```

The next boot goes to USB once. The normal EEPROM boot order is not permanently changed.

### Step 4: Work from the USB recovery OS

After the USB recovery OS boots and reaches the internet, it should appear in Raspberry Pi Connect.

From the USB recovery OS, the technician can now:

* inspect the eMMC OS
* repair files
* reflash eMMC
* restore `bootonce` into eMMC
* prepare Raspberry Pi Connect for eMMC
* create a backup image

Example image command:

```bash
sudo bootonce makeimage emmc
```

After the raw image is created, `bootonce` asks whether PiShrink should be used.

If PiShrink is missing, `bootonce` can:

* recheck
* ask for a manual path
* skip shrinking
* download PiShrink from GitHub if the technician chooses that option

### Step 5: Prepare the eMMC OS again

If eMMC was reflashed or repaired, create a fresh Raspberry Pi Connect auth key for the eMMC OS.

Then run:

```bash
sudo bootonce connect emmc
```

Restore `bootonce` into the eMMC OS:

```bash
sudo bootonce restore
```

Select the eMMC OS when asked.

### Step 6: Return to normal boot

Reboot manually:

```bash
sudo reboot
```

Because the USB boot was only a one-time override, the device should return to its normal boot path after the recovery boot is finished.

If the eMMC OS was prepared with a valid Connect auth key and reaches the internet before the key expires, it should appear in Raspberry Pi Connect.

## Imaging

`bootonce` can create raw images from detected storage devices.

Examples:

```bash
sudo bootonce makeimage emmc
sudo bootonce makeimage usb
sudo bootonce makeimage nvme
```

The tool refuses to image or modify the currently running root filesystem.

After creating an image, `bootonce` can optionally run PiShrink.

To shrink an existing image later:

```bash
sudo bootonce makeimage pishrink
```

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

## Project status

`bootonce` is field-tested on a real CM5 recovery workflow, but it is still a small early-stage tool.

Test carefully before using it in production environments.

## License

MIT. See `LICENSE`.
