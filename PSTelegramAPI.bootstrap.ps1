using namespace Microsoft.PowerShell.Commands
[CmdletBinding()]
param(
    #
    [ValidateSet("CurrentUser", "AllUsers")]
    $Scope = "CurrentUser"
)

[ModuleSpecification[]]$RequiredModules = @(
    @{ ModuleName = "InvokeBuild"; RequiredVersion = "5.4.2" }
    @{ ModuleName = "Pester"; RequiredVersion = "4.4.4" }
    @{ ModuleName = "BuildHelpers"; RequiredVersion = "2.0.3" }
)

$Policy = (Get-PSRepository PSGallery).InstallationPolicy
Set-PSRepository PSGallery -InstallationPolicy Trusted

try {
    $RequiredModules | Install-Module -Scope $Scope -Repository PSGallery -SkipPublisherCheck -Verbose
} finally {
    Set-PSRepository PSGallery -InstallationPolicy $Policy
}

$RequiredModules | Import-Module

# Install custom version of Pester
& git clone https://github.com/ThePSAdmin/Pester.git Pester;
& cd Pester;
& git pull;
& git checkout fix/jacocoreport;
& cd ..;

Get-Module Pester | Remove-Module;
Import-Module ./Pester/Pester.psd1
