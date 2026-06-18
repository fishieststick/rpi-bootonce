# bootonce commands

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

Common options:

```text
--yes                Skip confirmations
--dry-run            Show what would happen, change nothing
--quiet              Print less output
--target <partition> Advanced manual target override
--user <name>        Connect target user override
--key-file <file>    Connect auth key from file
--output <folder>    Image output folder
--name <image-name>  Image name
```
