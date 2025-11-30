#!/usr/bin/env bash
set -euo pipefail

DEVICE="/dev/disk/azure/scsi1/lun0"   # 必要に応じて変更
PART="${DEVICE}-part1"
MOUNT_POINT="/opt"
FSTAB_BACKUP="/etc/fstab.$(date +%Y%m%d%H%M%S).bak"

echo "=== [1] デバイス確認: ${DEVICE} ==="
if [ ! -b "${DEVICE}" ]; then
  echo "エラー: デバイス ${DEVICE} が見つかりません。LUNやデバイス名を確認してください。" >&2
  exit 1
fi

# 既にパーティションがあれば中断（誤初期化防止）
if lsblk -no NAME "${DEVICE}" | grep -qE '^.+[0-9]$'; then
  echo "エラー: ${DEVICE} に既にパーティションが存在します。処理を中止します。" >&2
  lsblk "${DEVICE}"
  exit 1
fi

echo "=== [2] パーティション作成（単一 ext4 用） ==="
# GPT ラベル＋全領域を1パーティションで確保
parted -s "${DEVICE}" mklabel gpt
parted -s "${DEVICE}" mkpart primary ext4 0% 100%

# udev 反映待ち
sleep 5

echo "=== [3] ファイルシステム作成 (ext4) ==="
mkfs.ext4 -F "${PART}"

echo "=== [4] マウントポイント作成: ${MOUNT_POINT} ==="
mkdir -p "${MOUNT_POINT}"

echo "=== [5] UUID 取得 & /etc/fstab 更新 ==="
UUID=$(blkid -s UUID -o value "${PART}")
if [ -z "${UUID}" ]; then
  echo "エラー: UUID を取得できませんでした (${PART})" >&2
  exit 1
fi

echo "既存 /etc/fstab をバックアップ: ${FSTAB_BACKUP}"
cp /etc/fstab "${FSTAB_BACKUP}"

# /etc/fstab へ追記（ext4, nofail, discard 推奨）
# ※fstab に複数回追加しないよう既存行をチェック
if ! grep -q "${UUID}" /etc/fstab; then
  echo "UUID=${UUID} ${MOUNT_POINT} ext4 defaults,nofail,discard 1 2" >> /etc/fstab
fi

echo "=== [6] mount -a でマウント ==="
mount -a

echo "=== [7] 結果確認 ==="
lsblk
df -Th | grep "${MOUNT_POINT}" || echo "注意: ${MOUNT_POINT} がマウントされていない可能性があります。"

echo "完了: ${DEVICE} を初期化し ${MOUNT_POINT} にマウントしました。"
