# Azure VM ローカルユーザー作成スクリプト

param (
    [string]$hradminpass,
    [string]$infrapass
)

#Initialize-Disk -Number 1 -PartitionStyle GPT
#New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter D
#Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false
#管理用ユーザー追加(hradmin)
$password = convertto-securestring $hradminpass -AsPlainText -Force
New-LocalUser -name hradmin -password $password -description "Admin User" -AccountNeverExpires -PasswordNeverExpires
Add-localgroupMember -group Administrators -Member hradmin 
#管理用ユーザー追加(hradmin2)
$password = convertto-securestring  $hradminpass -AsPlainText -Force
New-LocalUser -name hradmin2 -password $password -description "Admin User" -AccountNeverExpires -PasswordNeverExpires
Add-localgroupMember -group Administrators -Member hradmin2 
#管理用ユーザー追加(infrasupport)
#$password = convertto-securestring $infrapassword -AsPlainText -Force
#New-LocalUser -name infrasupport -password $password -description "Infra Support" -AccountNeverExpires -PasswordNeverExpires
#Add-localgroupMember -group Administrators -Member infrasupport 

