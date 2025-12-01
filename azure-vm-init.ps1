# Azure VM の初期化を行うスクリプト
# カレントディレクトリのスクリプトを実行する。
# パラメータ
param (
    [string]$hradminpass,
    [string]$infrapass,
    [int]$withtempdisk = 0
)

# ファイアウォール無効
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# OSディスク拡張
# ドライブレターを指定（例：Cドライブ）
$driveLetter = 'C'
# 拡張可能な最大サイズを取得
$supportedSize = Get-PartitionSupportedSize -DriveLetter $driveLetter
# パーティションを最大サイズへ拡張
Resize-Partition -DriveLetter $driveLetter -Size $supportedSize.SizeMax

if ($withtempdisk){
    $disknum = 2
    $driveLetter = "E"
}else{
    $disknum=1
    $driveLetter = "D"
}

# ドライブレター を削除
$tempfile =  $env:temp + "\diskpart-"+(Get-Date).ToFileTime()+".txt"

@"
select volume $DriveLetter
remove
exit
"@ | set-content $tempfile
diskpart /s $tempfile

# ディスク初期化
Initialize-Disk -Number $disknum -PartitionStyle GPT
New-Partition -DiskNumber $disknum -UseMaximumSize -DriveLetter $driveLetter
Format-Volume -DriveLetter $driveLetter -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

# ローカルユーザー作成
& .\make-local-user.ps1 $hradminpass $infrapass

# 再起動後に実行するスクリプトを指定
$scriptPath = (get-childitem change-ws2022-lang-ja-step2.ps1).FullName
$cmd = "powershell.exe -ExecutionPolicy Bypass -File `"$scriptPath`""

$regPath = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce'
New-ItemProperty -Path $regPath -Name 'RunMyScriptOnce' -Value $cmd -PropertyType String -Force

# 日本語化 Step1
# スクリプトの中で再起動される。
& .\change-ws2022-lang-ja-step1.ps1
