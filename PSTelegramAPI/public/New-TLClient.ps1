function New-TLClient {

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [int]$ApiId,

        [Parameter(Mandatory = $true)]
        [string]$ApiHash,

        [Parameter(Mandatory = $true)]
        [int64]$PhoneNumber
    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

    }

    Process {

        Write-Verbose "[$(Get-Date)] [INFO ]   > [TLSharp.Core.TelegramClient]::New(${ApiId}, '${ApiHash}', Null, ${PhoneNumber}, Null)"
        $TLClient = [TLSharp.Core.TelegramClient]::New($ApiId, $ApiHash, $Null, $PhoneNumber, $Null)

        Do {
            Write-Verbose "[$(Get-Date)] [INFO ]   > TLClient.ConnectAsync()"
            $Result = $TLClient.ConnectAsync() | Wait-TLAsync
        } While ($Result -eq $false)

        If (-Not $TLClient.IsUserAuthorized()) {

            Write-Verbose "[$(Get-Date)] [INFO ]   > TLClient.SendCodeRequestAsync('+${PhoneNumber}')"
            $Hash = $TLClient.SendCodeRequestAsync("+${PhoneNumber}") | Wait-TLAsync

            $Code = Read-Host "Code from telegram"
            Write-Verbose "[$(Get-Date)] [INFO ]   > TLClient.MakeAuthAsync(${PhoneNumber}, '${Hash}', ${Code})"
            $Result = $TLClient.MakeAuthAsync($PhoneNumber, $Hash, $Code) | Wait-TLAsync

        }

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $TLClient

    }
}