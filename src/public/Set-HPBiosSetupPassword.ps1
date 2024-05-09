function Set-HPBiosSetupPassword {
    <#
    .SYNOPSIS
        This function allow's you to Set, Replace or Clear the HP Bios Setup password.
    .DESCRIPTION
        This function allow's you to Set, Replace or Clear the HP Bios Setup password.
    .NOTES
        File Name      : Set-HPBiosSetupPassword.ps1
        Author         : Jack den Ouden
        Change history : 
            2024-05-09 - Initial creation
    .LINK
        https://github.com/Jackldam/HPBios
    .EXAMPLE
    C:\PS> Set-HPBiosSetupPassword -NewPassword $("PlainTextPW" | ConvertTo-SecureString -AsPlainText -Force)
    
    .EXAMPLE
    C:\PS> Set-HPBiosSetupPassword -CurrentPassword $("PlainTextPW" | ConvertTo-SecureString -AsPlainText -Force) -NewPassword $("PlainTextPW2" | ConvertTo-SecureString -AsPlainText -Force)
    
    .EXAMPLE
    C:\PS> Set-HPBiosSetupPassword -Clear -CurrentPassword $("PlainTextPW2" | ConvertTo-SecureString -AsPlainText -Force)
    #>

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Clear')]
        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [securestring]
        $CurrentPassword,

        [Parameter(Mandatory = $false, ParameterSetName = 'Default')]
        [securestring]
        $NewPassword,
        
        [Parameter(ParameterSetName = 'Clear')]
        [switch]
        $Clear
    )

    begin {
        # Define the list of error codes
        $List = @(
            [pscustomobject]@{ExitCode = "0"; Description = "Success" }
            [pscustomobject]@{ExitCode = "1"; Description = "Not Supported" }
            [pscustomobject]@{ExitCode = "2"; Description = "Unkown" }
            [pscustomobject]@{ExitCode = "3"; Description = "Timeout" }
            [pscustomobject]@{ExitCode = "4"; Description = "Failed" }
            [pscustomobject]@{ExitCode = "5"; Description = "Invalid Parameter" }
            [pscustomobject]@{ExitCode = "6"; Description = "Access Denied" }
        )
    }

    Process {

        #* Test if manufacturer is HP if not return
        #region

        if (!(Test-HPManufacturer)) {
            Write-Verbose "Manufacturer is not HP!"
            return
        }

        #endregion
        
        #* Check if clear switch has been used and set NewPassword
        #region

        if ($Clear) {
            if (!(Test-HPBiosSetupPasswordIsSet)) {
                Write-Verbose "Bios password is not set"
                return "Success"
            }
            $NewPassword = $null
        }
        else {
            # Convert new password to plaintext
            [string]$NewPassword = ConvertFrom-SecureStringToPlainText -SecureString $NewPassword
        }

        #endregion

        #* Current password prechecks
        #region

        # Check if password is set
        Write-Verbose "Test if bios setup password is set"
        if (!(Test-HPBiosSetupPasswordIsSet)) { 
            $CurrentPassword = $null 
        } 
        else {
            # Check if current password is supplied
            if ($null -eq $CurrentPassword) { Throw "Please supply current password" ; return }

            # Convert current password to plaintext
            [string]$CurrentPassword = ConvertFrom-SecureStringToPlainText -SecureString $CurrentPassword 
        }

        #endregion

        #* Set Password
        #region

        $BiosCimInstance = Get-CimInstance -Namespace "root/hp/instrumentedBIOS" -ClassName "HP_BIOSSettingInterface"

        if ($NewPassword.Length -gt 30) {
            throw "New password is to long it must be less then 30 characters"
            return
        }
    
        # Set new password
        $Return = $BiosCimInstance | Invoke-CimMethod -MethodName "SetBIOSSetting" -Arguments @{
            Name     = "Setup Password"
            Value    = "<utf-16/>${NewPassword}"
            Password = "<utf-16/>${CurrentPassword}"
        }

        Write-Verbose "Return $($Return.return)"

        if ($Return.return -ne 0) {
            throw $($List | Where-Object ExitCode -EQ $Return.return).Description
        }
        else {
            return $($List | Where-Object ExitCode -EQ $Return.return).Description
        }

        #endregion
    }

    end {

    }
    

}