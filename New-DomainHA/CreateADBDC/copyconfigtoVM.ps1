#copy config and packages

$username = "administrator"
$password = "P@ssw0rd!"
$secureStringPwd = $password | ConvertTo-SecureString -AsPlainText -Force 
$credentials = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $secureStringPwd



 #$session1 = New-PSSession -ComputerName "192.168.0.50" -Credential $credentials
 $session2 = New-PSSession -ComputerName "192.168.0.51" -Credential $credentials

 
 Copy-Item -ToSession $session2 -Path C:\Users\martin\Documents\GitHub\hyper-v\CreateADBDC\modules -Recurse -Destination "C:\Program Files\WindowsPowerShell\Modules" -Force

 Copy-Item -ToSession $session2 -Path C:\Users\martin\Documents\GitHub\hyper-v\CreateADBDC\CreateADBDC1\ -Recurse -Destination C:\ -Force