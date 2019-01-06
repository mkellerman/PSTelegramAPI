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

        Write-Debug "`t Executing: [TLSharp.Core.TelegramClient]::New(${ApiId}, '${ApiHash}', Null, ${PhoneNumber}, Null)"
        $TLClient = [TLSharp.Core.TelegramClient]::New($ApiId, $ApiHash, $Null, $PhoneNumber, $Null)

        Do {

            Write-Debug "`t Executing: TLClient.ConnectAsync()"
            $Result = $TLClient.ConnectAsync() | Wait-TLAsync

        } Until ($Result)

        If (-Not $TLClient.IsUserAuthorized()) {

            Write-Debug "`t Executing: TLClient.SendCodeRequestAsync('+${PhoneNumber}')"
            $Hash = $TLClient.SendCodeRequestAsync("+${PhoneNumber}") | Wait-TLAsync

            $Code = Read-Host "Code from telegram"
            Write-Debug "`t Executing: TLClient.MakeAuthAsync(${PhoneNumber}, '${Hash}', ${Code})"
            $Result = $TLClient.MakeAuthAsync($PhoneNumber, $Hash, $Code) | Wait-TLAsync

        }

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $TLClient

    }
}