Import-Module ActiveDirectory


<### Instructions

Create Scheduled task to run under directory service account on the directory server.  Ensure ActiveDirectory tools are loaded
Set to run every 30 minutes
Will create a "Proxy CustomerShortName Computers" Universal security group, add all computer accounts for that specific customer to it, add the computers group to the Proxy CustomerShortName Users group.  This will enable the computers to process Group Policy




#>

$RootDomain = Get-AdDomain
$OriginalCustomerSearchBase = "OU=Customers," + $RootDomain.DistinguishedName

$AllProxyGroups = Get-ADGroup -filter * -SearchBase $OriginalCustomerSearchBase | ?{$_.name -like "Customer*computers"}

#$CustomerGroups = $AllProxyGroups[0]

foreach ($CustomerGroups in $AllProxyGroups) {


$ReplaceString = "CN=" + $CustomerGroups.name + ","
$SearchBase = $CustomerGroups.DistinguishedName -replace $ReplaceString

$CustomerComputers = Get-AdComputer -SearchBase $SearchBase -filter *


##### Find CustomerShortName

$CustomerShortName = $CustomerGroups.name -Replace " Computers",""
$CustomerShortName = $CustomerShortName -Replace "Customer ",""


### Set Customers Computers ExtensionAttribute15

$CustomerComputers | Set-AdComputer -replace @{extensionAttribute15=$CustomerShortName}


$ComputerGroupMembers = Get-AdGroupMember -Identity $CustomerGroups | select name




if ($CustomerComputers) {

    foreach ($Computer in $CustomerComputers) { 
                                                if ($ComputerGroupMembers.name -notcontains $computer.name) {Add-AdgroupMember -Identity $CustomerGroups.name -Members $Computer -ErrorAction Silentlycontinue}

                                            }





}
}