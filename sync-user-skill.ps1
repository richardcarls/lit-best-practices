#Requires -Version 7
# Syncs SKILL.md and rules/ to the user-level Claude skills directory so the
# skill is available globally across all projects, not just this repo.

$src = $PSScriptRoot
$dst = Join-Path $env:USERPROFILE '.claude\skills\lit-best-practices'

New-Item -ItemType Directory -Path (Join-Path $dst 'rules') -Force | Out-Null

Copy-Item -Path (Join-Path $src 'SKILL.md') -Destination $dst -Force
Copy-Item -Path (Join-Path $src 'rules\*.md') -Destination (Join-Path $dst 'rules') -Force

Write-Host "Synced lit-best-practices -> $dst"
