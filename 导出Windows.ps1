$ErrorActionPreference = 'Stop'
$engine = Join-Path $PSScriptRoot 'engine\godot-4.7.2\Godot_v4.7.2-stable_win64_console.exe'
$game = Join-Path $PSScriptRoot 'game'
$outputDirectory = Join-Path $PSScriptRoot 'dist\windows'
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
& $engine --headless --quiet --editor --path $game --import --log-file (Join-Path $outputDirectory 'import.log')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
& $engine --headless --quiet --path $game --export-release 'Windows Desktop' (Join-Path $outputDirectory 'AVGGame.exe') --log-file (Join-Path $outputDirectory 'export.log')
if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }
Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'licenses') -Destination $outputDirectory -Recurse -Force
exit 0
