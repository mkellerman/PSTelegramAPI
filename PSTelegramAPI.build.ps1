<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

param ($Configuration = 'Development')

#region use the most strict mode
Set-StrictMode -Version Latest
#endregion

#region Task to Update the PowerShell Module Help Files.
# Pre-requisites: PowerShell Module PlatyPS.
task UpdateHelp {
    Import-Module .\PSTelegramAPI.psd1 -Force
    Update-MarkdownHelp .\docs
    New-ExternalHelp -Path .\docs -OutputPath .\en-US -Force
}
#endregion

#region Task to retrieve latest version of TLSharp Packages
# More info: https://www.nuget.org/packages/TLSharp
task GetLatestTLSharpPackage {
    Find-Package -Name TLSharp -Provider Nuget -Source 'https://www.nuget.org/api/v2'
}
#endregion

#region Task to Update TLSharp Package if newer version is released
task UpdateTLSharpPackage {

    # Check current TLSharp Package version
    # Get TLSharp.Core.dll file properties
    $ProductionPath = Get-ChildItem -Path .\lib\ -Filter TLSharp.Core.dll -Recurse | Select-Object -Expand Directory
    $ProductionFolder = Split-Path $ProductionPath -Leaf
    [Version]$ProductVersion = ($ProductionFolder -Split "\.")[-4,-3,-2,-1] -Join "."
    Write-Output -InputObject ('ProductVersion {0}' -f $ProductVersion)

    # Check latest version TLSharpPackage
    $LatestPackage = Find-Package -Name TLSharp -Provider Nuget -Source 'https://www.nuget.org/api/v2'
    [Version]$LatestVersion = $LatestPackage.Version
    Write-Output -InputObject ('Latest Version {0}' -f $LatestVersion)

    #Download latest version when newer
    If ($LatestVersion -gt $ProductVersion) {

        Write-Output -InputObject ('Newer version {0} available' -f $LatestVersion)
        #Install TLSharp package to temp folder
        $LatestPackage | Install-Package -Force -Confirm:$false | Out-Null
        $LatestPackage = Get-Package -Name TLSharp
        $LatestPath = Split-Path $LatestPackage.Source
        $LatestFolder = Split-Path $LatestPath -Leaf

        Write-Output -InputObject ('Remove current TLSharp binaries')
        Remove-Item -Path $ProductionFolder -Recurse -Force -Confirm:$false

        Write-Output -InputObject ('Copy TLSharp binaries to PSTelegramAPI Module')
        New-Item -Path ".\lib\${LatestFolder}" -ItemType Directory | Out-Null
        Get-ChildItem -Path $LatestPath -Filter *.dll -Recurse | Copy-Item -Destination ".\lib\${LatestFolder}"

    }
    else {
        Write-Output -InputObject ('Current local version {0}. Latest version {1}' -f $ProductVersion, $LatestVersion)
    }
}
#endregion

#region Task to Copy PowerShell Module files to output folder for release as Module
task CopyModuleFiles {

    # Copy Module Files to Output Folder
    if (-not (Test-Path .\output\PSTelegramAPI)) {

        $null = New-Item -Path .\output\PSTelegramAPI -ItemType Directory

    }

    #Copy-Item -Path '.\en-US\' -Filter *.* -Recurse -Destination .\output\PSTelegramAPI -Force
    Copy-Item -Path '.\lib\' -Filter *.* -Recurse -Destination .\output\PSTelegramAPI -Force
    Copy-Item -Path '.\public\' -Filter *.* -Recurse -Destination .\output\PSTelegramAPI -Force
    Copy-Item -Path '.\private\' -Filter *.* -Recurse -Destination .\output\PSTelegramAPI -Force
    Copy-Item -Path '.\tests\' -Filter *.* -Recurse -Destination .\output\PSTelegramAPI -Force

    #Copy Module Manifest files
    Copy-Item -Path @(
        '.\README.md'
        '.\PSTelegramAPI.psd1'
        '.\PSTelegramAPI.psm1'
    ) -Destination .\output\PSTelegramAPI -Force
}
#endregion

#region Task to run all Pester tests in folder .\tests
task Test {

    $OutputPath = New-Item '.\TestResults' -ItemType Directory -Force

    $PesterParams = @{
        Script = '.\Tests'
        OutputFile = "${OutputPath}\TestResults.PSTelegramAPI.xml"
        CodeCoverage = '.\PSTelegramAPI\*\*.ps1'
        CodeCoverageOutputFile = "${OutputPath}\CodeCoverage.PSTelegramAPI.xml"
    }

    $Result = Invoke-Pester @PesterParams -PassThru

    if ($Result.FailedCount -gt 0) {
        throw 'Pester tests failed'
    }

}
#endregion

#region Task to update the Module Manifest file with info from the Changelog in Readme.
task UpdateManifest {
    # Import PlatyPS. Needed for parsing README for Change Log versions
    Import-Module -Name PlatyPS

    # Find Latest Version in README file from Change log.
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    [regex]$regex = '\d\.\d\.\d'
    $Versions = $regex.Matches($MarkdownObject.ParseString($README).Children.Spans.Text) | foreach-object {$_.value}
    ($Versions | Measure-Object -Maximum).Maximum

    $manifestPath = '.\PSTelegramAPI.psd1'

    # Start by importing the manifest to determine the version, then add 1 to the Build
    $manifest = Test-ModuleManifest -Path $manifestPath
    [System.Version]$version = $manifest.Version
    [String]$newVersion = New-Object -TypeName System.Version -ArgumentList ($version.Major, $version.Minor, ($version.Build + 1))
    Write-Output -InputObject ('New Module version: {0}' -f $newVersion)

    # Update Manifest file with Release Notes
    $README = Get-Content -Path .\README.md
    $MarkdownObject = [Markdown.MAML.Parser.MarkdownParser]::new()
    $ReleaseNotes = ((($MarkdownObject.ParseString($README).Children.Spans.Text) -match '\d\.\d\.\d') -split ' - ')[1]

    #Update Module with new version
    Update-ModuleManifest -ModuleVersion $newVersion -Path .\PSTelegramAPI.psd1 -ReleaseNotes $ReleaseNotes
}
#endregion

#region Task to Publish Module to PowerShell Gallery
task PublishModule -If ($Configuration -eq 'Production') {
    Try {
        # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
        $params = @{
            Path        = ('{0}\PSTelegramAPI' -f $PSScriptRoot )
            NuGetApiKey = $ENV:NuGetApiKey
            ErrorAction = 'Stop'
        }
        Publish-Module @params
        Write-Output -InputObject ('PSTelegramAPI PowerShell Module version published to the PowerShell Gallery')
    }
    Catch {
        throw $_
    }
}
#endregion

#region Task clean up Output folder
task Clean {
    # Clean output folder
    if ((Test-Path .\output)) {

        Remove-Item -Path .\Output -Recurse -Force

    }
}
#endregion

#region Default Task. Runs Clean, Test, CopyModuleFiles Tasks
task . Clean, Test, CopyModuleFiles, PublishModule
#endregion