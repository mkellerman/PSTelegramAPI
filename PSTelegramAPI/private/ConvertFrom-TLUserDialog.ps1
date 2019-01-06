
function ConvertFrom-TLUserDialog {

    [cmdletbinding()]
    Param(
        [object]$TLUserDialog
    )

    Begin {

        #Write-Verbose "[$(Get-Date)] [BEGIN] $($MyInvocation.MyCommand)"

        $Results = New-Object System.Collections.ArrayList

    }

    Process {

        ForEach ($TLDialog in ($TLUserDialog.Dialogs | Select-Object *)) {

            Switch ($TLDialog.Peer.GetType().Name) {
                'TLPeerUser'    {
                    $TLPeer = $TLUserDialog.Users.Where({$_.Id -eq $TLDialog.Peer.UserId}) | Select-Object -Last 1
                    $TLMessage = $TLUserDialog.Messages.Where({($_.FromId -eq $TLPeer.Id) -or ($_.ToId.UserId -eq $TLPeer.Id)}) | Select-Object -Last 1
                }
                'TLPeerChat'   {
                    $TLPeer = $TLUserDialog.Chats.Where({$_.Id -eq $TLDialog.Peer.ChatId}) | Select-Object -Last 1
                    $TLMessage = $TLUserDialog.Messages.Where({$_.ToId.ChatId -eq $TLPeer.Id}) | Select-Object -Last 1
                }
                'TLPeerChannel' {
                    $TLPeer = $TLUserDialog.Chats.Where({$_.Id -eq $TLDialog.Peer.ChannelId}) | Select-Object -Last 1
                    $TLMessage = $TLUserDialog.Messages.Where({$_.ToId.ChannelId -eq $TLPeer.Id}) | Select-Object -Last 1
                }
            }

            $TLDialog | Add-Member -MemberType NoteProperty -Name Peer -Value $TLPeer -Force
            $TLDialog | Add-Member -MemberType NoteProperty -Name Message -Value $TLMessage

            [void] $Results.Add($TLDialog)

        }

    }

    End {

        #Write-Verbose "[$(Get-Date)] [END  ] $($MyInvocation.MyCommand)"

        Return $Results

    }

}