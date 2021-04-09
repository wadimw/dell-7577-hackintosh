# dell-7577-hackintosh
Now with Big Sur and OpenCore!

The repo is archived because I barely use my hack these days (though I might unarchive it one day and add updates if I get back to it).

Based on [Dortania's Guide](https://dortania.github.io/OpenCore-Install-Guide/) and my previous Clover hack.

## Attention
I advise against using my EFI directly, treat it as a reference for creating Your own. Read The Guide, manuals for every kext etc.

## Thanks
Whole hackintosh community, [@lersy](https://github.com/lersy/Dell-7577-Hackintosh-macos-Opencore)

## Info
Dell Inspiron 7577 Gaming

MacOS 11.0.1 Big Sur  
OpenCore 0.6.3

CPU: Intel Core i5-7300HQ (Kaby Lake)  
iGPU: Intel HD Graphics 630 (64MB DVMT prealloc default)  
dGPU: Nvidia GeForce GTX 1060 Max-Q  
RAM: 16GB DDR4  
Chipset: Intel HM175  
Audio: VEN_8086&DEV_A171 – Intel CM238, VEN_10EC&DEV_0256 – Realtek ALC256 (ALC3246)  
Eth: Intel RTL8168  
WiFi and Bluetooth: Lenovo Broadcomm BCM94352Z (FRU 04x6020)  
Screen: 15" FHD 60Hz  
BIOS version: 1.11.0

## Not working
- ???
- Combo Jack Headphones+Mic partially (not 100% reliably but I was pretty successful with https://github.com/hackintosh-stuff/ComboJack)
- DRM (not supported on Big Sur yet)
- Ambient Light Sensor
- USB-C/TB3 hotplug (external display over USB-C>HDMI dongle is hotpluggable though)
- SD Card reader (never will iirc)
- Fingerprint (never will)
- HDMI (but USBC works, see notes below)

## External displays
GTX 1060 version of this laptop has HDMI port wired directly to the Nvidia card, which means there is no way to use it on Mojave+. Instead, You can use e.g. an USB-C (DisplayPort)>HDMI dongle, USB-C docking station, TB3 accessories (not tested).

GTX1050(Ti) versions reportedly have HDMI port connected to iGPU however, so yes You can use it! I don't have means to test it so I won't include config for this in my repo – head over to [@lersy](https://github.com/lersy/Dell-7577-Hackintosh-macos-Opencore) instead.

## Kexts
Kext | Version | Why
--- | :---: | ---
AirportBrcmFixup.kext | 2.1.2 | Wi-Fi; for Big Sur AirPortBrcm4360_Injector.kext must be disabled
AppleALC.kext | 1.5.5 | Audio, using layout 13
BrcmBluetoothInjector.kext | 2.5.6 | Bluetooth
BrcmFirmwareData.kext | 2.5.6 | Bluetooth
BrcmPatchRAM3.kext | 2.5.6 | Bluetooth
BrightnessKeys.kext | 1.0.1 | Handles brightness up/down fn keys (instead of BRT6 patch)
CPUFriend.kext | 1.2.2 | CPU Power Management
CPUFriendDataProvider.kext | n/a | Created with fewtarius fork of CPUFriendFriend commit `ae123c0` – settings: 800MHz, balance power, bias 07, additional savings enabled
CtlnaAHCIPort.kext | 341.0.2 | SATA controller; I had "still waiting for root device" on Catalina fixed by AHCIPortInjector.kext and guide stated this kext should replace it
Lilu.kext | 1.5.0 | General
RealtekRTL8111.kext | 2.4.0d5 | Ethernet
SMCBatteryManager.kext | 1.1.9 | VirtualSMC plugin; battery
SMCLightSensor.kext | 1.1.9 | VirtualSMC plugin; ambient light sensor
SMCProcessor.kext | 1.1.9 | VirtualSMC plugin; CPU
SMCSuperIO.kext | 1.1.9 | VirtualSMC plugin; fan speed
USB-Map-Dell7577.kext | n/a | Created manually with Dortania guide; see inside kext or in journal for map details
VirtualSMC.kext | 1.1.9 | General
VoodooI2C.kext | 2.5.2 | Touchpad I2C
VoodooI2CHID.kext | 2.5.2 | Touchpad I2C
VoodooPS2Controller.kext | 2.1.9 | Keyboard; PS2 touchpad plugins disabled because it is handled by VoodooI2C
WhateverGreen.kext | 1.4.5 | Graphics

## ACPI
Prebuilt from Dortania's guide:
- SSDT-EC-USBX-LAPTOP.aml
- SSDT-PLUG-DRTNIA.aml
- SSDT-PNLF.aml

Custom:
- SSDT-GPI0-VI2C.aml – enables I2C Precision Touchpad (incorporates Dortania's SSDT-GPI0)
- SSDT-HPET.aml – Patch out IRQ Conflicts (done with SSDTTime)
- SSDT-SBUS-MCHC.aml – Enable SMBus (stock Dortania matched my hardware actually)
- SSDT-OCWork-DELL.aml – Enable brightness keys and power LED

## Pre-install
Generate Your own SMBIOS.

## Post-install
- Sleep  
```
sudo pmset autopoweroff 0
sudo pmset powernap 0
sudo pmset standby 0
sudo pmset proximitywake 0
```  
execute these commands for safety (see Dortania https://dortania.github.io/OpenCore-Post-Install/universal/sleep.html#preparations)

- ComboJack  
https://github.com/hackintosh-stuff/ComboJack to enable both headphones and their microphone.  

## Multi-booting
I do not recommend using OpenCore to boot Windows. Injection should probably be disabled for other OSes, but it still may break something. Better to use rEFInd of just BIOS F12.
