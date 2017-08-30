 
configuration CreateADPDC1

{

    param
    (    

         [Parameter(Mandatory)]
         [String]$DomainName,
        [Parameter(Mandatory)]
        [pscredential]$safemodeAdministratorCred,
        [Parameter(Mandatory)]
        [pscredential]$domainCred 
     
    )
    Import-DscResource -ModuleName xActiveDirectory,PSDesiredStateConfiguration,xNetworking,xPendingReboot
    $Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
    $InterfaceAlias=$($Interface.Name)

  
    Node $AllNodes.NodeName
    {
        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature DNS
        {
            Ensure = "Present"
            Name = "DNS"
        }

        Script EnableDNSDiags
        {
      	    SetScript = {
                Set-DnsServerDiagnostics -All $true
                Write-Verbose -Verbose "Enabling DNS client diagnostics"
            }
            GetScript =  { @{} }
            TestScript = { $false }
            DependsOn = "[WindowsFeature]DNS"
        }

        WindowsFeature DnsTools
        {
            Ensure = "Present"
            Name = "RSAT-DNS-Server"
            DependsOn = "[WindowsFeature]DNS"
        }

        xDnsServerAddress DnsServerAddress
        {
            Address        = '127.0.0.1'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
            DependsOn = "[WindowsFeature]DNS"
        }

        

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
            DependsOn="[WindowsFeature]DNS"
        }

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSTools"
        }

        xADDomain FirstDS
        {
            DomainName = $DomainName
            DomainAdministratorCredential = $DomainCred
            SafemodeAdministratorPassword = $DomainCred
           
            DependsOn = @("[WindowsFeature]ADDSInstall")
        }

        xPendingReboot RebootAfterPromotion{
            Name = "RebootAfterPromotion"
            DependsOn = "[xADDomain]FirstDS"
        }
          xPendingReboot PreTest{
            Name = "Check for a pending reboot before changing anything"
        }
 
        LocalConfigurationManager{
            RebootNodeIfNeeded = $True
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
 

CreateADPDC1 `
 -configurationData $ConfigData `
   -DomainName "development.local" `
    -safemodeAdministratorCred (New-Object System.Management.Automation.PSCredential ('guest', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
    -domainCred (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
    #-NewADUserCred (New-Object System.Management.Automation.PSCredential ($NewADUser, (ConvertTo-SecureString $SafeModePW -AsPlainText -Force))) `
  #  -NewADUser $NewADUser

#Start-DscConfiguration -Wait -Force -Verbose -ComputerName "192.168.0.50" -Path $PSScriptRoot\AssertHADC -Credential $localcred
#Start-DscConfiguration -Wait -Force -Verbose -ComputerName "192.168.0.51" -Path $PSScriptRoot\AssertHADC -Credential $localcred

#$SafeModePW = 'P@ssw0rd!'
#$Credential = (New-Object System.Management.Automation.PSCredential ('Administrator', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force)))
#Start-DscConfiguration -Wait -Force -Verbose `
  #  -ComputerName "192.168.0.50" `
  #  -Path $PSScriptRoot\CreateADPDC `
  #  -Credential $Credential


#Start-DscConfiguration -Wait -Force -Verbose `
 #   -ComputerName "192.168.0.51" `
 #  -Path $PSScriptRoot\AssertHADC `
  #  -Credential $Credential