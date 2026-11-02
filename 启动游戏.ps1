param([switch]$Editor)
$ErrorActionPreference = 'Stop'
$engine = Join-Path $PSScriptRoot 'engine\godot-4.7.2\Godot_v4.7.2-stable_win64.exe'
$game = Join-Path $PSScriptRoot 'game'
if (-not (Test-Path -LiteralPath $engine)) { throw "Godot 不存在：$engine" }
$godotArgs = @('--path', $game)
if ($Editor) { $godotArgs += '--editor' }
& $engine @godotArgs
exit $LASTEXITCODE
