function Get-TLClientContacts ($TLClient) {

    # Contact list that is synced with users phone. :/
    Do {
        $Async = $TLClient.GetContactsAsync() | Wait-TLAsync
        If ($TimeToWait = $Async.Exception.InnerException.TimeToWait.TotalSeconds) { Start-Sleep -Seconds $TimeToWait }
    } Until ($Result = $Async.Result)

    Return $Result

}
