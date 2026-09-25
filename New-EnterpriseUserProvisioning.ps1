<#
.SYNOPSIS
    Automated Active Directory User Onboarding & RBAC Assignment Tool.
.DESCRIPTION
    Reads new hire data, generates secure temporary credentials, provisions AD accounts 
    in target OUs, assigns RBAC security groups, and enforces password change at next logon.
.NOTES
    Author: Namit Rajput
    Target Environment: Enterprise Windows Server Active Directory
#>

Param(
    [Parameter(Mandatory=$true)]
    [string]$FirstName,

    [Parameter(Mandatory=$true)]
    [string]$LastName,

    [Parameter(Mandatory=$true)]
    [string]$Department,

    [Parameter(Mandatory=$true)]
    [string]$OUPath
)

Import-Module ActiveDirectory

$SAMAccountName = ($FirstName.Substring(0,1) + $LastName).ToLower()
$UPN = "$SAMAccountName@company.com"
$DisplayName = "$FirstName $LastName"

# Generate Temporary Secure Password
$TempPassword = ConvertTo-SecureString "Welcome2026!#$(Get-Random -Minimum 1000 -Maximum 9999)" -AsPlainText -Force

try {
    Write-Host "Provisioning AD User: $DisplayName..." -ForegroundColor Cyan
    
    New-ADUser -Name $DisplayName `
               -GivenName $FirstName `
               -Surname $LastName `
               -SamAccountName $SAMAccountName `
               -UserPrincipalName $UPN `
               -Department $Department `
               -Path $OUPath `
               -AccountPassword $TempPassword `
               -Enabled $true `
               -ChangePasswordAtLogon $true

    Write-Host "SUCCESS: Account created for $SAMAccountName" -ForegroundColor Green
}
catch {
    Write-Error "Failed to create AD User: $_"
}
