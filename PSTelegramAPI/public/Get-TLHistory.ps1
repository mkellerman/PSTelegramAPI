function Get-TLHistory {

    [cmdletbinding()]
    Param(
        $TLClient,
        $Peer,
        [int]$OffsetId = 0,
        [int]$OffsetDate = 0,
        [int]$AddOffset = 0,
        [int]$Limit = [int]::MaxValue,
        [int]$MaxId = 0,
        [int]$MinId = 0
    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

        $LimitPerRequest = 100
        $Results = New-Object System.Collections.ArrayList

    }

    Process {

        $MessageTotal = 0

        Do {

            If ($Limit -lt $LimitPerRequest) { $LimitPerRequest = $Limit }

            Write-Verbose "[$(Get-Date)] [INFO ]   > GetHistoryAsync ($Peer, ${OffsetId}, ${OffsetDate}, ${AddOffSet}, ${LimitPerRequest}, ${MaxId}, ${MinId})"
            $Result = $TLClient.GetHistoryAsync($Peer, $OffsetId, $OffsetDate, $AddOffSet, $LimitPerRequest, $MaxId, $MinId) | Wait-TLAsync

            [void] $Results.Add($Result)

            $OffsetId = $Result.Messages[-1].Id
            $Limit -= $LimitPerRequest


        } Until (($Limit -eq 0) -or ($Result.Messages.Count -lt $LimitPerRequest))

    }

    End {

        Switch ($Results[0].GetType().Name) {
            'TLChannelMessages' { $MessageCount = $Results[0].Count }
            'TLMessages'        { $MessageCount = $Results.Messages.Count }
            Default {
                Write-Warning "Unknown Type returned : $_"
            }
        }

        [object[]]$TLUsers    = $Results.Users # | Group-Object Id | ForEach-Object { $_.Group[-1] }
        [object[]]$TLChats    = $Results.Chats # | Group-Object Id | ForEach-Object { $_.Group[-1] }
        [object[]]$TLMessages = $Results.Messages # | Group-Object Id | ForEach-Object { $_.Group[-1] }

        Write-Verbose "[$(Get-Date)] [INFO ]   > Messages: $($TLMessages.Count) | Users: $($TLUsers.Count) | Chats: $($TLChats.Count) | Count: $($MessageCount)"

        $Result = [PSCustomObject]@{
            Users    = $Results | Select-Object -Expand Users
            Chats    = $Results | Select-Object -Expand Chats
            Messages = $Results | Select-Object -Expand Messages
            Count = $MessageCount
        }

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $Result

    }

}
