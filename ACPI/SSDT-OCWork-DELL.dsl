// https://github.com/daliansky/OC-little/ > 18-Special Patches for Brand Machines/ 18-1-Dell machine special patch
// ~Eb=nables backlight and status LED
DefinitionBlock("", "SSDT", 2, "OCLT", "OCWork", 0)
{
    External (_SB.ACOS, IntObj)
    External (_SB.ACSE, IntObj)
    
    Scope (\)
    {
        If (_OSI ("Darwin"))
        {
            \_SB.ACOS = 0x80 // To enable brightness keys
            \_SB.ACSE = 1 // ACSE=0:win7 (breathing light in sleep) ACSE=1:win8 (not breathing)
        }
    }
}
//EOF
