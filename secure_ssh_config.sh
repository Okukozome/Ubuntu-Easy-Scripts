#!/bin/bash

CONFIG_FILE="/etc/ssh/sshd_config"

declare -A SSH_SETTINGS
SSH_SETTINGS=(
  ["PasswordAuthentication"]="no"
  ["ChallengeResponseAuthentication"]="no"
  ["KbdInteractiveAuthentication"]="no"
  ["GSSAPIAuthentication"]="no"
  ["PubkeyAuthentication"]="yes"
  ["AuthenticationMethods"]="publickey"
)

BACKUP_FILE="${CONFIG_FILE}.bak_$(date +%F-%T)"
cp "$CONFIG_FILE" "$BACKUP_FILE"
echo "已备份原配置文件到 $BACKUP_FILE"

sed -iE '/^\s*Include\s+/s/^/#/' "$CONFIG_FILE"

for key in "${!SSH_SETTINGS[@]}"; do
  value="${SSH_SETTINGS[$key]}"
  correct_line="$key $value"

if ! grep -qE "^\s*$correct_line\s*$" "$CONFIG_FILE"; then
  sed -iE "/^\s*$key\s+/s/^/#/" "$CONFIG_FILE"
  echo "$correct_line" >> "$CONFIG_FILE"
fi
done

echo "请手动重启SSH服务以使配置生效："
echo "systemctl restart sshd"
