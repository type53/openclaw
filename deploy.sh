# cat << 'EOF' > deploy.sh
#!/bin/bash
# =================================================================
# OpenClaw 自动化部署脚本 (适配 Docker Sandbox 架构)
# =================================================================

# 1. 定义 ssw 专用包装器路径
DOCKER_BIN="sudo /usr/local/bin/d_sw.sh"
COMPOSE_BIN="sudo /usr/local/bin/dc_sw.sh"

# 数据目录
USER_DATA_DIR="/data/user/clawuser/openclaw_data"
# 你的私有配置文件
MY_COMPOSE_TEMPLATE="docker-compose_myself.yml"
# 最终运行的文件
TARGET_COMPOSE="docker-compose.yml"

echo "----------------------------------------------------"
echo "🚀 [$(date +'%Y-%m-%d %H:%M:%S')] 开始自动化部署流程..."

# 2. 进入脚本所在目录
cd "$(dirname "$0")"

# 【新增安全措施】在拉取代码前，先备份你的私有配置
# 防止 git reset --hard 意外把你的配置文件冲掉（如果它被误提交过）
# if [ -f "$MY_COMPOSE_TEMPLATE" ]; then
#     echo "💾 备份私有配置..."
#     cp "$MY_COMPOSE_TEMPLATE" "/tmp/openclaw_config_backup.yml"
# fi

# 3. 从 GitHub 同步最新代码
echo "📥 正在拉取最新的 cabania 分支代码..."
git fetch origin cabania
git reset --hard origin/cabania

# 【恢复配置】从备份恢复（如果本地文件被 git 覆盖了）
# if [ -f "/tmp/openclaw_config_backup.yml" ]; then
#     mv "/tmp/openclaw_config_backup.yml" "$MY_COMPOSE_TEMPLATE"
# fi

# 4. 强行应用私有编排文件
if [ -f "$MY_COMPOSE_TEMPLATE" ]; then
    echo "🛠️  应用私有配置 -> $TARGET_COMPOSE"
    cp "$MY_COMPOSE_TEMPLATE" "$TARGET_COMPOSE"
else
    echo "❌ 错误：未找到 $MY_COMPOSE_TEMPLATE，无法部署！"
    exit 1
fi

# 5. 停止旧服务
# 保留镜像缓存，加快构建速度
# 只有当你确实需要彻底重装时，才手动加 --rmi all
echo "🛑 停止当前服务..."
$COMPOSE_BIN down --remove-orphans

# 6. 确保数据目录存在
if [ ! -d "$USER_DATA_DIR" ]; then
    echo "📂 创建数据目录: $USER_DATA_DIR"
    mkdir -p "$USER_DATA_DIR"
fi

# 7. 【关键修改】分步构建与启动
# ----------------------------------------------------------------
# 第一步：构建沙箱镜像
# 因为我们在 compose 里加了 profiles: ["tools"]，普通的 up 命令不会构建它们
# 所以这里必须显式构建。
echo "🏗️  [1/2] 正在构建沙箱环境 (这可能需要几分钟)..."
# 注意：如果 ssw 包装器不支持 --profile 参数，请尝试使用:
# COMPOSE_PROFILES=tools $COMPOSE_BIN build
$COMPOSE_BIN --profile tools build

if [ $? -ne 0 ]; then
    echo "❌ 沙箱构建失败，停止部署。"
    exit 1
fi

# 第二步：启动核心服务 (Gateway + CLI)
# 这里不需要 --profile tools，因为我们只想运行网关，不想运行构建器容器
echo "🚀 [2/2] 正在启动 OpenClaw 网关..."
$COMPOSE_BIN up -d --remove-orphans

# 8. 清理悬空镜像 (Dangling images)
# 只清理构建过程中产生的无用中间层，不删现有镜像
echo "🧹 清理无用数据..."
$DOCKER_BIN image prune -f 2>/dev/null || echo "⚠️  跳过镜像清理"

echo "✅ [$(date +'%Y-%m-%d %H:%M:%S')] 部署成功！"
echo "   - 网关端口: 18789"
echo "   - 检查日志: $COMPOSE_BIN logs -f openclaw-gateway"
echo "----------------------------------------------------"

# 赋予自身执行权限
chmod +x ./deploy.sh

EOF
