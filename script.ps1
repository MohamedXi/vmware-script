$vcenterName = "NAME" #The host name or IP of the VCENTER
$username = Read-Host -Prompt "USERNAME" #Prompt for the user
$password = Read-Host -Prompt "PASSWORD"
$datastore = "DATASTORE"
$esxHostNumber = "NUMBER_OF_"
$template = "TEMPLATE_NAME"
$vmNumber = Read-Host -Prompt "NUMBER_OF_VM_TO_CLONE"
$customerFile = "FILE_NAME"
$futurVmName = "NAME_OF_VM{0}"

$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Credential.UserName+':'+$Credential.GetNetworkCredential().Password))
$head = @{
  'Authorization' = "Basic $auth"
}

$r = Invoke-WebRequest -Uri "SESSION_URI" -Method Post -Headers $head
$token = (ConvertFrom-Json $r.Content).value
$session = @{'vmware-api-session-id' = $token}

Function Create {
    1..$vmNumber | foreach {
        $vmName = $futurVmName -f $_
        $vm = Get-VM -Name $vmName
        if($vm) {
            Write-Host "Existing machines" -ForegroundColor Read
            exit
            Disconnect-VIServer -Confirm:$false
        } else {
            $hostNumber = get-random -Maximum $esxHostNumber ##Generate a name 
            $esx = (Get-VMHost)[$hostNumber]
            $esx | New-VM -Name $vmName -Template $template -Datastore $datastore -OSCustomizationSpec $spec -RunASync
        }
    }
}


Clear
Function Log {
    Do {
        Clear
        Get-Task | Where-Object { $_.name -eq "CloneVM_Task" -and $_.State -eq "Running"} | Format-Table
        sleep 10
        Clear
    } until ((Get-Task | Where-Object { $_.name -eq "CloneVM_Task" -and $_.State -eq "Running"}) -eq $Null)

    Function Start {
        1..$vmNumber | foreach {
            $vmName = futurVmName -f $_
            Start-VM -VM vmName
            sleep 3
        }
    }
}

Create
Log
Start

Write-Host "" -ForegroundColor Yellow
Disconnect-VIServer -Confirm:$false

#$r1 = Invoke-WebRequest -Uri "VM_LIST_URI" -Method Get -Headers $session
#$vms = (ConvertFrom-Json $r1.Content).value
#$vms

