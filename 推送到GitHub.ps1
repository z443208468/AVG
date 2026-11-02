$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot
git lfs install
git push -u origin main
Write-Host ""
Write-Host "推送完成，可以关闭窗口。"
Read-Host "按回车退出"
