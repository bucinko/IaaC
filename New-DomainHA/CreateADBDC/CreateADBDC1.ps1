  
  configuration CreateADBDC1

{

    param
    (    
         [Parameter(Mandatory)]
         [String]$DomainName,
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred 
        #[Parameter(Mandatory)]
       # [pscredential]$NewADUserCred,
       # [Parameter(Mandatory)]
       # [string]$NewADUser
    )
   Import-DscResource -ModuleName xActiveDirectory, PSDesiredStateConfiguration,xNetworking,xPendingReboot
    $Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
    $InterfaceAlias=$($Interface.Name)

  
  Node $AllNodes.NodeName
    {   

         LocalConfigurationManager            
       {            
          ActionAfterReboot = 'ContinueConfiguration'            
          ConfigurationMode = 'ApplyOnly'            
          RebootNodeIfNeeded = $true            
       }

         xDnsServerAddress DnsServerAddress
        {
            Address        = '192.168.0.50'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        xWaitForADDomain DscForestWait
        {
            DomainName = $Node.DomainName
            DomainUserCredential = $domaincred
        RetryCount = $Node.RetryCount
            RetryIntervalSec = $Node.RetryIntervalSec
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        xADDomainController SecondDC
        {
            DomainName = $Node.DomainName
            DomainAdministratorCredential = $domaincred
            SafemodeAdministratorPassword = $safemodeAdministratorCred
            DependsOn = "[xWaitForADDomain]DscForestWait"
        }
    }
    }


 
 $ConfigData = @{
    AllNodes = @(
        @{
            Nodename = "localhost"
            DomainName = "development.local"
            PSDscAllowPlainTextPassword = $true
            RetryCount = 20
            RetryIntervalSec = 30
        }

         
    )
} 

$SafeModePW = 'P@ssw0rd!'
$NewADUser = 'sysadmin'
 

CreateADBDC1 `
 -configurationData $ConfigData `
   -DomainName "development.local" `
    -safemodeAdministratorCred (New-Object System.Management.Automation.PSCredential ('guest', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
    -domainCred (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
 