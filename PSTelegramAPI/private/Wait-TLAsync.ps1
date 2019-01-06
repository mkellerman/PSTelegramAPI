
function Wait-TLAsync {

    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [System.Threading.Tasks.Task]$AsyncTask,
        [switch]$PassThru
    )

    Process {

        While ($AsyncTask.Status -eq 'WaitingForActivation') {
            Start-Sleep -Milliseconds 100
        }

        If ($AsyncTask.IsFaulted -or $AsyncTask.IsCanceled) {

            If ([int]$TimeToWait = $AsyncTask.Exception.InnerException.TimeToWait.TotalSeconds) {
                Write-Warning "Wait-TLAsync: Flood Prevention (TimeToWait: ${TimeToWait})."
                Start-Sleep -Seconds $TimeToWait
                Return $False
            }

            Throw $AsyncTask.Exception.InnerException.Message

        }

        If ($AsyncTask.IsCompleted) {
            While (-Not $AsyncTask.Result) { Start-Sleep -Milliseconds 100 }
        }

        If ($PassThru) {
            Return $AsyncTask
        } Else {
            Return $AsyncTask.Result
        }

    }

}