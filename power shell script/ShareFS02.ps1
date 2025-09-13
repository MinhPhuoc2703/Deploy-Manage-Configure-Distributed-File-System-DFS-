#Variables
$sharename = $args[0] #VMM argument
$domain = (gwmi WIN32_ComputerSystem).Domain
#Create new share
New-Item -Path C:\share\$sharename -Type Directory
New-SmbShare -Path C:\share\$sharename -Name $sharename -FullAccess "$domain\Administrator"
Set-SMBPathAcl -ShareName $sharename


