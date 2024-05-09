function Set-HPBiosSetting {
    <#
    .SYNOPSIS
        This function allow's you to set a HP Bios setting.
    .DESCRIPTION
        This function allow's you to set a HP Bios setting.
        To get the available values of a HP Bios Setting use the Get-HPBiosSetting function
    .NOTES
        File Name      : Set-HPBiosSetting.ps1
        Author         : Jack den Ouden
        Change history : 
            2024-05-09 - Initial creation
    .LINK
        https://github.com/Jackldam/HPBios
    .EXAMPLE
        PS C:\> Set-HPBiosSetting -Password ("Password" | ConvertTo-SecureString -AsPlainText -Force) -Name "USB Legacy Port Charging" -Value "Enable"
    .EXAMPLE
        PS C:\> Set-HPBiosSetting -Name "USB Legacy Port Charging" -Value "Disable"
    #>

    [CmdletBinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory = $true)]
        [string]
        $Name,
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [string]
        $Value,
        # Parameter help description
        [Parameter(Mandatory = $false)]
        [securestring]
        $Password
    )

    Begin {
        # Define the list of Exit codes
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
            throw "Manufacturer is not HP!"
            return
        }

        #endregion

        #* Test if Bios setting is readonly if yes throw error
        #region

        if (Test-HPBiosSettingIsReadOnly -Name $Name) {
            throw "Skipping bios setting $Name, is read only"
            return
        }

        #endregion

        #* Test if bios setup password is set and if Password parameter is not empty
        #region

        If (Test-HPBiosSetupPasswordIsSet) {
            if (($null -eq $Password)) {
    
                # throw error if no password was provided and password is set
                throw "HP Bios password is set please supply password"
    
            }
        }

        #endregion
    
        #* Convert securestring password to plain text
        #region

        if ($Password) {
            # Store password as plain text in variable
            $PlainTextPW = ConvertFrom-SecureStringToPlainText -SecureString $Password
        }
    
        #endregion

        #* Set Bios setting
        #region

        # Get the Bios Instance
        $BiosCimInstance = Get-CimInstance -Namespace "root/hp/instrumentedBIOS" -ClassName "HP_BIOSSettingInterface" 
        
        # Get the Bios Instance
        $Return = $BiosCimInstance | Invoke-CimMethod -MethodName "SetBIOSSetting" -Arguments @{
            Name     = $Name
            Value    = $Value
            Password = "<utf-16/>${PlainTextPW}"
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

    End {
    }
}