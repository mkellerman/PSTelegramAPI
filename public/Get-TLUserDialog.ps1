function Get-TLUserDialog {

    [cmdletbinding()]
    Param(
        [Parameter(Mandatory = $true)]
        [TLSharp.Core.TelegramClient]$TLClient,
        [Parameter(Mandatory = $false)]
        [int]$OffsetDate = 0,
        [Parameter(Mandatory = $false)]
        [int]$OffsetId = 0,
        [Parameter(Mandatory = $false)]
        [TeleSharp.TL.TLAbsPeer]$OffsetPeer = $Null,
        [Parameter(Mandatory = $false)]
        [int]$Limit = [int]::MaxValue,
        [Parameter(Mandatory = $false)]
        [switch]$PassThru

    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

        $LimitPerRequest = 100
        $Results = New-Object System.Collections.ArrayList

    }

    Process {

        Do {

            If ($Limit -lt $LimitPerRequest) { $LimitPerRequest = $Limit }

            Write-Verbose "[$(Get-Date)] [INFO ]   > GetUserDialogsAsync (${OffsetDate}, ${OffsetId}, ${OffsetPeer}, ${LimitPerRequest})"
            $Result = $TLClient.GetUserDialogsAsync($OffsetDate, $OffsetId, $OffsetPeer, $LimitPerRequest) | Wait-TLAsync
            [void] $Results.Add($Result)

            $OffsetDate = $Result.Messages.Date | Sort-Object | Select-Object -First 1
            $Limit -= $Result.Dialogs.Count

        } Until (($Result.Dialogs.Count -lt $LimitPerRequest) -or ($Results.Dialogs.Count -ge $Limit))

    }

    End {

        Write-Verbose "[$(Get-Date)] [INFO ] > Dialogs: $($Results.Dialogs.Count) | Users: $($Results.Users.Count) | Chats: $($Results.Chats.Count) | Messages: $($Results.Messages.Count)"

        If ($PassThru) {

            ForEach ($Result in $Results) { $Result }

        } Else {

            $Result = [PSCustomObject]@{
                Dialogs = $Results.Dialogs
                Users = $Results.Users
                Chats = $Results.Chats
                Messages = $Results.Messages
            }

            ConvertFrom-TLUserDialog -TLUserDialog $Result -Verbose:$false

        }

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

    }

}