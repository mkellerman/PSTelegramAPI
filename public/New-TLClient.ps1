function New-TLClient ($apiId, $apiHash, $phoneNumber) {

    $TLClient = [TLSharp.Core.TelegramClient]::new($apiId, $apiHash, $Null, [int64]$phoneNumber, $null)
    Do {
        $Async = $TLClient.ConnectAsync()
        If ($TimeToWait = $Async.Exception.InnerException.TimeToWait.TotalSeconds) {
            Write-Warning "WAITING: $TimeToWait"
            Start-Sleep -Seconds $TimeToWait
        }
    } Until ($IsConnected = $Async.Result)

    If (-Not($TLClient.IsUserAuthorized())) {

        Do {
            $Async = $TLClient.SendCodeRequestAsync("+${phoneNumber}") | Wait-TLAsync
            If ($TimeToWait = $Async.Exception.InnerException.TimeToWait.TotalSeconds) { Start-Sleep -Seconds $TimeToWait }
        } Until ($Hash = $Async.Result)

        $Code = Read-Host "Code from telegram"

        Do {
            $Async = $TLClient.MakeAuthAsync($phoneNumber, $Hash, $Code) | Wait-TLAsync
            If ($TimeToWait = $Async.Exception.InnerException.TimeToWait.TotalSeconds) { Start-Sleep -Seconds $TimeToWait }
        } Until ($User = $Async.Result)

    }

    If (-Not($TLClient.IsUserAuthorized())) {
        Throw "Error: IsUserAuthorized = False"
    }

    Return $TLClient

}