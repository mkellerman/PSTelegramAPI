[![PSGallery Version](https://img.shields.io/powershellgallery/v/PSTelegramAPI.svg?style=for-the-badge&label=PowerShell%20Gallery)](https://www.powershellgallery.com/packages/PSTelegramAPI/)
![PSGallery Downloads](https://img.shields.io/powershellgallery/dt/PSTelegramAPI.svg?style=for-the-badge&label=Downloads)

![Azure Pipeline](https://img.shields.io/azure-devops/build/mkellerman/PSTelegramAPI/3.svg?style=for-the-badge&label=Azure%20Pipeline)

# PSTelegramAPI

PowerShell Module for Telegram APIs

# Install PSTelegramAPI from PSGallery
```powershell
Install-Module PSTelegramAPI -Scope CurrentUser
```

# Examples

```powershell
Import-Module PSTelegramAPI

# Establish connection to Telegram
$TLClient = New-TLClient -apiId $ENV:TLApiId -apiHash $ENV:TLApiHash -phoneNumber $ENV:TLPhoneNumber

# Get List of User Dialogs
$TLUserDialogs = Get-TLUserDialogs -TLClient $TLClient

# Get latest 100 messages from each User in List
ForEach ($User in $TLUserDialog) {
    $TLHistory = Get-TLHistory -TLClient $TLClient -Peer $User.Peer -Limit 100
}

# Find a specific User
$TLPeer = $TLUserDialogs.Where({ $_.Peer.Username -eq 'mkellerman' }).Peer

# Send message to User
Invoke-TLSendMessage -TLClient $TLClient -TLPeer $TLPeer -Message 'Hello World'
```

# Completed

* Get-TLUserDialogs
* Get-TLContacts
* Get-TLHistory
* Invoke-TLSendMessage

# References

* [PSTelegramAPI](https://www.powershellgallery.com/packages/PSTelegramAPI/) : PowerShell Gallery
* [TLSharp](https://github.com/sochix/TLSharp) : Telegram client library implemented in C#
