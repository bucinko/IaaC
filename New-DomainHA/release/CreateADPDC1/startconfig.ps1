$Credential = (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force)))
 Start-DscConfiguration -Wait -Force -Verbose `
     -ComputerName "localhost" `
     -Path C:\CreateADPDC1 `
     -Credential $Credential
     Restart-Computer -ComputerName $env:computername -Force

    