# dell-7577-hackintosh

Dell Inspiron 7577 Gaming w/ i5-7300HQ, GTX 1060 Max-Q, Full HD screen (not 4K), M2 SATA SSD Crucial MX500, ~~Intel 8265 WiFi (to be replaced)~~ Broadcomm BCM94352Z, Goodix Fingerprint, 8GB RAM

Installed: Mojave 10.14.3 + Windows 10

Not working:
- Headphones, they act like they are not fully plugged
- Brightness adjustment buttons (but brightness works in settings)
- ~~Battery life (currently under 2 hrs, on Windows around 6 hrs)~~ After successful dGPU disable about 4hrs
- ~~DGPU disable (IOReg shows power state 2 for GFX0, battery life poor so I believe it is not disabled properly)~~ Removing bunch of DSDT fixes from config.plist helped (these removed should be checked tho, I don't know what they did)
- ~~Minimum brightness is brighter than on Windows~~ Same thing as above apparently fixed the issue
- ~~Sleep (Screen goes black but keyboard stays lit and laptop still seems to work)~~ Sleep apparently works as well. No problems encountered. It takes about 30 seconds to sleep completely but apparently it is normal for macOS. Wakes only on power button.
- ~~Touchpad works poorly (by far using VoodooPS2, will likely need to switch to VoodooI2C)~~ Implemented VoodooI2C, works. ~~It likely uses polling though, and double tap and drag does not work for some reason.~~ Now it works like a charm using interrupts. Probably drag was not working because of polling intermittently "dropping" finger hold (that is just a guess tho).
- ~~USB 3 pendrive (Doesn't show at all in any port, however USB2 devices like keyboard, mouse, pendrive work; also Android phone in USB tethering mode works too)~~ USB3 works now
- ~~Integrated WIFI (didn't yet buy replacement card, although I apparently already have needed kexts for dw1560)~~ Bought Lenovo PN:20-200480 (Broadcomm BCM94352Z) and it works (needed Lenovo drivers on Windows)
- ~~Screen disable on lid close~~ apparently it was fixed somewhere along the line, probably when removed those excessive DSDT fixes
- Goodix Fingerprint (likely won't work anyway but would be wonderful if it did)

Working: Basically everything
- Audio
- Keyboard
- USB 2, 3
- Thunderbolt USB-C to HDMI dongle
- Ethernet ~~probably (didn't check)~~ for sure
- Brightness adjustment (only in settings or via Karabiner shortcut)
- Internet: WiFi or HoRNDIS
- DGPU Disable
- Sleep
