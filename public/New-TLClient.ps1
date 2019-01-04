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

        Write-Verbose "[$(Get-Date)] [BEGIN] New-TLClient: ${PhoneNumber}"

    }

    Process {

        $TLClient = [TLSharp.Core.TelegramClient]::New($ApiId, $ApiHash, $Null, $PhoneNumber, $null)

        Do {

            Write-Debug "`t Executing TLClient.ConnectAsync()"
            $Result = $TLClient.ConnectAsync() | Wait-TLAsync

        } Until ($Result)

        If (-Not $TLClient.IsUserAuthorized()) {

            Write-Debug "`t Executing TLClient.SendCodeRequestAsync()"
            $Hash = $TLClient.SendCodeRequestAsync("+${phoneNumber}") | Wait-TLAsync

            $Code = Read-Host "Code from telegram"
            Write-Debug "`t Executing TLClient.MakeAuthAsync()"
            $Result = $TLClient.MakeAuthAsync($PhoneNumber, $Hash, $Code) | Wait-TLAsync

        }

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] New-TLClient: ${PhoneNumber}"
        Return $TLClient

    }
}