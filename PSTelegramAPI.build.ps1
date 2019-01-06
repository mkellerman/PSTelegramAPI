<#
.Synopsis
	Build script (https://github.com/nightroman/Invoke-Build)
#>

param ($Configuration = 'Development')

#region use the most strict mode
Set-StrictMode -Version Latest
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

#region Task to run all Pester tests in folder .\tests
task Test {

    $OutputPath = New-Item -Path '.\TestResults' -ItemType Directory -Force -Verbose

    $PesterParams = @{
        Script = '.\Tests'
        OutputFile = "${OutputPath}\TestResults-PSTelegramAPI.xml"
        CodeCoverage = 'PSTelegramAPI\*\*.ps1'
        CodeCoverageOutputFile = "${OutputPath}\CodeCoverage-PSTelegramAPI.xml"
        CodeCoverageOutputFileFormat = 'JaCoCo'
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
    #Import-Module -Name PlatyPS

    $ManifestPath = '.\PSTelegramAPI\PSTelegramAPI.psd1'
    $ModuleManifest = Test-ModuleManifest -Path $ManifestPath
    [System.Version]$ManifestVersion = $ModuleManifest.Version
    Write-Output -InputObject ('Manifest Version  : {0}' -f $ManifestVersion)

    $PSGalleryModule = Find-Module -Name PSTelegramAPI -Repository PSGallery
    [System.Version]$PSGalleryVersion = $PSGalleryModule.Version
    Write-Output -InputObject ('PSGallery Version : {0}' -f $PSGalleryVersion)

    If ($PSGalleryVersion -ge $ManifestVersion) {

        [System.Version]$Version = New-Object -TypeName System.Version -ArgumentList ($PSGalleryVersion.Major, $PSGalleryVersion.Minor, ($PSGalleryVersion.Build + 1))
        Write-Output -InputObject ('Updated Version   : {0}' -f $Version)
        Update-ModuleManifest -ModuleVersion $Version -Path .\PSTelegramAPI\PSTelegramAPI.psd1 # -ReleaseNotes $ReleaseNotes

    }

}
#endregion

#region Task to Publish Module to PowerShell Gallery
task PublishModule -If ($Configuration -eq 'Production') {
    Try {

        # Publish to gallery with a few restrictions
        if(
            $env:BHModulePath -and
            $env:BHBuildSystem -ne 'Unknown' -and
            $env:BHBranchName -eq "master" -and
            $env:BHCommitMessage -match '!publish'
        )
        {

            # Build a splat containing the required details and make sure to Stop for errors which will trigger the catch
            $params = @{
                Path        = ".\PSTelegramAPI"
                NuGetApiKey = $ENV:NuGetApiKey
                ErrorAction = 'Stop'
            }
            Publish-Module @params
            Write-Output -InputObject ('PSTelegramAPI PowerShell Module version published to the PowerShell Gallery')

        }
        else
        {
            "Skipping deployment: To deploy, ensure that...`n" +
            "`t* You are in a known build system (Current: $ENV:BHBuildSystem)`n" +
            "`t* You are committing to the master branch (Current: $ENV:BHBranchName) `n" +
            "`t* Your commit message includes !deploy (Current: $ENV:BHCommitMessage)" |
                Write-Host
        }

    }
    Catch {
        throw $_
    }
}
#endregion

#region Default Task. Runs Test, UpdateManifest, PublishModule Tasks
task . Test, UpdateManifest, PublishModule
#endregion