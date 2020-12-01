# 2020-11-18
Dell Inspiron 7577 OpenCore Big Sur install log
Following Dortania guide.

### Hardware:
- CPU: Intel Core i5-7300HQ (Kaby Lake)
- GPU: Intel HD Graphics 630, Nvidia GeForce GTX 1060 Max-Q
- Chipset: Intel HM175 (Sunrise Point?)
- Audio: VEN_8086&DEV_A171 – Intel CM238, VEN_10EC&DEV_0256 – Realtek ALC256 (ALC3246)
- Eth: Intel RTL8168/8111
- Wifi: Broadcomm BCM4352 (Lenovo) - replaced

Going with `001-79699 - 11.0.1 macOS Big Sur` downloaded via GibMacOS. USB3 pendrive 64GB, installation created on MacOS. Drive formatted as Mac OS Extended Journaled with GUID scheme.

Downloaded OpenCore release 0.6.3. Will start with DEBUG build bc it seems logical, X64 obviously.

USB3 pendrive.

###Drivers:
Following guide religiously, removing everything butOpenRuntime.efi, then adding HfsPlus.efi.

### Tools:
Removing everything but OpenShell.efi

### Kexts:
- VirtualSMC 1.1.9 (no plugins for now)
- Lilu 1.5.0
- WhateverGreen 1.4.5
- AppleALC 1.5.5
- Realtek RTL8111 2.4.0d5
- USBInjectAll 0.7.1 (but no XHCIUnsupported)
- CtlnaAHCIPort 341.0.2
- VoodooPS2 (acidanthera) 2.1.9
these two will be added later
// - AirportBrcmFixup 2.1.2 + BrcmPatchRAM (acidanthera) 2.5.6 PatchRAM3, FirmwareData, BluetoothInjector
// - VoodooI2C 2.5.2 + VoodooI2CHID

### ACPI:
https://dortania.github.io/Getting-Started-With-ACPI/ssdt-methods/ssdt-prebuilt.html#laptop-skylake-and-kaby-lake
Using prebuilt:
- SSDT-XOSI.aml
- SSDT-PNLF.aml
- SSDT-PLUG-DRTNIA.aml
- SSDT-EC-USBX-LAPTOP.aml
Actually https://dortania.github.io/OpenCore-Install-Guide/config-laptop.plist/kaby-lake.html#starting-point says I should have SSDT-GPIO. not XOSI but for now will stick to XOSI.

### Config:
Starting with sample.plist from Docs. Using ProperTree. First "OC Clean Snapshot".

#### ACPI
/ACPI/Patch: Adding \_OSI>XOSI and removing preexisting \_Q11 and \_Q12.

#### Booter
As default.

#### DeviceProperties
Adding device PciRoot(0x0)/Pci(0x2,0x0) with ID 00001B59 and patch 0306>0105. Will try with the other patch perhaps.
Removing PciRoot(0x0)/Pci(0x1b,0x0) device because guide says to use alcid boot arg, so for now I'll follow guide.

#### Kernel
Quirks: enabling CustomSMBIOSGuid (as this is Dell). Enabling AppleXcpmCfgLock DisableIOMapper PanicNoKextDump PowerTimeoutKernelPanic XhciPortLimit (this will need to be disabled later obviously).

#### Misc
Debug: enabling AppleDebug ApplePanic DisableWatchDog and setting Target to 67. Security: enabling AllowNvramReset, AllowSetDefault, ScanPolicy to 0, SecureBootModel to Default, Vault to Optional.

#### NVRAM
7C436110-AB2A-4BBB-A880-FE41995C9F82:  
csractiveconfig left to 0. Adding bootargs debug=0x100, alcid=13 (for ALC256), -wegnoegpu. Blanking prev-lang:kbd.

#### PlatformInfo
Using SMBIOS MacBookPro14,1 (best match for my CPU) with Serial, SmUUID and Board Serial from my previous Clover install.

For Generic/ROM will use MAC address of Ethernet card: _redacted_.

#### UEFI
Enabling ReleaseUsbOwnership.

#### Sanity ckeck
After sanity check also setting UpdateSMBIOSMode to Custom.

# 2020-11-21
It boots!

Wanted to add AirportBrcmFixup 2.1.2 to enable WiFi but it seems to prevent installer from booting, getting:
```
com.apple.xpc.launchd[1] (com.apple.displaypolicyd.66) <Warning>: Service exited with abnormal code: 1
com.apple.xpc.launchd[1] (com.apple.displaypolicyd.178) <Warning>: Service exited with abnormal code: 1
ifnet_attach: All kernel threads created for interface en0 have been scheduled at least once. Proceeding.
_dlil_attach_flowswitch_nexus: en0 900 1500
IOKit Daemon (kernelmanagerd) stall[0], (240s): 'PXSX'
com.apple.xpc.launchd[1] (com.apple.displaypolicyd.179) <Warning>: Service exited with abnormal code: 1
```
according to https://github.com/acidanthera/AirportBrcmFixup AirportBrcmFixup.kext/Contents/PlugIns/AirPortBrcm4360_Injector.kext should not be injected on Big Sur, so I changed its entry to disabled and it boots again! Seems it needs to be done every time I run Clean Snapshot in properTree.

Wanting to remove old data from NVRAM, re-adding CleanNvram.efi Tool.

~~Neither builtin KB nor Touchpad seem to work, so for installation I'll use USB.~~ Installation was successful. It also seems iMessage and others work off the bat if You set SMBIOS correctly prior to installation (which I was hoping for as it did previously).

Audio works for now, GPU accelerations works.

# 2020-11-22
First thing to fix would be KB+M, but it seems I'm just dumb and didn't copy over the kext earlier.

Going through post install from the top.

## Universal

### FileVault
PollAppleHotKeys true, AuthRestart true, UIScale left at 01 because for now scale seems ok, KeySupport true, ProvideConsoleGop true, FirmwareVolume true, RequestBootVarRouting true.

### Vault
later.

### ScanPolicy
Leaving it at default because I think booting different sources  will be done only from BIOS.

### Apple Secure Boot
Seems cool but I'm not interested for now.

### Fixing audio with AppleALC
Speakers and internal mic work just fine, combo jack don't (both headphones and mic). lersy/Dell-7577-Hackintosh-macos-Opencore uses layout 21, on it the headphones work but after unplugging them speakers don't switch back for some time (2 min or so), also combo jack mic does not work either. In general it seems there are all the same issues that I had earlier with Clover so I might get back to it later but I don't care for now. I'll keep layout 13 and move it from bootarg to deviceproperty.

### Moving OpenCore from USB to macOS Drive
Later

### Fixing DRM support and iGPU performance
Not supported on Big Sur yet

### Fixing iMessage and other services with OpenCore
iMessage apparently allows me to log in to my account, but then kicks me out after 10s or so. Will fix it one day probably.

### Optimizing Power Management
X86PlatformPlugin works. Adding kext CPUFriend 1.2.2 and using CPUFriendFriend by fewtarius with settings: 800MHz, Balance power and Bias 07. 

### Fixing USB
Using USBMap tool and plugging in USB3 pendrive and USB2 mouse. Turns out USB-C port does not work yet for some reason though I just checked on Clover Mojave/Catalina I didn't map it in SSTD-UIAC either so it probably is disabled elsewhere. Removing USBInjectAll kext and disabling port limit patch XhciPortLimit.

## Bluetooth
Now with USB fixed I can add Bluetooth kexts: BrcmPatchRAM (acidanthera) 2.5.6 PatchRAM3, FirmwareData, BluetoothInjector.

## Battery and other sensors
Last time battery worked well with SMC plugin, so now adding all plugin kexts as well: SMCBatteryManager.kext SMCDellSensors.kext SMCLightSensor.kext SMCProcessor.kext SMCSuperIO.kext. Battery sensor works (though it says Service Recommended), ALS does not seem to work (no option in Display preferences). IntelPowerGadget works.

## Sleep
Checked, sleep works for now.

## Trackpad
Following https://dortania.github.io/Getting-Started-With-ACPI/Laptops/trackpad-methods/manual.html
First getting rid of XOSI aml and rename. Adding kexts VoodooI2C and VoodooI2CHID, disabling trackpad kexts from VoodooPS2.

Creating SSDT-GPI0-VI2C with GPEN and SBRG set to One as in SSDT-GPI0 from guide (instead of renaming and reimplementing GPI0 \_STA).
Instead of hotpatching TPD1 as it was done in Clover, following https://github.com/jsassu20/OpenCore-HotPatching-Guide/tree/master/10-1-OCI2C-TPXX%20Patch%20Method and lersy/Dell-7577-Hackintosh-macos-Opencore to create a second Touchpad ACPI device and disable the first one.

First copied over whole TPD1 device from my disassembled DSDT and renamed it to TPXX. Then - because original \_STA method returns 0x0F only when SDS1 equals 0x07, added `SDS1 = Zero` next to GPEN and SBRG enables. Then patched TPXX.\_STA to return 0x0F on\_OSI(Darwin), \_INI to not rely on SDS1 anymore (also disabled OSYS<Win8 check and final Return (Zero) - though with the latter I don't actually know why), finally implemented old patches: SBFG pin set to 0x1B (APIC 0x33 > Sunrise Point GPP_B3_IRQ > B3: 27 (0x1B)) and \_CRS to always Concatenate SBSB, SBFG. All of that didn't work until I removed `SBRG = One` – without it GPI0 still works fine and the touchpad finally works as well.

# 2020-11-24
I got a few kernel panics from SMCDellSensors. I don't need it anyway so I'm gonna disable it for now. Also found out that (same as before) intermittently I don't have audio – will try out with alc delay 1s. Also I have an intermittent issue where when I click with a touckpad, it acts like I clicked with three fingers somehow. Also I'd like to move most bootargs to Device properties instead, so I will push -wegnoegpu out.

Added alc-delay 1000 property to Audio device. Added disable-external-gpu 1 property to iGPU device.

Also removed CleanNvram.efi Tool because OpenCore does that itself.

USB-C port does not work (tested with C>3x3.1A+HDMI Hub, USB-C>HDMI adapter and Samsung C>A 3.0 adapter), neither does external display over it. However, when with device plugged in the device is visible in system. After unplugging and re-plugging the device it does not work anymore though. Interetingly (or not), when plugging any device to USB-C port Touchpad hangs for a moment. No devices get added/removed in IORegExp tho.

Reverting to USBInjectAll and trying to figure out proper mapping.
It gets better: the USBC device can be replugged successfully until the USBC>A adapter is not unplugged. Additionally, there are multiple XHC controllers so they need unique renaming due to how USBMap looks for controllers (by name).

In the meantime, I'm updating BIOS from 1.8.0 to 1.11.0 so that I won't make too many patches in vain. Will need to re-extract SSDT etc. Fortunately, it seems to work fine after update. TPD1 devide in DSDT did not change, so my custom patch does not need changing.

# 2020-11-26
I did the manual mapping for both controllers.

/\_SB/PCI0@0/XHC@140000 (Intel xHCI controller, USB-A ports)
- USB2 (type 0): `HS01` Left, `HS02` Far Right, `HS03` Near Right
- Internal (type 255): `HS04` Bluetooth, (`HS08` Fingerprint disabled), `HS12` Webcam
- USB3 (type 3): `SS01` Left, `SS02` Far Right, `SS03` Near Right

/\_SB/PCI0@0/RP01@1c0000/PXSX@0/TBDU@20000/XHC@0 (Alpine Ridge 2C 2016 JHL6340 TB3 controller, USB-C)
- USB-C +sw (type 9): `HS01` both sides USB2, `SS01` both sides USB3

The mapping works, but doesn't solve my issue with no hot-plug, disappearing and no video on USB-C plug. Did also try using USBInjectAll+SSDT-UIAC from my old Clover but it did not solve the issue either.

With SSDTTime ran `FixHPET - Patch out IRQ Conflicts` (option C to omit conflicting legacy IRQs).

Also adding support for SMBUS.

Finally fixed external display by copying over my old settings from Clover. Apart from accidental whitespace in property keys (removal of which didn't help), I added device-id 16590000 and hda-gfx onboard-1. After that external display over USB-C dongle works, and even is hotpluggable! (Even though XHC for the USBC still does not enumerate in system and behaves like earlier – I'm not so sure anymore if the USB part of the plug ever worked correctly. This is TB3 Alpine Ridge controller which seems to cause massive pain in the hackintoshers asses https://dortania.github.io/OpenCore-Post-Install/universal/sleep.html#fixing-thunderbolt so I don't know if I'll ever try to fix that). This also meant, that USPMap kext would work mainly ok (though it did try to remap the other controller as well, so the manually created version is better).

Todos:
- fix imessage
- consider fixing USBC

Brightness keys are now handled by acidanthera's kext as per OpenCore guide. To get them running \_SB.ACOS must be set to 0x80 so that they even work.

Tried USB-C 3.1 Hub and it seems that when plugged before reboot, the bus works with full speed. Power LED behaves as on Windows regardless of setting \_SB.ACSE - it is on only when laptop is plugged in, always off otherwise.

Disabling OpenCore BootProtect so it won't keep snatching the first position in boot order (I mainly use Windows).
