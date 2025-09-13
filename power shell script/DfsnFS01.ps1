
#Variables
Start-Transcript -Path C:\result.txt
$pass = $args[0] #VMM argument
$sharename = $args[1] #VMM argument
$netbios = (Get-ADDomain -Identity (gwmi WIN32_ComputerSystem).Domain).NetBIOSName
$domain = (gwmi WIN32_ComputerSystem).Domain
$secpass = convertto-securestring $pass -asplaintext -force
$credential = New-Object System.Management.Automation.PsCredential -ArgumentList "$domain\Administrator", $secpass
$pcname = hostname

#DFSN Configuration
New-Item -Path C:\share\$sharename -Type Directory

#General DFS namespace
New-ADGroup -Name "DFSUsers" -GroupScope Global -DisplayName "DFS Users" -Credential $credential;
New-SmbShare -Path C:\share\$sharename -Name $sharename -FullAccess "$domain\Administrator" -ReadAccess "$domain\DFSUsers";
Set-SMBPathACL -ShareName $sharename;
New-DfsnRoot -TargetPath \\$pcname\$sharename -Path \\$netbios\$sharename -Type DomainV2 -EnableAccessBasedEnumeration $true -GrantAdminAccounts "$domain\Administrator" -Confirm:$false;
New-DfsReplicationGroup -GroupName DFSReplication -Confirm:$false -DomainName $domain;
New-DfsReplicatedFolder -GroupName DFSReplication -FolderName $sharename -DomainName $domain -Confirm:$false;
Add-DfsrMember -GroupName DFSReplication -ComputerName DFS-02P -Confirm:$false -DomainName $domain;
Add-DfsrMember -GroupName DFSReplication -ComputerName $pcname -Confirm:$false -DomainName $domain;
Add-DfsrConnection -SourceComputerName $pcname -GroupName DFSReplication -DestinationComputerName DFS-02P -DomainName $domain -Confirm:$false;
Set-DfsrMembership -GroupName DFSReplication -FolderName $sharename -ComputerName $pcname -PrimaryMember $true -ContentPath c:\share\$sharename -DomainName $domain -Force;
Set-DfsrMembership -GroupName DFSReplication -FolderName $sharename -ComputerName DFS-02P -PrimaryMember $false -ContentPath c:\share\$sharename -DomainName $domain -Force
Start-Sleep -Seconds 10
