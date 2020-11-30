// VoodooI2C for Dell 7577 i5-7300HQ GTX1060MaxQ
// Done partially with https://github.com/jsassu20/OpenCore-HotPatching-Guide/tree/master/10-1-OCI2C-TPXX%20Patch%20Method
DefinitionBlock("", "SSDT", 2, "hack", "VI2C", 0)
{
    //GPI0
    External(GPEN, FieldUnitObj)
    External(SBRG, FieldUnitObj)
    //Touchpad
    External (_SB_.PCI0.GPI0, DeviceObj)
    External (_SB_.PCI0.I2C1, DeviceObj)
    External (OSYS, FieldUnitObj)
    External (_SB_.SRXO, MethodObj)
    External (GPDI, FieldUnitObj)
    External (_SB_.GNUM, MethodObj)
    External (_SB_.INUM, MethodObj)
    External (SDM1, FieldUnitObj)
    External (_SB_.SHPO, MethodObj)
    External (SDS1, FieldUnitObj)
    External (_SB_.GGIV, MethodObj)
    External (IPFI, FieldUnitObj)
    External (_SB_.PCI0.HIDG, IntObj)
    External (_SB_.PCI0.HIDD, MethodObj)
    External (_SB_.PCI0.TP7D, MethodObj)
    External (_SB_.PCI0.TP7G, IntObj)    
    
    Scope (\)
    {
        If (_OSI ("Darwin"))
        {
            GPEN = One // Enable GPI0 for MacOS, courtesy Dortania's SSDT-GPI0.dsl
            //SBRG = One // SSDT-GPI0 said I should use it, but with it touchpad wouldn't ever work, while without it GPI0 still works fine and Touchpad does work
            SDS1 = Zero // Disable original TPD1
        }
    }

    // Recreated touchpad device with hackintosh modifications
    Scope (_SB.PCI0.I2C1)
    {
        Device (TPXX) // Modified TPD1
        {
            Name (HID2, Zero)
            Name (SBFB, ResourceTemplate () // Root pinned
                {
                    I2cSerialBusV2 (0x002C, ControllerInitiated, 0x00061A80,
                        AddressingMode7Bit, "\\_SB.PCI0.I2C1",
                        0x00, ResourceConsumer, , Exclusive,
                        )
                })
            Name (SBFI, ResourceTemplate ()
            {
                Interrupt (ResourceConsumer, Level, ActiveLow, ExclusiveAndWake, ,, _Y2A)
                {
                    0x00000000,
                }
            })
            Name (SBFG, ResourceTemplate ()
                {
                    GpioInt (Level, ActiveLow, ExclusiveAndWake, PullDefault, 0x0000,
                        "\\_SB.PCI0.GPI0", 0x00, ResourceConsumer, ,
                        )
                        {   // Pin list
                            //0x0000 // Return (ConcatenateResTemplate (SBFB, SBFG)) present in _CRS so should be well-pinned anyway
                            0x001B // Manual pinning: APIC 0x33 > Sunrise Point GPP_B3_IRQ or GPP_F3_IRQ > B3: 27 (0x1B) or F3 : 123 (0x7B)
                        }
                })
            CreateWordField (SBFG, 0x17, INT1)
            CreateDWordField (SBFI, \_SB.PCI0.I2C1.TPXX._Y2A._INT, INT2)  // _INT: Interrupts
            Method (_INI, 0, NotSerialized)  // _INI: Initialize
            {
                /*
                If (LLess (OSYS, 0x07DC)) // Disables touchpad if less than Windows 8
                {
                    SRXO (GPDI, One)
                }
                */

                Store (GNUM (GPDI), INT1)
                Store (INUM (GPDI), INT2)
                If (LEqual (SDM1, Zero))
                {
                    SHPO (GPDI, One)
                }

                //If (LEqual (SDS1, 0x07)) // Let it work while original touchpad is disabled
                If (One)
                {
                    Store ("DELL07FB", _HID)
                    If (CondRefOf (GGIV))
                    {
                        Store (GGIV (0x01060016), Local0)
                    }

                    Store (IPFI, Local0)
                    If (LEqual (Local0, One))
                    {
                        Store ("DELL07FA", _HID)
                    }
                    ElseIf (LEqual (Local0, 0x02))
                    {
                        Store ("DELL07FB", _HID)
                    }
                    ElseIf (LEqual (Local0, 0x03))
                    {
                        Store ("DELL0802", _HID)
                    }
                    ElseIf (LEqual (Local0, 0x04))
                    {
                        Store ("DELL0803", _HID)
                    }

                    Store (0x20, HID2)
                    //Return (Zero) // Not sure why commenting this out
                }
            }

            Name (_HID, "XXXX0000")  // _HID: Hardware ID
            Name (_CID, "PNP0C50")  // _CID: Compatible ID
            Name (_S0W, 0x03)  // _S0W: S0 Device Wake State
            Method (_DSM, 4, Serialized)  // _DSM: Device-Specific Method
            {
                If (LEqual (Arg0, HIDG))
                {
                    Return (HIDD (Arg0, Arg1, Arg2, Arg3, HID2))
                }

                If (LEqual (Arg0, TP7G))
                {
                    Return (TP7D (Arg0, Arg1, Arg2, Arg3, SBFB, SBFG))
                }

                Return (Buffer (One)
                {
                     0x00                                           
                })
            }

            Method (_STA, 0, NotSerialized)  // _STA: Status
            {
                //If (LAnd (LGreaterEqual (OSYS, 0x07DC), LEqual (SDS1, 0x07)))
                If (_OSI ("Darwin")) // Enable only for MacOS
                {
                    Return (0x0F)
                }

                Return (Zero)
            }
            
            Method (_CRS, 0, NotSerialized)  // _CRS: Current Resource Settings
            {
                /*
                If (LLess (OSYS, 0x07DC))
                {
                    Return (SBFI)
                }

                If (LEqual (SDM1, Zero))
                {
                    Return (ConcatenateResTemplate (SBFB, SBFG)) // This is present originally, so it should be well-pinned
                }

                Return (ConcatenateResTemplate (SBFB, SBFI))
                */
                
                Return (ConcatenateResTemplate (SBFB, SBFG)) // As says VoodooI2C pinning guide
            }
        }
    }
}
