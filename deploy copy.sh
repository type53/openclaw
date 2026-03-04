# 第二步：启动核心服务 (Gateway + CLI)
echo "🚀 [2/2] 正在启动 OpenClaw 网关与 CLI..."
$COMPOSE_BIN up -d --remove-orphans openclaw-gateway openclaw-cli

# ==========================================
# 【新增】自动修复 Host 头跨域配置
# ==========================================
echo "⏳ 等待 CLI 容器就绪 (3秒)..."
sleep 3

echo "⚙️ 正在自动写入 Gateway 控制台跨域配置..."
# 直接调用 CLI 容器执行配置写入 (不需要加 -it，因为是脚本后台执行)
$DOCKER_BIN exec openclaw-cli openclaw config set gateway.controlUi.dangerouslyAllowHostHeaderOriginFallback true

echo "🔄 正在重启 Gateway 以应用新配置..."
$COMPOSE_BIN restart openclaw-gateway
# ==========================================

# 8. 清理悬空镜像 (Dangling images)
# ... 下面的代码保持不变 ...
