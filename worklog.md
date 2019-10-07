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
* ~~Audio~~ Headphones
* ~~Backlight~~
* Backlight keys
* ~~Advanced trackpad~~
* ~~Lid closing - neither screen off nor sleep~~
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

Now on to implementing VoodooI2C. First emulate Windows by hotpatching DSDT (_OSI -> XOSI) and adding SSDT-XOSI.dsl. Then add two kext pathes for AppleIntelI2C. Instead of patching whole DSDT I'll be hotpatching:
So hotpatch rename _CRS to XCRS and _STA to XSTA.
To do that, I must target method definition (as here https://www.tonymacx86.com/threads/guide-using-clover-to-hotpatch-acpi.200137/ in Rename and Replace). I have generated mixed listing of DSDT, found _SB.PCI0.I2C1.TPD1._CRS at 34640 FEAA as 14 33 5F 43 52 53 00 with further body A0 0E 95 4F 53 59 53 0B DC 07 (.3_CRS....OSYS...). I wish to replace it to XCRS, so it should be 14 33 58 but I'll skip 14 33 (method definition and method length) and add some body instead. Thus replacing 5F 43 52 53 00 A0 0E 95 (_CRS....) with 58 43 52 53 00 A0 0E 95 (XCRS....).
It turns out it won't work because three methods start with
Method (_CRS, 0, NotSerialized) { If (LLess (OSYS, 0x07DC))
So I won't be able to distinguish them by hotpatching. I will use normal DSDT patch instead.
Change manually GPIO._STA to always return 0x0F, TPD1 SBFG pin list to 0x1B and TPD1._CRS to always concatenate SBFB and SBFG.
Finally add:
* VoodooI2CHID.kext 2.2
* VoodooI2C.kext    2.2
This however once again causes VoodooPS2 Keyboard to not work, so I am replacing it back with  
* VoodooPS2Controller.kext  2.0.3 (from acidanthera)
Both keyboard and touchpad (with all gestures) work after that. 

02-10-2019
For backlight fix I will be using
* AppleBacklightFixup.kext  1.0.2
with its SSDT-PNLF.aml. It works right away.
For battery
* ACPIBatteryManager.kext   1.90.1
Audio: I will follow https://github.com/acidanthera/AppleALC/wiki/Installation-and-usage
First I'll change Audio>Inject to NO (String). Second, ./gfxutil -f HDEF outputs DevicePath = PciRoot(0x0)/Pci(0x1f,0x3). In config.plist there already is such device, so I'll uncomment #layout-id and set it to 13 as this was used before.
Aaand there it is, both work right away. Microphone works as well, only headphones don't.
Ok so what's cool is that lid closing works now, I suppose that may be either beacuse of BatteryManager or BacklightFixup. Anyway the screen disables, the laptop goes to sleep (after about 30 seconds), after opening it wakes back. Audio still works after wakinng, no panics, no nothing.
However, now with lid open it wakes up immediately after sleeping "by hand" (Menu>Sleep). This may perhaps be caused by USB?

For now only things left to do (that I can think of) are:
* USB
* Instant wake with lid open (perhaps with closed too, only it's not visible due to display disabled)
* Native Power Management for extra battery life
* Backlight hotkeys, this one actually triggered the whole rebuilding process
* Headphones (sound + mic possibly?)
After that only cosmetic changes - hide Recovery, add dark theme for Clover, re-enable SIP

