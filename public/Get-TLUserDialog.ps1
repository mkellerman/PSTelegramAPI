function Get-TLUserDialog ($TLClient) {

    $Results = @()
    $lastMessageDate = 0

    Do {

        Do {

            Write-Verbose "GetUserDialogsAsync(lastMessageDate: $lastMessageDate)"
            $Async = $TLClient.GetUserDialogsAsync($lastMessageDate) | Wait-TLAsync

            If ($TimeToWait = $Async.Exception.InnerException.TimeToWait.TotalSeconds) { Start-Sleep -Seconds $TimeToWait }
            If (-Not($TimeToWait) -and ($Async.Exception.InnerException.Message)) {
                Throw $Async.Exception.InnerException.Message
            }

        } Until ($Result = $Async.Result)

        $lastMessageDate = $Result.Messages.Date[-1]
        $Results += $Result

    } Until ($Result.Dialogs.Count -lt 100)

    $Users    = $Results.Users | ? { $_.GetType().Name -match 'TLUser' } | ConvertFrom-TLObject
    $Chats    = $Results.Chats | ? { $_.GetType().Name -match 'TLChat' } | ConvertFrom-TLObject
    $Channels = $Results.Chats | ? { $_.GetType().Name -match 'TLChannel' } | ConvertFrom-TLObject

    $Dialogs = $Results.Dialogs | ConvertFrom-TLObject
    $Messages = $Results.Messages | ConvertFrom-TLObject

    $Result = [PSCustomObject]@{
        User = $Users
        Chat = $Chats
        Channel = $Channel
        Dialog = $Dialogs
        Message = $Messages
    }

    Return $Result

}