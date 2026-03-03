cat << 'EOF' > deploy.sh
#!/bin/bash
# =================================================================
# OpenClaw 自动化部署脚本 - ssw 专用版
# =================================================================

# 1. 定义 ssw 专用包装器路径 (核心：不依赖别名)
DOCKER_BIN="/usr/local/bin/d_sw.sh"
COMPOSE_BIN="/usr/local/bin/dc_sw.sh"

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

# 4. 强行恢复私有编排文件
if [ -f "$MY_COMPOSE_TEMPLATE" ]; then
    echo "🛠️  检测到私有配置模板，正在覆盖 $TARGET_COMPOSE..."
    cp "$MY_COMPOSE_TEMPLATE" "$TARGET_COMPOSE"
else
    echo "❌ 错误：未找到 $MY_COMPOSE_TEMPLATE"
    exit 1
fi

# 5. 确保数据目录存在 (由当前用户创建，无需 sudo)
if [ ! -d "$USER_DATA_DIR" ]; then
    echo "📂 正在创建数据目录..."
    mkdir -p "$USER_DATA_DIR"
fi

# 6. 重启服务 (关键：使用 ssw 包装器)
echo "🔄 正在启动容器..."
$COMPOSE_BIN up -d --build

# 7. 清理镜像 (注意：如果 ssw 未授权此命令则会跳过)
echo "🧹 尝试清理旧镜像..."
$DOCKER_BIN image prune -f 2>/dev/null || echo "⚠️  跳过镜像清理 (ssw 策略限制)"

echo "✅ [$(date +'%Y-%m-%d %H:%M:%S')] 部署成功！"
echo "----------------------------------------------------"
EOF

# 赋予权限
chmod +x deploy.sh
