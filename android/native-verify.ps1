param(
  [string]$NdkRoot = "D:\\Android\\Sdk\\ndk\\28.0.12433566",
  [string]$ScanDirs = "app/src/main/jniLibs;vpnLib/src/main/jniLibs"
)

$ErrorActionPreference = 'Stop'
$llvm = Join-Path $NdkRoot 'toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-readelf.exe'
if (!(Test-Path $llvm)) { throw "llvm-readelf not found at $llvm" }

$dirs = $ScanDirs -split ';'
foreach ($dir in $dirs) {
  $abs = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) $dir
  if (!(Test-Path $abs)) { continue }
  Get-ChildItem -Recurse -Include *.so $abs | ForEach-Object {
    $p = $_.FullName
    Write-Host "=== $p"
    & $llvm -W -l $p | Select-String -Pattern 'MaxPageSize| Align' | ForEach-Object { $_.Line }
  }
}





