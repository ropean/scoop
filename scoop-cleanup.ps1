# scoop-cleanup.ps1
# 自动清理所有 Scoop 应用（排除 flyenv）

Write-Host "开始 Scoop 应用清理..." -ForegroundColor Green

# 方法1：直接解析 scoop list 的文本输出
$scoopOutput = scoop list | Out-String
$lines = $scoopOutput -split "`r?`n"

# 提取应用名称（跳过标题行）
$apps = @()
foreach ($line in $lines) {
    # 跳过空行和标题行
    if ($line.Trim() -eq "" -or $line -match "^-" -or $line -match "^Name\s+Version") {
        continue
    }
    
    # 提取应用名称（第一个单词）
    $appName = ($line -split '\s+')[0]
    if ($appName -and $appName -notmatch "^-" -and $appName -ne "Name") {
        $apps += $appName
    }
}

# 方法2：备选方案 - 使用 scoop export
if ($apps.Count -eq 0) {
    Write-Host "使用方法2获取应用列表..." -ForegroundColor Yellow
    $apps = scoop export | ConvertFrom-Json | Get-Member -MemberType NoteProperty | Select-Object -ExpandProperty Name
}

# 过滤掉 flyenv 和可能的空值
$appsToCleanup = $apps | Where-Object { 
    $_ -and $_ -ne "flyenv" -and $_ -ne "Name" -and $_ -notmatch "^-"
}

if ($appsToCleanup.Count -eq 0) {
    Write-Host "未找到需要清理的应用。" -ForegroundColor Yellow
    exit
}

Write-Host "找到以下应用进行清理:" -ForegroundColor Yellow
$appsToCleanup | ForEach-Object { Write-Host "  $_" }

# 确认操作
# $confirm = Read-Host "`n确定要清理以上 $($appsToCleanup.Count) 个应用吗？(y/N)"
# if ($confirm -ne 'y' -and $confirm -ne 'Y') {
#     Write-Host "操作已取消。" -ForegroundColor Red
#     exit
# }

# 逐个清理应用
$successCount = 0
$failCount = 0

foreach ($app in $appsToCleanup) {
    Write-Host "正在清理 $app ..." -ForegroundColor Cyan
    
    # 直接执行命令并捕获输出，同时实时显示
    $hasError = $false
    
    try {
        # 使用 Invoke-Expression 执行命令并捕获输出
        $output = Invoke-Expression "scoop cleanup $app -k 2>&1" | ForEach-Object {
            $line = $_.ToString()
            
            # 实时显示输出并检测错误
            if ($line -match "ERROR" -or $line -match "isn't installed" -or $line -match "failed" -or $line -match "not found") {
                $script:hasError = $true
                Write-Host $line -ForegroundColor Red
            } elseif ($line -match "WARN") {
                Write-Host $line -ForegroundColor Yellow
            } else {
                # 显示其他正常输出
                if ($line.Trim() -ne "") {
                    Write-Host $line
                }
            }
            
            # 返回原始行用于进一步处理
            return $line
        }
        
        # 检查是否有任何输出包含错误
        $errorLines = $output | Where-Object { 
            $_ -match "ERROR" -or $_ -match "isn't installed" -or $_ -match "failed" -or $_ -match "not found" 
        }
        
        if ($errorLines.Count -gt 0) {
            $hasError = $true
        }
        
    } catch {
        $hasError = $true
        Write-Host "执行命令时出错: $_" -ForegroundColor Red
    }
    
    # 检查是否真的有错误
    if ($hasError) {
        Write-Host "✗ $app 清理失败" -ForegroundColor Red
        $failCount++
    } else {
        Write-Host "✓ $app 清理完成" -ForegroundColor Green
        $successCount++
    }
    Write-Host "---"
}

Write-Host "清理完成！" -ForegroundColor Green
Write-Host "成功: $successCount 个应用" -ForegroundColor Green
if ($failCount -gt 0) {
    Write-Host "失败: $failCount 个应用" -ForegroundColor Red
    Write-Host "提示：对于全局安装的应用，请使用 scoop cleanup <app> -g -k" -ForegroundColor Yellow
}