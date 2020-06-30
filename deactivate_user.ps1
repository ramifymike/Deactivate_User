function Disable-Account {
    param (
           [Parameter(Mandatory=$true, Position=0)] [System.String]${Name},
           [Parameter(Mandatory=$true, Position=1)] [System.String]${ticketID}
       )

    ### MODIFY ###
    $target_path = 'OU=DisabledUsers,DC=ramify,DC=local'
    $local_domain = "ramify.io"
    ### MODIFY ###


    $getcred = Get-Credential -Message "PLEASE ENTER YOUR OFFICE 365 EMAIL ACCOUNT INFORMATION!!"    
    $datename = Get-Date -UFormat "%m%d%Y"

    # Username from ENV Variable
    $infra_associate = $env:USERNAME
   
    #import mods
    Import-Module ActiveDirectory
    Import-Module MSOnline
    Connect-MsolService -Credential $getcred
   
    #Save settings in case we need to restore
    $fullpath = Get-Location | Select-Object -ExpandProperty Path
    Write-Output " "
    Write-Output "Backing up user config..."
    $get_license = (Get-MsolUser -UserPrincipalName "$Name@$local_domain").Licenses | Select-Object -ExpandProperty AccountSkuID
    $get_license | Out-File "$fullpath/backups/$Name.txt" -Append
    Get-ADUser $Name -Properties MemberOf | Select-Object -ExpandProperty Memberof | Out-File "$fullpath/backups/$Name.txt" -Append
    Get-ADUser $Name -Properties Description | Out-File "$fullpath/backups/$Name.txt" -Append
   
   
    Write-Output " "
    Write-Output "Disabling Office 365 License..."
    Connect-MsolService -Credential $getcred
   
    Write-Output " "
    Write-Output "ATTACHED LICENSES:"
    $get_license
   
    ForEach ($i in $get_license){ Set-MsolUserLicense -UserPrincipalName $Name@$local_domain -RemoveLicenses $i }
    ForEach ($I in $get_license){ Write-Host "$i has been removed." -ForegroundColor Green}
    Write-Output " "
    Write-Host "Licenses have been removed." -ForegroundColor:Green
   
    #Remove AD Group Membership
    Write-Output " "
    Write-Output "Removing AD Group Membership..."
    Get-ADUser $Name -Properties MemberOf | ForEach-Object { $_.MemberOf | Remove-ADGroupMember -Members $_.DistinguishedName -Confirm:$false }
    Write-Output " "
    Write-Host "Group Membership has been removed." -ForegroundColor:Green
   
    Write-Output " "
    Write-Output "Disabling AD Account..."
    Disable-ADAccount -Identity $Name
    Write-Output " "
    Write-Host "Account has been disabled." -ForegroundColor:Green
   
    Write-Output " "
    Write-Output "Moving Account to Disabled Users OU..."
    Get-ADUser $Name | Move-ADObject -TargetPath $target_path
    Write-Output " "
    Write-Host "Account has been moved." -ForegroundColor:Green
   
    Write-Output " "
    Write-Output "Editing Description..."
    Set-ADUser $Name -Description "Account has been deactivated on $datename, by $infra_associate, ID: $ticketID"
    Get-ADUser $Name -Properties Description
    Write-host "Description has been updated." -ForegroundColor:Green
   
   }
   try {
    Disable-Account $args[0] $args[1]
   }
   
   catch {
    Write-Output "
       -- Deactive User Script --
       Usage Example:
           ./DEACTIVE_USER.ps1 %username %ticketUID
           ./DEACTIVE_USER.ps1 ramify_account 12345
   
