function ConvertTo-FlatJson {
    # Will take an object, and any object property will be converted to json

    [cmdletbinding()]
    Param ([parameter(ValueFromPipeline)][object[]]$InputObject)
    Process {

        $Properties = $InputObject | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name

        ForEach ($Object in $InputObject) {
            ForEach ($Property in ($Object.PSObject.Properties.Where({ $_.TypeNameOfValue -eq 'System.Management.Automation.PSCustomObject' }))) {
                $Property.Value = $Property.Value | ConvertTo-Json -Compress
            }
        }

        Return $InputObject | Select-Object $Properties
    }

}