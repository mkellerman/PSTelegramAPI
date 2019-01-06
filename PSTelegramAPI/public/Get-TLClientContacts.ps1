function Get-TLClientContacts {


    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [TLSharp.Core.TelegramClient]$TLClient
    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

    }

    Process {

        Do {
            Write-Verbose "[$(Get-Date)] [INFO ]   > TLClient.GetContactsAsync()"
            $Result = $TLClient.GetContactsAsync() | Wait-TLAsync
        } While ($Result -eq $False)

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $Result

    }

}
