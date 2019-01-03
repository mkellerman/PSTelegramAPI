
function Wait-TLAsync {

    [cmdletbinding()]
    Param ([parameter(ValueFromPipeline)][object]$InputObject)
    Process {

        While ($InputObject.Status.value__ -eq 1) { # WaitingForActivation
            Start-Sleep -Milliseconds 100
        }

        If ($InputObject.Status.value__ -eq 5) {
            Do { Start-Sleep -Milliseconds 100 } Until ($InputObject.Result)
        } Else {
            Throw $InputObject.Exception.InnerException.Message
            # Write-Warning "Async Status: $($InputObject.Status) [$($InputObject.Status.value__)]"
            # Write-Warning $InputObject.Exception.InnerException.Message
        }

        Return $InputObject

    }

}