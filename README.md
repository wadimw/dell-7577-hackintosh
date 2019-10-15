# dell-7577-hackintosh

## System info
Dell Inspiron 7577 Gaming  
OS: macOS Catalina 10.15.0

CPU: i5-7300HQ (Kaby Lake)  
iGPU: Intel HD Graphics 630, 64MB video memory  
dGPU: Nvidia GTX 1060 Max-Q (disabled)  
Screen: 15" FHD  
Disk: M2 SATA SSD Crucial MX500  
WiFi: Lenovo Broadcomm BCM94352Z  
Bluetooth: none, hardware broken (not working under Windows as well)  
RAM: 8GB DDR4  
Audio: Realtek ALC3246  

## Not working
* Combo jack microphone (headphones and built-in mic work)
* Sensors (temperature etc.)
* Bluetooth? (may work, can't test)
* SD reader? (rather won't didn't check)
* Fingerprint scanner (3rd party don't work with Apple)

## Known issues
* After unplugging headphones loudspeakers turn back on only after ~25 seconds
* Waking from sleep sometimes causes Sleep Wake Failure panic (rarely, hard to reproduce)
* Touchpad may not work in recovery mode (acidanthera's VoodooPS2controller does not work with my touchpad and VoodooI2C HID won't work without IOGraphicsFamily, use RehabMan's VoodooPS2controller instead)

## Bootloader
[Clover v2.5k_r5093](https://github.com/Dids/clover-builder/releases)
Standard install. Drivers used:
* ApfsDriverLoader.efi
* AptioMemoryFix.efi
* HFSPlus.efi
SIP enabled.

## Kexts
All kexts injected via Clover.
* ACPIBatteryManager.kext - Battery detection, percentage
* AHCIPortInjector.kext - For "Still waiting for root device"
* AirportBrcmFixup.kext - For WiFi
* AppleALC.kext - For audio, injeect layout 13 in config
* AppleBacklightFixup.kext - For backlight control, pair with SSDT-PNLF
* BrcmFirmwareRepo.kext - For WiFi
* BrcmPatchRAM2.kext - For WiFi
* Lilu.kext - For other kexts
* RealtekRTL8111.kext - For ethernet
* USBInjectAll.kext - For USB full config, pair with SSDT-UIAC
* VirtualSMC.kext - General
* VoodooI2C.kext - For touchpad
* VoodooI2CHID.kext - For touchpad, pair with SSDT-VI2C and force load IOGraphicsFamily, may not work in Recovery/Install
* VoodooPS2Controller.kext - For keyboard. If touchpad does not work in Recovery, replace with RehabMan's
* WhateverGreen.kext - For graphics, in config inject 0x59160000

## ACPI patches
* SSDT-BRT6 - Backlight hotkeys, pair with BRTX hotpatch
* SSDT-DDGPU - Disable dGPU
* SSDT-ECUSBX - This was necessary to run Catalina, not sure what it does
* SSDT-PNLF - Backlight control
* SSDT-PRW - Prevent USB instant wake
* SSDT-UIAC - Disable unused USB ports. Note: Bluetooth port disabled here too!
* SSDT-VI2C - VoodooI2c touchpad pinning, pair with two hotpatches
* SSDT-XOSI - Fix for Darwin OS in ACPI

## Post-install
```
sudo pmset -a hibernatemode 0
sudo rm /var/vm/sleepimage
sudo mkdir /var/vm/sleepimage
sudo pmset -a standby 0
sudo pmset -a autopoweroff 0
sudo pmset -a powernap 0
```
In Energy Saver disable Power Nap, optionally disable Put hard disks to sleep, Wake for network access.