[![Build status](https://mkellerman.visualstudio.com/PSTelegramAPI/_apis/build/status/PSTelegramAPI-CI)](https://mkellerman.visualstudio.com/PSTelegramAPI/_build/latest?definitionId=3)

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
$TLUserDialog = Get-TLUserDialog -TLClient $TLClient

# Get latest 100 messages from each User in List
ForEach ($User in $TLUserDialog) {
    $TLHistory = Get-TLHistory -TLClient $TLClient -Peer $User.Peer -Limit 100
}

# Find a specific User
$TLPeer = $TLUserDialog.Where({ $_.Peer.Username -eq 'mkellerman' }).Peer

# Send message to User
Invoke-TLSendMessage -TLClient $TLClient -TLPeer $TLPeer -Message 'Hello World'
```

# References

<https://github.com/sochix/TLSharp> : Telegram client library implemented in C#
