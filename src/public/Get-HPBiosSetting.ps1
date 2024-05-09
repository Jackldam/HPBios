function Get-HPBiosSetting {
    <#
    .SYNOPSIS
        This function gets all HP Bios settings info or the specified bios setting.
    .DESCRIPTION
        This function gets all HP Bios settings info or the specified bios setting.
    .NOTES
        File Name      : Get-HPBiosSetting.ps1
        Author         : Jack den Ouden
        Change history : 
            2024-05-09 - Initial creation
    .LINK
        https://github.com/Jackldam/HPBios
    .EXAMPLE
        PS C:\> Get-HPBiosSetting


        DisplayInUI              : 1
        IsReadOnly               : 0
        Name                     : Virtualization Based BIOS Protection
        Path                     : \Security\Utilities\Sure Option ROM
        Prerequisites            : {SELECT * FROM HP_BIOSEnumeration WHERE Name='Virtualization Technology (VTx)' AND CurrentValue = 'Enable'}
        PrerequisiteSize         : 1
        RequiresPhysicalPresence : 0
        SecurityLevel            : 0
        Sequence                 : 22010
        Value                    : Disable,*Enable
        CurrentValue             : Enable
        PossibleValues           : {Disable, Enable}
        Size                     : 2
        Active                   : True
        InstanceName             : ACPI\PNP0C14\1_29
        PSComputerName           :

        DisplayInUI              : 1
        IsReadOnly               : 0
        Name                     : Virtualization Based BIOS Protection Manual Recovery
        Path                     : \Security\Utilities\Sure Option ROM
        Prerequisites            :
        PrerequisiteSize         : 0
        RequiresPhysicalPresence : 0
        SecurityLevel            : 0
        Sequence                 : 22020
        Value                    : *Disable,Enable
        CurrentValue             : Disable
        PossibleValues           : {Disable, Enable}
        Size                     : 2
        Active                   : True
        InstanceName             : ACPI\PNP0C14\1_30
        PSComputerName           :
    .EXAMPLE
        PS C:\> Get-HPBiosSetting -Name "System Management Command"

        
        DisplayInUI              : 1
        IsReadOnly               : 0
        Name                     : System Management Command
        Path                     : \Security\Utilities\System Management Command
        Prerequisites            : {SELECT * FROM HP_BIOSPassword WHERE Name='Setup Password' AND IsSet=1}
        PrerequisiteSize         : 1
        RequiresPhysicalPresence : 0
        SecurityLevel            : 0
        Sequence                 : 18010
        Value                    : Disable,*Enable
        CurrentValue             : Enable
        PossibleValues           : {Disable, Enable}
        Size                     : 2
        Active                   : True
        InstanceName             : ACPI\PNP0C14\1_0
        PSComputerName           :
    #>

    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $Name
    )

    #* Test if manufacturer is HP if not return
    #region

    if (!(Test-HPManufacturer)) {
        throw "Manufacturer is not HP!"
        return
    }

    #endregion
        
    #* Get all bios settings
    #region

    $Result = Get-CimInstance `
        -Namespace "root/hp/instrumentedBIOS" `
        -ClassName "hp_biosEnumeration" | 
    Sort-Object Path, Name

    #endregion

    #* Filter and return results
    #region

    # If name is passed trough Name parameter show only that setting
    if (($null -ne $Name) -and ("" -ne $Name)) {
        $Result = $Result | Where-Object Name -Like $Name
    }

    # Return result
    return $Result

    #endregion

}