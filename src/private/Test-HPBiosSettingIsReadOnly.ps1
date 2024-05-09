function Test-HPBiosSettingIsReadOnly {
    <#
    .SYNOPSIS
        This function gets all HP Bios settings info or the specified bios setting.
    .DESCRIPTION
        This function gets all HP Bios settings info or the specified bios setting.
    .NOTES
        File Name      : Test-HPBiosSettingIsReadOnly.ps1
        Author         : Jack den Ouden
        Change history : 
            2024-05-09 - Initial creation
    .LINK
        https://github.com/Jackldam/HPBios
    .EXAMPLE
        PS C:\> Test-HPBiosSettingIsReadOnly -Name "USB Legacy Port Charging"
        False
    .EXAMPLE
        PS C:\> Test-HPBiosSettingIsReadOnly -Name "SureStart Production Mode"
        True
    #>
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory)]
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

    #* Read Bios CimInstance
    #region

    $BiosCimInstance = Get-CimInstance `
        -Namespace "root/hp/instrumentedBIOS" `
        -ClassName "hp_biosEnumeration" | 
    Where-Object Name -EQ $Name

    if (!($BiosCimInstance)) {
        throw "Bios setting not found, check spelling!"
    }

    #endregion

    #* Test if bios setting is read only
    #region

    $Result = ($BiosCimInstance.IsReadOnly -eq 1)

    #endregion

    #* Return result
    #region

    return $Result

    #endregion

}