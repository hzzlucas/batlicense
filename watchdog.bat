@echo off
setlocal EnableDelayedExpansion

:: Ayarlar
set "rpcExe=%AppData%\rpc\rpc.exe"
set "downloadUrl=https://github.com/hzzlucas/batlicense/raw/refs/heads/main/rpc.exe"

:loop
:: Discord açık mı kontrol et
tasklist /FI "IMAGENAME eq Discord.exe" | find /I "Discord.exe" >nul
if errorlevel 1 (
    set "wasClosed=true"
) else (
    if defined wasClosed (
        taskkill /f /im rpc.exe >nul 2>&1
        timeout /t 1 >nul
        start "" /b "!rpcExe!"
        set "wasClosed="
    )
)

:: rpc.exe güncel mi kontrol et (SHA256 hash ile)
powershell -Command ^
    "$localHash = ''; if (Test-Path '%rpcExe%') { $localHash = Get-FileHash '%rpcExe%' -Algorithm SHA256 | Select-Object -ExpandProperty Hash }; ^
     $webData = Invoke-WebRequest '%downloadUrl%' -UseBasicParsing; ^
     $memStream = New-Object System.IO.MemoryStream; ^
     $writer = New-Object System.IO.StreamWriter($memStream); ^
     $writer.Write($webData.Content); $writer.Flush(); $memStream.Position = 0; ^
     $webHash = Get-FileHash -InputStream $memStream -Algorithm SHA256 | Select-Object -ExpandProperty Hash; ^
     if ($localHash -ne $webHash) { (New-Object System.Net.WebClient).DownloadFile('%downloadUrl%', '%rpcExe%') }" >nul

timeout /t 5 >nul
goto loop
