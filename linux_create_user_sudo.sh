#!/bin/bash
# 引数で指定されたユーザーを作成、sudoersに追加し、公開鍵をauthorized_keysに入れる
# 公開鍵は stdin で渡す
#使用例
#   ※事前にscpなどで対象サーバーにスクリプトをコピーする
#   echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILkQkagKLrw+vdXpo19B68N8le4gCgRMRhtcKz8kUQ/L hradmin" | ssh host sudo sh ./linux_create_user_sudo.sh hradmin
#

# 引数チェック
if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <username>" >&2
  exit 1
fi

USERNAME="$1"

set -e

if ! id $USERNAME &>/dev/null; then
    useradd -m -s /bin/bash "$USERNAME"
fi

HOMEDIR=$(getent passwd "$USERNAME" | cut -d: -f6)
SSH_DIR="$HOMEDIR/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"
touch "$AUTH_KEYS"
chmod 600 "$AUTH_KEYS"

cat >> "$AUTH_KEYS"

chown -R "$USERNAME:$USERNAME" "$SSH_DIR"

echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/91-$USERNAME"
