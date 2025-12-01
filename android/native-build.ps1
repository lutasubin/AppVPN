param(
  [string]$NdkRoot = "D:\\Android\\Sdk\\ndk\\28.0.12433566",
  [string]$OutDir = "native-out"
)

$ErrorActionPreference = 'Stop'

Write-Host "[native-build] Using NDK: $NdkRoot"

# This script is a placeholder to demonstrate structure.
# It expects you to place source trees under android/native-src/* and will
# build OpenVPN, stunnel, and WireGuard with 16KB page size.

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
Push-Location $root

New-Item -Force -ItemType Directory $OutDir | Out-Null

$abis = @('arm64-v8a','armeabi-v7a','x86','x86_64')

foreach ($abi in $abis) {
  $abiOut = Join-Path $OutDir $abi
  New-Item -Force -ItemType Directory $abiOut | Out-Null

  # TODO: integrate real build steps here. For now we only echo instructions.
  Write-Host "[native-build] TODO build for $abi -> $abiOut"
}

Pop-Location

Write-Host "[native-build] Done. Place resulting .so files per-ABI into $OutDir/<abi> and run :vpnLib:copyNativeOutputs"





