function Test-HPManufacturer {
    <#
    .SYNOPSIS
        This function test if the current machine's manufacturer is HP
    .DESCRIPTION
        This function test if the current machine's manufacturer is HP
    .NOTES
        File Name      : Test-HPManufacturer.ps1
        Author         : Jack den Ouden
        Change history : 
            2024-05-09 - Initial creation
    .LINK
        https://github.com/Jackldam/HPBios
    .EXAMPLE
        PS C:\> Test-HPManufacturer
        True
    .EXAMPLE
        PS C:\> Test-HPManufacturer
        False
    #>

    [CmdletBinding()]
    param(
    )

    # Get Cim instance of class Win32_Computersystem
    $Win32Computersystem = Get-CimInstance -Namespace "root/cimv2" -ClassName "Win32_Computersystem"

    # Throw error if Win32Computersystem variable is empty
    if (!($Win32Computersystem)) {
        throw "Unable to read CimInstance"
        return
    }

    # Test if current endpoint manufacturer is HP if true set result to True 
    $Result = ($Win32Computersystem.Manufacturer -eq "HP")

    # Return result
    return $Result

}