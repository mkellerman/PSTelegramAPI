$ModuleName = 'PSTelegramAPI'
$ModuleManifestName = "${ModuleName}.psd1"
$ModuleManifestPath = "${PSScriptRoot}\..\${ModuleManifestName}"

Describe 'General Module Tests' {
    It 'Passes Test-ModuleManifest' {
        Test-ModuleManifest -Path $ModuleManifestPath | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
    It 'Passes Import-Module' {
        Import-Module -Name $ModuleManifestPath -Force -PassThru | Should Not BeNullOrEmpty
        $? | Should Be $true
    }
}

