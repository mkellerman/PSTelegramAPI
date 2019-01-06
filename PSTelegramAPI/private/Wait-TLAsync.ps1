
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

            Write-Warning "Wait-TLAsync: Error: $($AsyncTask.Exception.InnerException.Message)"

            If ($TimeToWait = [int]$AsyncTask.Exception.InnerException.TimeToWait.TotalSeconds) {
                Start-Sleep -Seconds $TimeToWait
            } Else {
                Throw $AsyncTask.Exception.InnerException.Message
            }

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