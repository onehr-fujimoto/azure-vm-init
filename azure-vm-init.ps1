# Azure VM の初期化を行うスクリプト
# カレントディレクトリのスクリプトを実行する。
# パラメータ
param (
    [string]$hradminpass,
    [string]$infrapass
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

# DドライブがDVDの可能性があるため、Dドライブ割り当てを削除
# 1. CD/DVDドライブ（D:）のパーティション情報を取得
$partition = Get-Volume -DriveLetter D | Get-Partition
# 2. ドライブレター D: を削除
Remove-PartitionAccessPath -Partition $partition -AccessPath "D:\"

# ディスク初期化
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter D
Format-Volume -DriveLetter D -FileSystem NTFS -NewFileSystemLabel "Data" -Confirm:$false

# ローカルユーザー作成
& .\make-local-user.ps1 $hradminpass $infrapass

# 日本語化 Step1
# スクリプトの中で再起動される。
& .\change-ws2022-lang-ja-step1.ps1
