# =================================================================
# 脚本 1: SyncUpstream.ps1 - 同步原作者最新代码
# =================================================================

$remoteUrl = "https://github.com/openclaw/openclaw.git" # 请确保这是正确的原作者地址

# 1. 确保 upstream 远程仓库存在
$remotes = git remote
if ($remotes -notcontains "upstream") {
    Write-Host "⚠️ [INFO] 未检测到 upstream，正在添加原作者仓库..." -ForegroundColor Yellow
    # 替换为原作者的真实地址
    git remote add upstream $remoteUrl
}

Write-Host "🔄 [STEP 1] 正在切换到 main 分支并拉取作者更新..." -ForegroundColor Cyan
git checkout main
git pull upstream main

Write-Host "📤 [STEP 2] 正在同步本地 main 到你的 GitHub 仓库 (origin)..." -ForegroundColor Cyan
git push origin main

Write-Host "🧬 [STEP 3] 正在尝试将更新合并到 cabania 分支..." -ForegroundColor Cyan
git checkout cabania

# 尝试合并。如果没有冲突，会自动成功。
if (git merge main) {
    Write-Host "✅ [SUCCESS] 合并成功！" -ForegroundColor Green
}
else {
    Write-Host "❗ [ERROR] 检测到冲突！" -ForegroundColor Red
    Write-Host "请选择处理方式:" -ForegroundColor Yellow
    Write-Host "1. 以作者版本为准 (强制覆盖我的修改)"
    Write-Host "2. 手动去 VS Code 里解决"
    $choice = Read-Host "请输入编号 [1/2]"
    
    if ($choice -eq "1") {
        Write-Host "[INFO] 已采用作者版本完成合并。" -ForegroundColor Green
        git merge --abort
        git merge -X theirs main
    }
    else {
        Write-Host "[WAIT] 请在 VS Code 中手动解决冲突，处理完后记得执行 commit。" -ForegroundColor Yellow
        exit
    }
}

Write-Host "🚀 [STEP 4] 正在推送合并后的 cabania 到 GitHub..." -ForegroundColor Cyan
git push origin cabania
Write-Host "✨ 全部同步任务已完成！" -ForegroundColor Green
