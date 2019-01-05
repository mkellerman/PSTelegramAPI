
# Import TLSharp binaries.
$TLSharpDll = Get-ChildItem -Path $PSScriptRoot\lib\ -Filter TLSharp.Core.dll -Recurse
Import-Module -Name $TLSharpDll.FullName | Out-Null

#Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\private\*.ps1 -ErrorAction SilentlyContinue )

#Dot source the files.
Foreach ($import in @($Public + $Private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

Export-ModuleMember -Function $Public.Basename