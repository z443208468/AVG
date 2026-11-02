param([switch]$Editor, [switch]$Smoke)
$ErrorActionPreference = 'Stop'
$engine = 'D:\CangqiStudio\Godot\Godot_v4.7.2-stable_win64_console.exe'
$game = Join-Path $PSScriptRoot 'game'
if (-not (Test-Path -LiteralPath $engine)) { throw "Godot 不存在：$engine" }
$godotArgs = @('--path', $game)
if ($Editor) { $godotArgs += '--editor' }
if ($Smoke) { $godotArgs += @('--headless', '--', '--smoke') }
& $engine @godotArgs
exit $LASTEXITCODE
