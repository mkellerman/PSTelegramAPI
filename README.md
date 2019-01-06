[![Build status](https://mkellerman.visualstudio.com/PSTelegramAPI/_apis/build/status/PSTelegramAPI-CI)](https://mkellerman.visualstudio.com/PSTelegramAPI/_build/latest?definitionId=3)

# PSTelegramAPI

PowerShell Module for Telegram APIs

# Examples

```powershell
Import-Module PSTelegramAPI

# Establish connection to telegram
$TLClient = New-TLClient -apiId $ENV:TLApiId -apiHash $ENV:TLApiHash -phoneNumber $ENV:TLPhoneNumber -Verbose

# Get User Dialogs
$TLUserDialog = Get-TLUserDialog -TLClient $TLClient -Verbose

# Get latest 100 messages from each User Dialog
ForEach ($User in $TLUserDialog) {
    $TLHistory = Get-TLHistory -TLClient $TLClient -Peer $User.Peer -Limit 100 -Verbose
}
```

# References

<https://github.com/sochix/TLSharp> : Telegram client library implemented in C#
