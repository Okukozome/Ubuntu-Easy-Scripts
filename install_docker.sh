#!/bin/bash

# 脚本出错时立即退出
set -e

# 检查是否以 root/sudo 权限运行
if [ "$(id -u)" -ne 0 ]; then
  echo "🚫 请使用 sudo 权限运行此脚本" >&2
  exit 1
fi

echo "🚀 1/5：开始更新系统软件包..."
apt-get update

echo "🧹 2/5：卸载旧版本或冲突的 Docker 软件包..."
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do
  apt-get remove -y $pkg >/dev/null 2>&1 || true
done

echo "⚙️ 3/5：设置 Docker 的官方 APT 仓库..."
# 安装依赖
apt-get install -y ca-certificates curl
# 添加 Docker 的官方 GPG 密钥
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
# 添加仓库源
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

echo "📦 4/5：安装 Docker Engine 和 Docker Compose..."
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo "✅ 5/5：配置当前用户以非 root 权限运行 Docker..."
# 将当前登录的用户添加到 docker 组
if [ -n "$SUDO_USER" ]; then
  usermod -aG docker "$SUDO_USER"
fi

echo "🎉 Docker 安装成功！"
echo "🐳 正在运行 hello-world 容器进行验证..."
docker run hello-world

echo ""
echo "------------------------------------------------------------------"
echo "‼️ 重要提示 ‼️"
echo "为了使 docker 用户组权限生效，您需要退出当前 SSH 会话然后重新登录。"
echo "重新登录后，您可以直接运行 'docker ps' 和 'docker compose version' 来验证。"
echo "------------------------------------------------------------------"
