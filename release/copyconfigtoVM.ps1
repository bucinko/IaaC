#copy config and packages

$username = "administrator"
$password = "P@ssw0rd!"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd



 $session1 = New-PSSession -ComputerName "192.168.0.50" -Credential $credentials
 #$session2 = New-PSSession -ComputerName "192.168.0.51" -Credential $credentials


  
 Copy-Item -ToSession $session1 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\modules -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules" -Force

 Copy-Item -ToSession $session1 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\CreateADPDC1 -Recurse -Destination C:\ -Force
 
 #Copy-Item -ToSession $session2 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\modules -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules" -Force

 #Copy-Item -ToSession $session2 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\CreateADBDC1 -Recurse -Destination C:\ -Force



 #copy config and packages

$username = "administrator"
$password = "P@ssw0rd!"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd



 $session1 = New-CimSession -ComputerName "192.168.0.50" -Credential $credentials
 $session2 = New-CimSession -ComputerName "192.168.0.51" -Credential $credentials
   Invoke-Command -Session $session1 -ScriptBlock  {
 $SafeModePW = 'P@ssw0rd!'


 $Credential = (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force)))
 Start-DscConfiguration -Wait -Force -Verbose `
     -ComputerName "localhost" `
     -Path C:\CreateADPDC1 `
     -Credential $Credential
     Restart-Computer -ComputerName $env:computername -Force

     }

     start-sleep -Seconds 400

Invoke-Command -Session $session2 -ScriptBlock  {
 $SafeModePW = 'P@ssw0rd!'
 $Credential = (New-Object System.Management.Automation.PSCredential ('development.local\Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force)))
 Start-DscConfiguration -Wait -Force -Verbose `
     -ComputerName "localhost" `
     -Path C:\CreateADBDC1 `
     -Credential $Credential
     Restart-Computer -ComputerName $env:computername -Force
     }

