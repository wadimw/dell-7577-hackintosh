/*
 * Intel ACPI Component Architecture
 * AML/ASL+ Disassembler version 20180427 (64-bit version)(RM)
 * Copyright (c) 2000 - 2018 Intel Corporation
 * 
 * Disassembling to non-symbolic legacy ASL operators
 *
 * Disassembly of iASL7nJG3T.aml, Thu Oct 10 18:12:48 2019
 *
 * Original Table Header:
 *     Signature        "SSDT"
 *     Length           0x00000122 (290)
 *     Revision         0x02
 *     Checksum         0x26
 *     OEM ID           "Andres"
 *     OEM Table ID     "AddOn"
 *     OEM Revision     0x00000000 (0)
 *     Compiler ID      "INTL"
 *     Compiler Version 0x20180427 (538444839)
 */
DefinitionBlock ("", "SSDT", 2, "Andres", "AddOn", 0x00000000)
{
    External (_SB_.PCI0, DeviceObj)    // (from opcode)
    External (_SB_.PCI0.LPCB, DeviceObj)    // (from opcode)

    Scope (\_SB.PCI0)
    {
        Scope (LPCB)
        {
            If (_OSI ("Darwin"))
            {
                Device (EC)
                {
                    Name (_HID, "EC000000")  // _HID: Hardware ID
                }
            }
        }
    }

    Scope (_SB)
    {
        If (_OSI ("Darwin"))
        {
            Device (USBX)
            {
                Name (_ADR, Zero)  // _ADR: Address
                Method (_DSM, 4, NotSerialized)  // _DSM: Device-Specific Method
                {
                    If (LNot (Arg2))
                    {
                        Return (Buffer (One)
                        {
                             0x03                                           
                        })
                    }

                    Return (Package (0x08)
                    {
                        "kUSBSleepPortCurrentLimit", 
                        0x0834, 
                        "kUSBSleepPowerSupply", 
                        0x13EC, 
                        "kUSBWakePortCurrentLimit", 
                        0x0834, 
                        "kUSBWakePowerSupply", 
                        0x13EC
                    })
                }
            }
        }
    }
}

