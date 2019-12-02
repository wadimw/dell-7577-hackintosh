# dell-7577-hackintosh

If You want to use this repo for Your laptop, keep in mind that:
* In actual Clover/ACPI/Patched there should be .aml files, not .dsl; You need to compile each into .aml using MaciASL
* You need to place actual drivers and kexts into Clover/drivers and Clover/kexts/Other; It's best to download kexts from their developers in the newest version.
* example.config.plist does not contain full SMBIOS information, so that You won't use my serials. Rename it to config.plist, open with Clover Configurator, re-select SMBIOS and generate new serials [etc](https://www.tonymacx86.com/threads/an-idiots-guide-to-imessage.196827/). You can obviously skip that, but then You won't be able to use iMessage etc.

According to some, this config works properly with i7 configs as well as 1050. I don't know if it will for You, try it.

I am attaching my ready Clover folder under Releases. Note however that I advise against ever using whole config blindly - in particular You should always download all kexts directly from their developers and use latest available versions.

## System info
Dell Inspiron 7577 Gaming  
OS: macOS Catalina 10.15.0

CPU: i5-7300HQ (Kaby Lake)  
iGPU: Intel HD Graphics 630 (64MB DVMT prealloc default)  
dGPU: Nvidia GTX 1060 Max-Q (disabled)  
Screen: 15" FHD  
Disk: M2 SATA SSD Crucial MX500  
WiFi and Bluetooth: Lenovo Broadcomm BCM94352Z (FRU 04x6020)  
RAM: 16GB DDR4  
Audio: Realtek ALC3246  

## Not working
* Combo jack microphone and headphones (built-in mic works; headphones technically do work with layout 21 but after unplugging them, speakers sometimes don't get back up. You can use it with boot arg alcid=21)
* Sensors? (temperature etc. I have some kexts in place but I don't really check that on macOS anyway so idk if they work)
* SD reader? (rather won't didn't check)
* Fingerprint scanner (3rd party don't work with Apple)

## Known issues
* (Only on layout-id 21) After unplugging headphones loudspeakers turn back on only after ~25 seconds
* Touchpad may not work in recovery mode (acidanthera's VoodooPS2controller does not work with my touchpad and VoodooI2C HID won't work without IOGraphicsFamily, use RehabMan's VoodooPS2controller instead)

## BIOS
* SATA mode - AHCI
* Secure Boot - disabled
* Virtualization - both **not disabled** and they don't cause issues for me

## Bootloader
[Clover v2.5k_r5099](https://github.com/Dids/clover-builder/releases)
Standard install. Drivers used:
* ApfsDriverLoader.efi
* AptioMemoryFix.efi
* HFSPlus.efi
* VirtualSmc.efi
SIP enabled (0x00).

## Kexts
All kexts injected via Clover.

* AHCIPortInjector.kext - For "Still waiting for root device"
* AirportBrcmFixup.kext - For WiFi
* AppleALC.kext - For audio, inject layout 13 in config
* AppleBacklightFixup.kext - For backlight control, pair with SSDT-PNLF
* BrcmBluetoothInjector.kext - Bluetooth
* BrcmFirmwareData.kext - Bluetooth
* BrcmPatchRAM3.kext - Bluetooth
* Lilu.kext - Framework for other kexts
* RealtekRTL8111.kext - For ethernet
* SMCBatteryManager.kext - Battery detection, percentage
* SMCProcessor.kext - Processor sensors, didn't really check if they work
* SMCSuperIO.kext - IO sensors, didn't really check if they work
* USBInjectAll.kext - For USB full config, pair with SSDT-UIAC
* VirtualSMC.kext - General
* VoodooI2C.kext - For touchpad
* VoodooI2CHID.kext - For touchpad, pair with SSDT-VI2C and force load IOGraphicsFamily, may not work in Recovery/Install
* VoodooPS2Controller.kext - For keyboard. If touchpad does not work in Recovery, replace with RehabMan's
* WhateverGreen.kext - For graphics

## ACPI patches
* SSDT-BRT6 - Backlight hotkeys, pair with BRTX hotpatch
* SSDT-DDGPU - Disable dGPU
* SSDT-ECUSBX - This was necessary to run Catalina, not sure what it does
* SSDT-PNLF - Backlight control
* SSDT-PRW - Prevent USB instant wake
* SSDT-UIAC - Disable unused USB ports
* SSDT-VI2C - VoodooI2C touchpad pinning, pair with two hotpatches
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
