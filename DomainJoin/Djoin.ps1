Configuration Djoin
{  


    param
    (    

         [Parameter(Mandatory)]
         [String]$dscDomainName,
         [Parameter(Mandatory)]
         [pscredential]$dscDomainAdmin 

    )
    Import-DscResource -ModuleName PSDesiredStateConfiguration,xNetworking
    Import-DscResource -ModuleName 'xDSCDomainjoin'
    $Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
    $InterfaceAlias=$($Interface.Name)
 
    node $AllNodes.NodeName
    {


         xDnsServerAddress DnsServerAddress
        {
            Address        = '192.168.0.50'
            InterfaceAlias = $InterfaceAlias
            AddressFamily  = 'IPv4'
        }

        xDSCDomainjoin JoinDomain
        {
            Domain = $dscDomainName
            Credential = $dscDomainAdmin
        }
    }
}

$ConfigData = @{
    AllNodes = @(
        @{
            NodeName = "localhost"
            PSDscAllowPlainTextPassword = $True
            PSDscAllowDomainUser = $True
        }
    )
}
$SafeModePW = 'P@ssw0rd!'
$dscDomainAdmin = (New-Object System.Management.Automation.PSCredential ('administrator@development.local', (ConvertTo-SecureString $SafeModePW -AsPlainText -Force)))
 $dscDomainName =  "development.local"

 Djoin -configurationData $ConfigData `
 -dscDomainName $dscDomainName  `
 -dscDomainAdmin $dscDomainAdmin

  

 