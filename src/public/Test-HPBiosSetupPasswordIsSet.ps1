function Test-HPBiosSetupPasswordIsSet {
    <#
        .SYNOPSIS
        Get-HPBiosPassword allows you to check if the bios password has been set or not

        .DESCRIPTION
        Get-HPBiosPassword allows you to check if the bios password has been set or not

        .INPUTS
        No inputs needed

        .OUTPUTS
        Outputs the info if a Password has been set or not by by True or False statement

        .EXAMPLE
        C:\PS> Get-HPBiosPassword
        False

        .EXAMPLE
        C:\PS> Get-HPBiosPassword -Verbose
        VERBOSE: Password has been set; True
        True

        .EXAMPLE
        C:\PS> Get-HPBiosPassword -Verbose
        VERBOSE: Password has been set; False
        False

        .LINK
        PowerShell Module DictionaryFile
    #>

    [CmdletBinding()]
    param(
    )

    #* Test if manufacturer is HP if not return
    #region

    if (!(Test-HPManufacturer)) {
        throw "Manufacturer is not HP!"
        return
    }

    #endregion

    #* Read and store the bios setup password state
    #region

    $SetupPassword = Get-CimInstance `
        -Namespace "root/hp/instrumentedBIOS" `
        -ClassName "HP_BIOSPassword" | 
    Where-Object Name -EQ "Setup Password"
        
    # Logic to define bios password has been setup
    $Result = ($SetupPassword.IsSet -eq 1)

    #endregion

    #* Return result
    #region

    return $Result

    #endregion

}