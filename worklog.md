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
