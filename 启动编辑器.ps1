$ErrorActionPreference = 'Stop'
$engine = Join-Path $PSScriptRoot 'engine\godot-4.7.2\Godot_v4.7.2-stable_win64.exe'
& $engine --editor --single-window --accessibility always --path (Join-Path $PSScriptRoot 'game')
exit $LASTEXITCODE
