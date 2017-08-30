Configuration CreateADReplicaDC 
{ 
   param 
    ( 
      

      [Parameter(Mandatory)]
         [String]$DomainName,
       # [Parameter(Mandatory)]
       # [System.Management.Automation.PSCredential]$Admincreds,
        [Parameter(Mandatory)]
        [System.Management.Automation.PSCredential]$SafemodeAdminCreds,
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )
    Import-DscResource -ModuleName xActiveDirectory, xPendingReboot
   
    Node $AllNodes.NodeName
    {
       LocalConfigurationManager            
       {            
          ActionAfterReboot = 'ContinueConfiguration'            
          ConfigurationMode = 'ApplyOnly'            
          RebootNodeIfNeeded = $true            
       }

       WindowsFeature RSAT 
       {
          Ensure = "Present"
          Name = "RSAT"
       }

       WindowsFeature ADDSInstall 
       { 
          Ensure = "Present" 
          Name = "AD-Domain-Services"
       }

       xWaitForADDomain DscForestWait 
       { 
          DomainName = $Node.DomainName 
          DomainUserCredential= $Node.DomainCreds
          RetryCount = $Node.RetryCount
          RetryIntervalSec = $Node.RetryIntervalSec
          DependsOn = "[WindowsFeature]ADDSInstall"
      }

      xADDomainController ReplicaDC 
      { 
         DomainName = $Node.DomainName 
         DomainAdministratorCredential = $Node.DomainCreds 
         SafemodeAdministratorPassword = $Node.SafeModeAdminCreds
         DatabasePath = "C:\NTDS"
         LogPath = "C:\NTDS"
         SysvolPath = "C:\SYSVOL"
         DependsOn = "[xWaitForADDomain]DScForestWait"
      }

      xPendingReboot Reboot1
      { 
         Name = "RebootServer"
         DependsOn = "[xADDomainController]ReplicaDC"
      }
   }
}

$ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "*"
            DomainName = "development.local"
            PSDscAllowPlainTextPassword = $true
            RetryCount = 20
            RetryIntervalSec = 30
        }

         
    )
} 

$SafeModePW = 'P@ssw0rd!'
$NewADUser = 'sysadmin'
 

CreateADReplicaDC ` 
 -configurationData $ConfigData `
  # -DomainName "development.local" `
    -safemodeAdministratorCreds (New-Object System.Management.Automation.PSCredential ('guest', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
    -domainCreds (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
 