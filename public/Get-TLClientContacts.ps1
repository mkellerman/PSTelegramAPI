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

        Write-Debug "`t Executing: GetContactsAsync()"

        $Result = $TLClient.GetContactsAsync() | Wait-TLAsync

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $Result

    }

}
