# Azure VM の初期化を行うスクリプト
# カレントディレクトリのスクリプトを実行する。
# パラメータ
param (
    [string]$hradminpass,
    [string]$infrapass
)

# ファイアウォール無効
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# ローカルユーザー作成
& .\make-local-user.ps1 $hradminpass $infrapass

# 日本語化 Step1
# スクリプトの中で再起動される。
& .\change-ws2022-lang-ja-step1.ps1
