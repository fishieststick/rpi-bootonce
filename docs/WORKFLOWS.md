# bootonce workflows

## Prepare USB recovery OS from eMMC

```bash
sudo bootonce connect
sudo bootonce restore
sudo bootonce usb on
sudo reboot
```

## Prepare eMMC from USB recovery OS

```bash
sudo bootonce connect
sudo bootonce restore
sudo reboot
```

## Create and optionally shrink an image

```bash
sudo bootonce makeimage emmc
```

After the raw image is created, bootonce asks whether PiShrink should be used.

## Shrink an existing image

```bash
sudo bootonce makeimage pishrink
```

If PiShrink is missing, bootonce can recheck, ask for a path, skip, or download PiShrink from the official Drewsif/PiShrink GitHub source.
