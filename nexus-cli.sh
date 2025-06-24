#!/bin/bash

set -e

echo "🧠 [Nexus CLI Setup] 启动 Nexus 网络 CLI 一键运行脚本..."

# 1. 检查依赖
echo "🔍 正在检查并安装必要依赖..."
if ! command -v docker &> /dev/null; then
    echo "🐳 Docker 未安装，正在安装..."
    apt update && apt install -y docker.io
    systemctl enable docker
    systemctl start docker
else
    echo "✅ 已检测到 Docker"
fi

if ! command -v curl &> /dev/null; then
    echo "🌐 安装 curl..."
    apt install -y curl
fi

# 2. 构建 Docker 镜像
BUILD_DIR="$HOME/nexus-docker"
IMAGE_NAME="nexus-cli"
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "📝 正在生成 Dockerfile..."

cat > Dockerfile <<EOF
FROM ubuntu:24.04

RUN apt update && apt install -y curl bash

RUN curl https://cli.nexus.xyz/ | sh

CMD ["/bin/bash"]
EOF

echo "🔨 正在构建 Docker 镜像（首次大约1-2分钟）..."
docker build -t $IMAGE_NAME .

# 3. 询问用户 Node ID
read -p "请输入您的 Node ID（如果没有，请先注册）: " NODE_ID

# 4. 启动 Nexus CLI 容器
echo "🚀 正在启动 Nexus CLI 并连接到网络..."
docker run -it --rm \
  -v ~/.nexus:/root/.nexus \
  $IMAGE_NAME \
  bash -c "source ~/.bashrc && nexus-network start --node-id $NODE_ID"
