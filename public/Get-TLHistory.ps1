function Get-TLHistory {

    [cmdletbinding()]
    Param(
        $TLClient,
        $Peer,
        [int]$OffsetId = 0,
        [int]$OffsetDate = 0,
        [int]$AddOffset = 0,
        [int]$Limit = 100,
        [int]$MaxId = 0,
        [int]$MinId = 0,
        [int]$Count = [int]::MaxValue,
        [int]$HasMessages = 0
    )

    $Loop = $True
    $MessageTotal = 0
    $Users = @(); $Chats = @(); $Channels = @(); $Messages = @()

    Do {

        if ($Peer.ChannelId) { $ContextId = $Peer.ChannelId }
        if ($Peer.ChatId) { $ContextId = $Peer.ChatId }
        if ($Peer.UserId) { $ContextId = $Peer.UserId }

        #Write-Verbose "GetHistoryAsync: Peer:${ContextId}, OffsetId:${OffsetId}, OffsetDate:${OffsetDate}, AddOffset:${AddOffset}, Limit:${Limit}, MaxId:${MaxId}, MinId:${MinId}"

        Do {

            $Async = $TLClient.GetHistoryAsync($Peer, $OffsetId, $OffsetDate, $AddOffSet, $Limit, $MaxId, $MinId) | Wait-TLAsync

            If ($TimeToWait = $Async.Exception.InnerException.TimeToWait.TotalSeconds) { Start-Sleep -Seconds $TimeToWait }
            If (-Not($TimeToWait) -and ($Async.Exception.InnerException.Message)) {
                Throw $Async.Exception.InnerException.Message
            }

        } Until ($Result = $Async.Result)

        If ($Result.Users.Count) {
            $Users    += $Result.Users.Where({ 'TLUser', 'TLUserForbidden' -contains $_.GetType().Name }) | ConvertFrom-TLObject
        }
        If ($Result.Chats.Count) {
            $Chats    += $Result.Chats.Where({ 'TLChat', 'TLChatForbidden' -contains $_.GetType().Name }) | ConvertFrom-TLObject
            $Channels += $Result.Chats.Where({ 'TLChannel', 'TLChannelForbidden' -contains $_.GetType().Name }) | ConvertFrom-TLObject
        }
        If ($Result.Messages.Count) {
            $Messages += $Result.Messages | ConvertFrom-TLObject
        }

        $MeasureMessages = $Result.Messages.Id | Measure-Object -Minimum -Maximum
        If($MeasureMessages.Count -lt $Limit) { $Loop = $False }

        If (($MessageTotal -eq 0) -and ($MeasureMessages.Count -gt $Result.Count)) {
            $MessageTotal = $MeasureMessages.Count
        } Else {
            $MessageTotal = $Result.Count
        }

        Write-Warning "Results : $($MeasureMessages.Maximum) > $($MeasureMessages.Minimum) [$($MeasureMessages.Count)] `t| $($Messages.Count + $HasMessages)/$($MessageTotal)"

        If ($MessageTotal -eq 0) { Break }
        If ($Messages.Count -ge $Count) { Break }
        If (($Messages.Count + $HasMessages) -ge $MessageTotal) { Break }

        $OffSetId = $MeasureMessages.Minimum

    } While ($Loop)

    $Result = [PSCustomObject]@{
        User    = $Users
        Chat    = $Chats
        Channel = $Channels
        Message = $Messages
        MessageTotal = $MessageTotal
    }

    Return $Result

}
