# =================================================================
# 脚本 2: PushMine.ps1 - 提交并上传我的本地修改
# =================================================================

# 1. 显示当前状态，让你看一眼改了哪些文件
Write-Host "📋 当前修改状态：" -ForegroundColor Cyan
git status -s

# 2. 询问提交信息
$msg = Read-Host "💬 请输入本次修改的说明 (Commit Message)"
if (-not $msg) { $msg = "update: 小修小补" }

# 3. 执行标准三部曲
Write-Host "📦 正在暂存文件..."
git add .

Write-Host "💾 正在提交到本地仓库..."
git commit -m "$msg"

Write-Host "📤 正在推送到 GitHub (cabania 分支)..."
git push origin cabania

Write-Host "🎉 提交成功！代码已同步至云端。" -ForegroundColor Green
