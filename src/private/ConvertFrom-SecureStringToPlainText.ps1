function ConvertFrom-SecureStringToPlainText {
    <#
    .SYNOPSIS
    Converts a SecureString to plain text.

    .DESCRIPTION
    The ConvertFrom-SecureStringToPlainText function decrypts a SecureString object to a plain text string.
    This can be useful in scenarios where a plain text password is required for a command or an API.
    The function utilizes .NET methods to ensure the conversion is done securely, but users should handle the output with caution to avoid exposing sensitive information.

    Important! 
    This function should be used with caution.
    Converting SecureString to plain text may expose sensitive information in memory or in scripts.

    .PARAMETER SecureString
    The SecureString object to be converted to plain text. This parameter is mandatory.
    .NOTES
        File Name      : ConvertFrom-SecureStringToPlainText.ps1
        Author         : Jack den Ouden <jack@ldam.nl>
        Change history : 
            2024-05-09 - Initial creation
    .LINK
        https://github.com/Jackldam/HPBios
    .EXAMPLE
    $securePassword = ("PlainTextPassword" | ConvertTo-SecureString -AsPlainText -force)
    $plainTextPassword = ConvertFrom-SecureStringToPlainText -SecureString $securePassword
    Write-Host "The plain text password is: $plainTextPassword"

    This example shows how to convert a SecureString to plain text. First, it creates a SecureString object from a plain text password, then converts it back to plain text.
    #>
    [CmdletBinding()]
    param (
        # Specifies the secure string to convert to plain text.
        [Parameter(Mandatory)]
        [SecureString]
        $SecureString
    )
    
    begin {
        #Set ErrorActionPreference to stop
        $ErrorActionPreference = "Stop"
    }
    
    process {
        # Convert SecureString to BSTR (Basic String).
        $ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)

        try {
            # Convert BSTR to plain text.
            $plainTextPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($ptr)
        }
        finally {
            # Ensure the BSTR pointer is freed to avoid memory leaks.
            [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
        }
    }
    
    end {
        # Return the plain text password.
        return $plainTextPassword
    }
}