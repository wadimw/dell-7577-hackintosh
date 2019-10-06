# Work Log

In this file I will keep step by step log of what I chose to do, so I'll be able to recreate config in case of BIOS update or find errors in my reasoning if something does not work.

06-10-2019
WIP config will be tested on 16GB USB3 pendrive formatted as GPT via Disk Utility.
In the beginning following https://hackintosh.gitbook.io/-r-hackintosh-vanilla-desktop-guide/
I'll use Dids Clover v2.5k_r5093 installed from .pkg
Installation settings are defaults (UEFI only, install in ESP, ApfsDriverLoader, AptioMemoryFix, HFSPlus).
Kexts (all to EFI/Clover/kexts/Other):
* VirtualSMC.kext   1.0.7
* RealtekRTL8111.kext   2.2.2
* USBInjectAll.kext 0.7.1
* Lilu.kext 1.3.8
* AppleALC.kext 1.4.1 (previously been using layout 13 so that's for later here)
* WhateverGreen.kext    1.3.2
* AirportBrcmFixup.kext 2.0.3 (according to its Github readme https://github.com/acidanthera/AirportBrcmFixup I should also need Clover Airport Fix or further kexts. In TMac guide however there is no mention of it so perhaps it's already implemented)
* BrcmFirmwareRepo.kext and BrcmPatchRAM2.kext  2.2.10 (from this guide: https://www.tonymacx86.com/threads/broadcom-wifi-bluetooth-guide.242423/)
* VoodooPS2Controller.kext  2.0.3 (from acidanthera as it's newer than RehabMan's)
For config starting point, I'll use config_HD615_620_630_640_650.plist from RehabMan.

Tried booting, didn't work. Got "Still waiting for root device" with scrambled text. Thought it may be related to booting from USB drive, so I have moved all this WIP config to ESP partition of my SSD (and copied working one to pendrive). Tried again, same thing.
Adding new kext:
* AHCIPortInjector.kext (no version, from InsanelyMac)
IT BOOTS, omg it does. WAY sooner than expected. I got flashed with some ugly colors during Apple logo loading, also touchpad does not work but other than that I am amazed.

Since trackpad not working prevents me from checking anything else (I don't have a mouse), I'll switch to
* VoodooPS2Controller.kext  1.9.2 (RehabMan's)
at least until implementing VoodooI2C.

For now it works. Currently
Not working:
* Audio
* Backlight
* Backlight keys
* Advanced trackpad
* Lid closing - neither screen off nor sleep
* ~~dGPU disable - in IORegExp it sits under PEGP@0 (10de 1c20)~~
Working:
* Boot
* Wifi
* iGPU identifies correctly
* Graphics (werid flash no more)
* Sleep (I'm surprised)
Can't check:
* 5GHz WiFi (don't have it currently)
* Bluetooth (my card is probably broken, because it does not work on Windows too)

I will now restore my SMBIOS with Clover Configurator because it is annoying that everything is logged out. For this I will also enable Dell SMBIOS Patch in config.plist. When I'm at it, I will set audio layout to 13 (as was previously), add boot flag -wegnoegpu for dGPU disable by WhateverGreen.

Except successful SMBIOS serial number change nothing else has changed, so I'll remove the boot flag. Now to the ACPI disassembly and patching to disable the humming of fans.

By adding SSDT-DDGPU.dsl the dGPU is successfully disabled.
