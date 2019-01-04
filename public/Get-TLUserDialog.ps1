function Get-TLUserDialog {

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [TLSharp.Core.TelegramClient]$TLClient
    )

    $Results = @()
    $lastMessageDate = 0

    Do {

        Write-Verbose "GetUserDialogsAsync(lastMessageDate: $lastMessageDate)"
        $Result = $TLClient.GetUserDialogsAsync($lastMessageDate) | Wait-TLAsync

        $lastMessageDate = $Result.Messages.Date[-1]
        $Results += $Result

    } Until ($Result.Dialogs.Count -lt 100)

    $Result = [PSCustomObject]@{
        User = $Results.Users
        Chat = $Results.Chats
        Dialog = $Results.Dialogs
        Message = $Results.Messages
    }

    Return $Result

}