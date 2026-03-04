#!/bin/bash
# ... 前面 1-5 步保持不变 ...

# 定义 chown 包装器
CHOWN_BIN="sudo /usr/local/bin/chown_sw.sh"
# 获取当前绝对路径下的 data 目录
ABS_DATA_DIR="$(pwd)/data"

# 6. 确保数据目录存在并修复权限
echo "📂 正在准备数据目录并修复权限..."
# 注意：如果目录不存在，由于普通 mkdir 被禁，我们可能需要通过 dc_sw.sh 间接创建，
# 但通常你运行了 compose up 之后，docker 会以 root 身份自动创建这个目录。
# 所以我们重点放在“夺回所有权”：
$CHOWN_BIN 1000:1000 "$ABS_DATA_DIR"

# 7. 启动服务
echo "🚀 [2/2] 正在启动 OpenClaw 网关与 CLI..."
$COMPOSE_BIN up -d --remove-orphans openclaw-gateway openclaw-cli

# ==========================================
# ✨ 自动化配置修复补丁
# ==========================================
echo "⏳ 等待服务初始化 (5秒)..."
sleep 5

echo "⚙️  正在自动写入控制台安全配置..."
# 这里使用 -T 是因为在脚本中运行
$COMPOSE_BIN exec -T openclaw-cli openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true

echo "🔄 正在重启网关以应用配置..."
$COMPOSE_BIN restart openclaw-gateway
# ==========================================

echo "✅ 部署完成！"
echo "👉 现在请执行向导: sudo /usr/local/bin/dc_sw.sh exec -it openclaw-cli openclaw onboard"
