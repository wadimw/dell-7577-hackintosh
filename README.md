# dell-7577-hackintosh

Dell Inspiron 7577 Gaming w/ i5-7300HQ, GTX 1060 Max-Q, Full HD screen (not 4K), M2 SATA SSD Crucial MX500, Intel 8265 WiFi (to be replaced), Goodix Fingerprint, 8GB RAM

Not working:
- Battery life (currently under 2 hrs, on Windows around 6 hrs)
- DGPU disable (IOReg shows power state 2 for GFX0, battery life poor so I believe it is not disabled properly)
- Sleep (Screen goes black but keyboard stays lit and laptop still seems to work)
- Touchpad works poorly (by far using VoodooPS2, will likely need to switch to VoodooI2C)
- USB 3 pendrive (Doesn't show at all in any port, however USB2 devices like keyboard, mouse, pendrive work; also Android phone in USB tethering mode works too)
- Integrated WIFI (didn't yet buy replacement card, although I apparently already have needed kexts for dw1560)
- Brightness adjustment buttons (but brightness works in settings)
- Minimum brightness is brighter than on Windows
- Screen disable on lid close
- Goodix Fingerprint (likely won't work anyway but would be wonderful if it did)

Working:
- Audio
- Keyboard
- USB 2
- Thunderbolt USB-C to HDMI dongle
- Ethernet probably (didn't check)
- Brightness adjustment (only in settings or via Karabiner shortcut)
- Internet w/ HoRNDIS or TP Link USB dongle
