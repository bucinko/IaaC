#copy config and packages

$username = "administrator"
$password = "P@ssw0rd!"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd



 $session1 = New-PSSession -ComputerName "192.168.0.50" -Credential $credentials
  $session2 = New-PSSession -ComputerName "192.168.0.51" -Credential $credentials


  
 Copy-Item -ToSession $session1 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\modules -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules" -Force

 Copy-Item -ToSession $session1 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\CreateADPDC1 -Recurse -Destination C:\ -Force
 
  Copy-Item -ToSession $session2 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\modules -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules" -Force

  Copy-Item -ToSession $session2 -Path C:\Users\martin\Documents\GitHub\hyper-v\New-DomainHA\release\CreateADBDC1 -Recurse -Destination C:\ -Force



 #copy config and packages

$username = "administrator"
$password = "P@ssw0rd!"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd



 $session1 = New-PSSession -ComputerName "192.168.0.50" -Credential $credentials
 $session2 = New-PSSession -ComputerName "192.168.0.51" -Credential $credentials
   Invoke-Command -Session $session1 -ScriptBlock  {

     C:\CreateADPDC1\startconfig.ps1
     Restart-Computer -ComputerName $env:computername -Force

     }

     start-sleep -Seconds 400

Invoke-Command -Session $session2 -ScriptBlock  {
  
     

     C:\CreateADBDC1\startconfig.ps1
     Restart-Computer -ComputerName $env:computername -Force

     }

     

