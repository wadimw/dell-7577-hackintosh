# Work Log

In this file I will keep step by step log of what I chose to do, so I'll be able to recreate config in case of BIOS update or find errors in my reasoning if something does not work.

## 06-10-2019
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
* ~~Backlight keys~~
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

## 07-10-2019
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
* ~~USB~~
* ~~Instant wake with lid open (perhaps with closed too, only it's not visible due to display disabled)~~
* ~~Native Power Management for extra battery life~~
* ~~Backlight hotkeys, this one actually triggered the whole rebuilding process~~
* Headphones (sound + mic possibly?)
~~After that only cosmetic changes - hide Recovery, add dark theme for Clover, re-enable SIP~~

For USB I already have UsbInjectAll, so I'll apply SSDT-UIAC.dsl I have previously done by myself. This works beautifully also fixing Instant Wake issue as expected.
For backlight buttons, following this comment https://www.tonymacx86.com/threads/guide-patching-dsdt-ssdt-for-laptop-backlight-control.152659/post-1773229 I'll first enable OSID>XSID rename, then add BRT6>BRTX rename and SSDT-BRT6.dsl from https://github.com/Nihhaar/Hackintosh-Dell-7567 
And here it is, after almost a year of using my hack I can finally use my normal backlight buttons instead of shitty Karabiner remaps which always left me confused after switching back to Windows. All that time, simply because I didn't understand that BRT6 dsl needed pairing with BRT6 rename hotpatch.

## 08-10-2019
On Nihhaar's Github I have also spotted a hotpatch for VoodooI2C (and a .dsl obviously) which uses TgtBridge, I need to look into that.

In RehabMan's guide for Power Management https://www.tonymacx86.com/threads/guide-native-power-management-for-laptops.175801/ first thing is disabling hibernation by  
sudo pmset -a hibernatemode 0  
sudo rm /var/vm/sleepimage  
sudo mkdir /var/vm/sleepimage  
sudo pmset -a standby 0  
sudo pmset -a autopoweroff 0  
sudo pmset -a powernap 0  
So I'll do that. Later there is "Note: If you followed the guide linked above, and you have a Haswell or later CPU, there is nothing for you to do here, as CPU PM is already enabled with the plists provided by the guide." and also "In order to use HWP, use an SMBIOS that is enabled for HWP... currently MacBook9,1, MacBookPro13,x (and now MacBookPro14,x, MacBookPro15,x). Also, since HWP tends to cause the xcpm_idle to be invoked, make sure the xcpm_idle patch (courtesy of PikeRAlpha) is enabled. It is default in all current plists provided by my Clover laptop guide." so I guess there is nothing more to do with that.

Now re-enabling SIP (CsrActiveConfig 0x67>0x00) because I'm going to inject kexts only via C/k/O. Added VM and Recovery to hide, set the theme to clover minimal dark.
That would be it. Apparently only thing left are headphones which I don't use often on Hack so I will get to them some day probably.

I applied VoodooI2C hotpatch from Nihhaar and removed patched DSDT. It works too so I'll keep it this way.
Except from headphones one more thnig to do could be fixing sensors (temperature).

It turns out that sadly hotplugging Thunderbolt>HDMI adapter causes system to panic, and after reboot adapter does not work anyway. It did in previous config (even hotplugging) so I need to investigate.

## 09-10-2019
Looks like spoofing GPU to be from Skylake rather than KabyLake fixes the issue (idea from here https://www.tonymacx86.com/threads/readme-common-problems-and-workarounds-on-10-14-mojave.255823/). I don't know if there is any other way to fix that, so I'll use what works for now at least. Also worth noting, that system information reports only 24-bit color depth on built-in display (without spoofing it reported 30) and 30 on external display. I don't see much of a difference except for the fact, that shadows on builtin are not banded anymore (they were before spoofing).

https://www.tonymacx86.com/threads/faq-read-first-laptop-frequent-questions.164990/ is it really set to 32MB now? This may be the culprit.

I have also noticed that I still have trouble with USB Instant Wake (which didn't manifest earlier due to not having stuff plugged I guess).
Todos for now:
* ~~USB instant wake~~
* Headphones
* Temperature sensors

I have tried installing Catalina. To even boot the installer, I needed to add SSDT-ECUSBX.dsl (don't know what does it do, will need to look into that). With it the installation worked fine, I have done a clean install. It turns out however, that VoodooI2CHID stopped loading. Thanks to ben9923 from VoodooI2C Gitter I have found out that to make it work I need to add IOGraphicsFamily.kext to ForceKextsToLoad (also invalidating system kext cache might be important here as well, others report that neither helps but copying IOGF to C/k/O does help in the end).

With that set Catalina works fine. There is however another issue with graphics - with external monitor plugged in, wallpaper on internal display gets ever so slightly misaligned leaving a black bar on the right side. This may not be an issue, but it's a bit annoying and proves that graphics is not fixed up correctly after all.

Meanwhile I've added USB instant wake fix pulled from Nihhaar's repo. It works properly, laptop does not wake immediately after sleeping anymore.

## 11-10-2019
After some poking around and reading I have discovered two things: 1) this laptop apparently has 64MB of DVMT prealloc (according to BIOS info), so there is no need to patch framebuffer into 32MB 2) I can use KBL framebuffer. Caveat is that when injecting 0x591B0000 (default Kaby Lake laptop id according to https://www.tonymacx86.com/threads/guide-intel-framebuffer-patching-using-whatevergreen.256490/ which is I think equal to not injecting at all) the system will panic when plugging external HDMI display via USB-C (with dongle). It works great with desktop's 0x59160000 though, so I'll stick with it instead of spoofing older Skylake id. I don't see much (any?) of a difference anyway. Wallpaper on laptop display is misaligned either way so I guess this may be Catalina bug, not a hackintosh one.

I have noticed that with current setting of kb/touchpad kexts (acidanthera's VoodooPS2controller and VoodooI2C+HID in C/k/O) touchpad does not work in Recovery (and so probably in USB installer), so to fix it I suppose I might replace VoodooPS2 to RehabMan's, however currently I don't need it anad would rather have a newer kext handle my keyboard on normal boot (especially since RehabMan's intemittently fails to work at all for a few boots).

## 14-10-2019
After some random issues I've decided to go back to spoofing Skylake Laptop card, olny this time without patching framebuffer size. I'll see how it goes.

Headphones: I'm testing ALC3246 layouts one by one (from https://github.com/acidanthera/applealc/wiki/supported-codecs). 5, 11, 13, 14: Only speakers work. 21 - headphones work as well, cleanly. Line-in microphone gets detected, but only picks fuzz. 22, 28 don't at all. 56 only speakers work. 57 speakers don't, headphones do, line in detected but only fuzz. 66 both speakers and headphones do work, but mic doesn't, also internal mic stops working. 97 speakers don't work, plugging headphones caused audio to crash (crossed sign).

It turns out though that with layout 21 after unplugging headphones speakers start to work after quite some time, about 25 seconds. It's still the best I have for now. I have also discovered that clamshell mode works. It also turns out, that going back to SKL does not really solve Sleep Wake Failure panics. It is however hard to reproduce this issue so I might just stick with it.

## 16-10-2019
Unplugging external monitor sometimes causes WindowServer to crash, so going back to Kaby Lake Desktop graphics id (which was working good on mojave). Will try to patch stuff according to this https://www.tonymacx86.com/threads/guide-intel-igpu-hdmi-dp-audio-all-sandy-bridge-kaby-lake-and-likely-later.189495/

So I have restored default RehabMan's patches to iGPU, then disabled 32MB memory patching. After some poking it turned out that patching 0105 instead of 0306 allows me to use 0x591b0000 and work with external monitor, no panics (don't know about WindowServer crashes or Sleep Wake Failures yet). Audio over it works as well. Sadly, with layout 21 unplugging headphones did not turn speakers back on anymore, so I'll do testing again:
```
ID  Speakers    Headphones  Sp. restore HDMI Audio  Built-in Mic    Headphone Mic
5   ok          no          ok          ok          no              no
11  ok          no          ok          ok          ok              no
13  ok          no          ok          ok          ok              no
14  ok          no          ok          ok          ok              no
21  ok          ok          no          ok          ok              no
22  no          no          ok          ok          no              no
28  ok          crackle     ok          ok          no              no
56  ok          no          ok          ok          ok              no
57  no          ok          no          ok          ok              no
66  ok          ok          delayed     ok          no              no
97  no          no          no          no          no              no
```
With that tested, I'm going back to 13 because I'd rather not need to reboot every so often to get my speakers back. I am setting layout id via boot arguments now in case I really need heacphones.

## 01-12-2019
Well it turns out that I brought my card's Bluetooth back to life! (by unplugging both main and CMOS battery and pressing Power a few times) In Windows it works but on macOS doesn't - so time to patch it. First obviously time to update all kexts.

* Update Clover to r5099 from Dids.
* AirportBrcmFixup to 2.0.4
* AppleALC to 1.4.3
* Lilu to 1.3.9
* VirtualSMC to 1.0.9 (also worth noting that along the way I decided to replace ACPIBatteryManager with SMCBatteryManager and add SMCProcessor SMCSuperIO. I now will also add VirtualSmc.efi to Drivers)
* VoodooPS2Controller to 2.0.4 (acidanthera's)
* WhateverGreen to 1.3.4

Now on to enabling Bluetooth. First of all, it is disabled in USBInjectAll configuration. After using -uia_ignore_rmcf it seems that it sits on HS04. This does not enable it yet in macOS, so following https://github.com/RehabMan/OS-X-BrcmPatchRAM readme replace BrcmFirmwareRepo to BrcmFirmwareData as I'm injecting everything from C/k/O. This didn't help too. Now removing BrcmFirmwareData.kext and BrcmPatchRAM2.kext completely. https://www.insanelymac.com/forum/topic/339175-brcmpatchram2-for-1015-catalina-broadcom-bluetooth-firmware-upload/ This may solve the issue later.

Turns out there is now BrcmPatchRAM3.kext maintained by acidanthera https://github.com/acidanthera/BrcmPatchRAM. Copied over 
* BrcmBluetoothInjector.kext 2.5.0
* BrcmFirmwareData.kext 2.5.0
* BrcmPatchRAM3.kext 2.5.0
Aaaaaaand it works! Tested on my AirPods. Won't test Continuity etc because I don't have any Apple devices.

# 05-12-2019
I will get around to fix combo jack some day. This repo https://github.com/hackintosh-stuff/ComboJack worked for me togeether with layout 13, but I don't consider it an elegant solution so I removed it for now.

Today I've also discovered that with dock Dell WD15 the third display is a copy of second (first being laptop's internal display). This is not the case on Windows where it works correctly, so I assume it's a problem with my graphics config.

I have also removed AppleBacklightFixup.kext because I've found out it's superceded by WhateverGreen (integrated into it).

# 06-12-2019
I have finally got around to investigate SSDT-ECUSBX.dsl and it turns out Catalina apparently needs \_SB\_.PCI0.LPCB.EC so instead of emulating it (as did this file) I have enabled ECDV>EC rename in config.plist and it seems to work well. I don't see any issues now, but for future reference https://www.tonymacx86.com/threads/guide-usb-power-property-injection-for-sierra-and-later.222266/ here is the guide for USBX stuff in case I need it.

I will soon test again all available layouts for ALC256. Meanwhile updated
* AppleALC.kext to 1.4.4
* Lilu.kext to 1.4.0
* WhateverGreen.kext to 1.3.5
I am also not sure what changed but HDMI audio isn't listed anymore, come to think of it - for quite some time actually.

# 11-12-2019
Reading AppleALC wiki page, I found out they recommend disabling HDAS->HDEF patch so I've disabled it.