##Author, Steven Soward ©2024   || MIT License

Import-Module ActiveDirectory
Add-Type -AssemblyName 'System.Web'
#intro message box:
$userresponse=[System.Windows.MessageBox]::Show('This tool imports a .CSV file of users and sets a random password for them.

The input csv must have the username in a column named "samAccountName".



Press OK to Choose the input CSV File', 'Steves rando password setter','okcancel')
if ($UserResponse -eq "ok" ) 
{

#Yes activity

} 

else 

{ 

exit

}



Function Get-FileName($initialDirectory) {
[System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
$OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$OpenFileDialog.initialDirectory = $initialDirectory
$OpenFileDialog.filter = "All files (*.*)| *.*"
if ($OpenFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $OpenFileDialog.FileName }
$Global:SelectedFile = $OpenFileDialog.FileName

} #end function Get-FileName

Get-FileName

#import user from csv file

Import-Csv $selectedfile |




ForEach-Object {

$samAccountName = $_."samAccountName"
$minLength = 16 ## characters
$maxLength = 17 ## characters
$length = Get-Random -Minimum $minLength -Maximum $maxLength
$nonAlphaChars = 5
$passwordgen = [System.Web.Security.Membership]::GeneratePassword($length, $nonAlphaChars)
$Password =$passwordgen

# Reset user Password.

Set-ADAccountPassword -Identity $samAccountName -Reset -NewPassword (ConvertTo-SecureString -AsPlainText "$Password" -Force)



#thanks to mike f. robbins at mikefrobbins.com for the following function to test the changed credentials we've set:

#begin cred test function:  ________________________________________
#Requires -Version 3.0 -Modules ActiveDirectory

<#
.SYNOPSIS
    Test-MrADUserPassword is a function for testing an Active Directory user account for a specific password.
.DESCRIPTION
    Test-MrADUserPassword is an advanced function for testing one or more Active Directory user accounts for a
    specific password.
.PARAMETER UserName
    The username for the Active Directory user account.
.PARAMETER Password
    The password to test for.
.PARAMETER ComputerName
    A server or computer name that has PowerShell remoting enabled.
.PARAMETER InputObject
    Accepts the output of Get-ADUser.
.EXAMPLE
     Test-MrADUserPassword -UserName alan0 -Password Password1 -ComputerName Server01
.EXAMPLE
     'alan0'. 'andrew1', 'frank2' | Test-MrADUserPassword -Password Password1 -ComputerName Server01
.EXAMPLE
     Get-ADUser -Filter * -SearchBase 'OU=AdventureWorks Users,OU=Users,OU=Test,DC=mikefrobbins,DC=com' |
     Test-MrPassword -Password Password1 -ComputerName Server01
.INPUTS
    String, Microsoft.ActiveDirectory.Management.ADUser
.OUTPUTS
    PSCustomObject
.NOTES
    Author:  Mike F Robbins
    Website: http://mikefrobbins.com
    Twitter: @mikefrobbins
#>
function Test-MrADUserPassword {
    [CmdletBinding(DefaultParameterSetName='Parameter Set UserName')]
    param (
        [Parameter(Mandatory,
                   ValueFromPipeline,
                   ValueFromPipelineByPropertyName,
                   ParameterSetName='Parameter Set UserName')]
        [Alias('SamAccountName')]
        [string[]]$UserName,
        [Parameter(Mandatory)]
        [string]$Password,
        [Parameter(Mandatory)]
        [string]$ComputerName,
        [Parameter(ValueFromPipeline,
                   ParameterSetName='Parameter Set InputObject')]
        [Microsoft.ActiveDirectory.Management.ADUser]$InputObject
    )
    BEGIN {
        $Pass = ConvertTo-SecureString $Password -AsPlainText -Force
        $Params = @{
            ComputerName = $ComputerName
            ScriptBlock = {Get-Random | Out-Null}
            ErrorAction = 'SilentlyContinue'
            ErrorVariable  = 'Results'
        }
    }
    PROCESS {
        if ($PSBoundParameters.UserName) {
            Write-Verbose -Message 'Input received via the "UserName" parameter set.'
            $Users = $UserName
        }
        elseif ($PSBoundParameters.InputObject) {
            Write-Verbose -Message 'Input received via the "InputObject" parameter set.'
            $Users = $InputObject
        }
        foreach ($User in $Users) {
            if (-not($Users.SamAccountName)) {
                Write-Verbose -Message "Querying Active Directory for UserName $($User)"
                $User = Get-ADUser -Identity $User
            }
            $Params.Credential = (New-Object System.Management.Automation.PSCredential ($($User.UserPrincipalName), $Pass))
            Invoke-Command @Params
            [pscustomobject]@{
                UserName = $User.SamAccountName
                PasswordCorrect =
                    switch ($Results.FullyQualifiedErrorId -replace ',.*$') {
                        LogonFailure {$false; break}
                        AccessDenied {$true; break}
                        default {$true}
                    }
            }
        }
    }
}

##End test cred function _____________________________________________________________________


Test-MrADUserPassword -UserName $samAccountName -Password $password -ComputerName localhost


# force user to reset passwod at next logon

##Set-ADUser -Identity $samAccountName -ChangePasswordAtLogon $true


Write-Host " Active Directory account Password has been reset for: " $samAccountName





#Clear-Variable -Name "password"
#Clear-variable -Name "passwordgen"
}


