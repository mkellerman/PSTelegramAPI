Try { Set-BuildEnvironment -Path "${PSScriptRoot}\.." -ErrorAction SilentlyContinue -Force } Catch { }

If (-Not $ENV:TLApiId)       { $ENV:TLApiId       = [Environment]::GetEnvironmentVariable("TLApiId", "User")       }
If (-Not $ENV:TLApiHash)     { $ENV:TLApiHash     = [Environment]::GetEnvironmentVariable("TLApiHash", "User")     }
If (-Not $ENV:TLPhoneNumber) { $ENV:TLPhoneNumber = [Environment]::GetEnvironmentVariable("TLPhoneNumber", "User") }

Remove-Module $ENV:BHProjectName -ErrorAction SilentlyContinue -Force -Confirm:$False
Import-Module $ENV:BHPSModuleManifest -Force

Describe 'Get-Module -Name PSTelegramAPI' {
    Context 'Strict mode' {

        Set-StrictMode -Version Latest

        It 'Should Import' {
            $Script:Module = Get-Module $ENV:BHPSModuleManifest
            $Script:Module.Name | Should be $ENV:BHProjectName
        }
        It 'Should have ExportedFunctions' {
            $Script:Module.ExportedFunctions.Keys -contains 'Get-TLContacts' | Should be $True
            $Script:Module.ExportedFunctions.Keys -contains 'Get-TLHistory' | Should be $True
            $Script:Module.ExportedFunctions.Keys -contains 'Get-TLUserDialogs' | Should be $True
            $Script:Module.ExportedFunctions.Keys -contains 'Invoke-TLSendMessage' | Should be $True
            $Script:Module.ExportedFunctions.Keys -contains 'New-TLClient' | Should be $True
        }
    }
}

Describe 'Execute Function tests' {
    Context 'Strict mode' {

        Set-StrictMode -Version Latest

        $Invalid_ApiId = Get-Random -Minimum 100000 -Maximum 999999
        $Invalid_ApiHash = [guid]::NewGuid().Guid.Replace('-','')
        $Invalid_PhoneNumber = '15550000000'

        It 'New-TLClient: Should fail with invalid ApiId' {
            { New-TLClient -ApiId $Invalid_ApiId -ApiHash $Invalid_ApiHash -PhoneNumber $Invalid_PhoneNumber } | Should -Throw "API_ID_INVALID"
        }
        It 'New-TLClient: Should fail with invalid ApiHash' {
            { New-TLClient -ApiId $ENV:TLApiId -ApiHash $Invalid_ApiHash -PhoneNumber $Invalid_PhoneNumber } | Should -Throw "API_ID_INVALID"
        }
        It 'New-TLClient: Should prompt for Code' {
            Mock 'Read-Host' { 11111 } -ModuleName PSTelegramAPI
            { New-TLClient -ApiId $ENV:TLApiId -ApiHash $ENV:TLApiHash -PhoneNumber $Invalid_PhoneNumber } | Should -Throw "The numeric code used to authenticate does not match the numeric code sent by SMS/Telegram"
            Assert-MockCalled -CommandName Read-Host -ModuleName PSTelegramAPI -Exactly 1
        }
    }
}

Describe 'Execution End-to-End tests' {
    Context 'Strict mode' {
        Set-StrictMode -Version Latest

        It 'New-TLClient: Should be IsConnected' {
            $Script:TLClient = New-TLClient -ApiId $ENV:TLApiId -ApiHash $ENV:TLApiHash -PhoneNumber $ENV:TLPhoneNumber
            $Script:TLClient.IsUserAuthorized() | Should -Be $true
        }

        It 'Get-TLContacts: Should be TLContacts' {
            $Script:TLContacts = Get-TLContacts -TLClient $Script:TLClient
            $Script:TLContacts.GetType().Name | Should -Be 'TLContacts'
        }

        It 'Get-TLUserDialogs: Should contain TLUserDialog' {
            $Script:TLUserDialogs = Get-TLUserDialogs -TLClient $Script:TLClient
            $Script:TLUserDialogs.Constructor | Should -Contain '1728035348'
        }

        It 'Get-TLUserDialogs: Should contain TLUser' {
            $Script:TLPeer = $Script:TLUserDialogs.Where({$_.Peer.username -eq 'mkellerman'}).Peer
            $Script:TLPeer.GetType().Name | Should -Be 'TLUser'
        }

        It 'Get-TLUserDialogs: Should contain TLMessage' {
            $Script:TLMessage = $Script:TLUserDialogs.Where({$_.Peer.username -eq 'mkellerman'}).Message
            $Script:TLMessage.GetType().Name | Should -Be 'TLMessage'
        }

        It 'Get-TLHistory: Should contain TLMessage' {
            $Script:TLHistory = Get-TLHistory -TLClient $Script:TLClient -TLPeer $Script:TLPeer -Limit 1
            $Script:TLHistory.Messages[0].GetType().Name | Should -Be 'TLMessage'
        }

        It 'Invoke-TLSendMessage: Should contain TLUpdateShortSentMessage' {
            $Script:TLSendMessage = Invoke-TLSendMessage -TLClient $Script:TLClient -TLPeer $Script:TLPeer -Message "Pester Test ${ENV:BHBuildNumber}"
        }

    }
}