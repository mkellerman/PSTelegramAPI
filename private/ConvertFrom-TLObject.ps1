function ConvertFrom-TLObject {

    [cmdletbinding()]
    Param (
        [parameter(ValueFromPipeline)]
        [object[]]$InputObject,
        [switch]$Flatten = $False
    )
    Process {

        $nInputObject = New-Object System.Collections.ArrayList
        ForEach ($Object in $InputObject) {

            $nObject = @{}
            ForEach ($Property in $Object.PSObject.Properties) {

                Switch ($Property.Name) {

                    'Id' {

                        Switch ($Object.GetType().Name) {
                            'TLMessage'        { $nObject['MessageId'] = [int64]$Property.Value }
                            'TLMessageService' { $nObject['MessageId'] = [int64]$Property.Value }
                            Default            { $nObject['ContextId'] = [int64]$Property.Value }
                        }

                    }

                    'Date'     { $nObject['Date']     = If ($Property.Value -is [int]) { (Get-Date '1970-01-01').AddSeconds($Property.Value) } Else { $Null } }

                    'EditDate' { $nObject['EditDate'] = If ($Property.Value -is [int]) { (Get-Date '1970-01-01').AddSeconds($Property.Value) } Else { $Null } }

                    'Peer' {
                        If (($Property.Value).UserId)    { $nObject['ContextId'] = ($Property.Value).UserId;    $nObject['ContextType'] = 'User'    }
                        If (($Property.Value).ChatId)    { $nObject['ContextId'] = ($Property.Value).ChatId;    $nObject['ContextType'] = 'Chat'    }
                        If (($Property.Value).ChannelId) { $nObject['ContextId'] = ($Property.Value).ChannelId; $nObject['ContextType'] = 'Channel' }
                    }

                    'ToId' {
                        $nObject['ToId'] = $Property.Value | ConvertTo-Json -Compress -Depth 5
                        If (($Property.Value).UserId)    { $nObject['ToId'] = ($Property.Value).UserId;    $nObject['ToType'] = 'User'    }
                        If (($Property.Value).ChatId)    { $nObject['ToId'] = ($Property.Value).ChatId;    $nObject['ToType'] = 'Chat'    }
                        If (($Property.Value).ChannelId) { $nObject['ToId'] = ($Property.Value).ChannelId; $nObject['ToType'] = 'Channel' }
                    }

                    'Entities' {
                        $nObject[$Property.Name] = $Property.Value | ? { $_ } | ForEach-Object {

                                $Entities = $PSItem | Select-Object @{n='MessageId'; e={$Object.Id}}, @{n='Type'; e={$_.GetType().Name}}, *, @{n='Value'; e={$Object.Message.SubString($_.Offset, $_.Length)}}
                                $Properties = 'Constructor', 'MessageId', 'Type', 'Offset', 'Length', 'Value'
                                $OtherAttributes = $Entities.PSObject.Properties.Name.Where({$Properties -notcontains $_})
                                If ($OtherAttributes) {
                                    $Entities | Select-Object $Properties | Add-Member -MemberType NoteProperty -Name OtherAttributes -Value ($Entities | Select-Object $OtherAttributes | ConvertTo-Json -Compress -Depth 10) -PassThru
                                } Else {
                                    $Entities | Select-Object $Properties
                                }

                            }
                    }

                    'Media' {

                        $nObject[$Property.Name] = $Property.Value | ? { $_ } | ForEach-Object {

                            $Caption = $PSItem.Caption
                            $MediaType = $PSItem.PSObject.Properties.Name.Where({ 'Constructor', 'Caption' -notcontains $_  })

                            $Media = $PSItem."$MediaType" | Select-Object @{n='MessageId'; e={$Object.Id}}, @{n='MediaType'; e={$MediaType}}, @{n='Caption';e={$Caption}}, @{n='Date';e={ If ($PSItem.Date -is [int]) { (Get-Date '1970-01-01').AddSeconds($PSItem.Date) } }}, * -Exclude Date

                            $Properties = 'Constructor','MessageId','MediaType','Id','AccessHash','Caption','Date','MimeType','Size','Url','SiteName','Type','Title','Description','Author'
                            $OtherAttributes = $Media.PSObject.Properties.Name.Where({$Properties -notcontains $_})
                            $Media | Select-Object $Properties | Add-Member -MemberType NoteProperty -Name OtherAttributes -Value ($Media | Select-Object $OtherAttributes | ConvertTo-Json -Compress -Depth 10) -PassThru

                        }

                    }

                    'AccessHash' {
                        $nObject[$Property.Name] = [Int64]$Property.Value
                    }

                    'BotInfoVersion' {
                        $nObject[$Property.Name] = [Int64]$Property.Value
                    }

                    Default {

                        Switch ($Property.TypeNameOfValue) {
                            'System.Int32'   { $nObject[$Property.Name] = [Int64]$Property.Value }
                            'System.String'  { $nObject[$Property.Name] = $Property.Value }
                            'System.Boolean' { $nObject[$Property.Name] = $Property.Value }
                            Default {
                                $nObject[$Property.Name] = $Property.Value | ConvertTo-Json -Compress -Depth 5
                            }
                        }

                    }

                }

            }

            If ($Flatten) {
                [PSCustomObject]$nObject | ConvertTo-FlatJson | % { $nInputObject.Add($_) } | Out-Null
            } Else {
                [PSCustomObject]$nObject | % { $nInputObject.Add($_) } | Out-Null
            }

        }

        Return $nInputObject

    }
}