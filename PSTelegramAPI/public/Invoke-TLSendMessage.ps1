function Invoke-TLSendMessage {


    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [TLSharp.Core.TelegramClient]$TLClient,

        [Parameter(Mandatory = $true)]
        [object]$TLPeer,

        [Parameter(Mandatory = $true)]
        [object]$Message
    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

        $TLInputPeer = ConvertTo-TLInputPeer -TLPeer $TLPeer -Verbose:$false

    }

    Process {

        Do {
            Write-Verbose "[$(Get-Date)] [INFO ]   > TLClient.GetContactsAsync()"
            $Result = $TLClient.SendMessageAsync($TLInputPeer, $Message) | Wait-TLAsync
        } While ($Result -eq $False)

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $Result

    }

}
