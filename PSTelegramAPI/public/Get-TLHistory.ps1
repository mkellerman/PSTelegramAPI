function Get-TLHistory {

    [cmdletbinding()]
    Param(
        $TLClient,
        [object]$Peer,
        [int]$OffsetId = 0,
        [int]$OffsetDate = 0,
        [int]$AddOffset = 0,
        [int]$Limit = [int]::MaxValue,
        [int]$MaxId = 0,
        [int]$MinId = 0,
        [switch]$PassThru
    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

        $MessageTotal = 0
        $LimitPerRequest = 100

        $Results = New-Object System.Collections.ArrayList

        $TLInputPeer = ConvertTo-TLInputPeer -TLPeer $Peer -Verbose:$false

    }

    Process {



        Do {

            If ($Limit -lt $LimitPerRequest) { $LimitPerRequest = $Limit }

            Do {
                Write-Verbose "[$(Get-Date)] [INFO ]   > GetHistoryAsync ($TLInputPeer, ${OffsetId}, ${OffsetDate}, ${AddOffSet}, ${LimitPerRequest}, ${MaxId}, ${MinId})"
                $Result = $TLClient.GetHistoryAsync($TLInputPeer, $OffsetId, $OffsetDate, $AddOffSet, $LimitPerRequest, $MaxId, $MinId) | Wait-TLAsync
            } While ($Result -eq $false)

            [void] $Results.Add($Result)

            $OffsetId = $Result.Messages[-1].Id
            $Limit -= $LimitPerRequest


        } Until (($Limit -eq 0) -or ($Result.Messages.Count -lt $LimitPerRequest))

    }

    End {

        Switch ($Results[0].GetType().Name) {
            'TLChannelMessages' { $MessageCount = $Results[0].Count }
            'TLMessagesSlice'   { $MessageCount = $Results[0].Count }
            'TLMessages'        { $MessageCount = $Results[0].Messages.Count }
            Default {
                Write-Warning "Unknown Type returned : $_"
            }
        }

        Write-Verbose "[$(Get-Date)] [INFO ]   > Messages: $($Results.Messages.Count) | Users: $($Results.Users.Count) | Chats: $($Results.Chats.Count) | Count: $($MessageCount)"

        If ($PassThru) {

            ForEach ($Result in $Results) { $Result }

        } Else {

            [PSCustomObject]@{
                InputPeer = $TLInputPeer
                Users     = $Results.Users
                Chats     = $Results.Chats
                Messages  = $Results.Messages
                Count     = $MessageCount
            }

        }

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

    }

}
