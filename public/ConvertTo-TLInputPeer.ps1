
function ConvertTo-TLInputPeer {

    [cmdletbinding()]
    Param(
        [parameter(ValueFromPipeline)]
        [object]$TLPeer
    )

    Begin {

        Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

    }

    Process {

        Switch ($TLPeer.GetType().Name) {
            'TLUser'    { New-Object TeleSharp.TL.TLInputPeerUser -Property @{ UserId = $TLPeer.Id; AccessHash = $TLPeer.AccessHash } }
            'TLChat'    { New-Object TeleSharp.TL.TLInputPeerChat -Property @{ ChatId = $TLPeer.Id } }
            'TLChannel' { New-Object TeleSharp.TL.TLInputPeerChannel -Property @{ ChannelId = $TLPeer.Id; AccessHash = $TLPeer.AccessHash } }
        }

    }

    End {

        Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

    }

}