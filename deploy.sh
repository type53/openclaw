cat << 'EOF' > deploy.sh
#!/bin/bash
# =================================================================
# OpenClaw 自动化部署脚本 (基于 ssw 安全环境)
# 功能：自动拉取代码 + 强行应用私有 Compose 配置 + 重启服务
# =================================================================

# 1. 定义变量
USER_DATA_DIR="/data/user/clawuser/openclaw_data"
MY_COMPOSE_TEMPLATE="docker-compose_myself.yml"
TARGET_COMPOSE="docker-compose.yml"

echo "----------------------------------------------------"
echo "🚀 [$(date +'%Y-%m-%d %H:%M:%S')] 开始自动化部署流程..."

# 2. 进入目录
cd "$(dirname "$0")"

# 3. 从 GitHub 同步最新代码
echo "📥 正在拉取最新的 cabania 分支代码..."
git fetch origin cabania
git reset --hard origin/cabania

# 4. 核心逻辑：强行恢复私有编排文件
if [ -f "$MY_COMPOSE_TEMPLATE" ]; then
    echo "🛠️  检测到私有配置模板，正在覆盖 $TARGET_COMPOSE..."
    cp "$MY_COMPOSE_TEMPLATE" "$TARGET_COMPOSE"
else
    echo "❌ 错误：未找到 $MY_COMPOSE_TEMPLATE！请检查文件是否存在。"
    exit 1
fi

# 5. 环境预检：确保数据目录权限正确 (针对容器内 node 用户)
echo "🛡️  正在校验数据目录权限..."
if [ -d "$USER_DATA_DIR" ]; then
    # 使用 sudo 确保权限，因为 ssw 下某些目录可能属于 root 或特定 UID
    chown -R 1000:1000 "$USER_DATA_DIR"
else
    echo "⚠️  提示：数据目录 $USER_DATA_DIR 尚不存在，将由 Docker 自动创建。"
fi

# 6. 重启服务
echo "🔄 正在重新构建并启动 Docker 容器..."
# 这里会直接调用被 ssw 包装过的 docker-compose
docker-compose up -d --build

# 7. 清理无用的镜像
echo "🧹 正在清理旧的构建镜像..."
docker image prune -f

echo "✅ [$(date +'%Y-%m-%d %H:%M:%S')] 部署成功！"
echo "----------------------------------------------------"
EOF

# 赋予执行权限
chmod +x deploy.sh
