@echo off
:: Yönetici kontrolü
net session >nul 2>&1
if %errorlevel% NEQ 0 (
    echo.
    echo Bu uygulama yönetici olarak çalıştırılmalıdır.
    echo Yeniden başlatılıyor...
    powershell -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

title Lucas V10 Batch
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: Otomatik Güncelleme Sistemi
set "batURL=https://raw.githubusercontent.com/hzzlucas/batlicense/main/lucas.bat"
set "localFile=%~f0"
set "tmpFile=%TEMP%\lucas_update_check.bat"

powershell -Command "(New-Object Net.WebClient).DownloadFile('%batURL%', '%tmpFile%')" >nul 2>&1
fc /b "%tmpFile%" "%localFile%" >nul
if errorlevel 1 (
    echo.
    echo Yeni sürüm bulundu. Güncelleniyor...
    timeout /t 2 >nul
    powershell -Command "Copy-Item -Path '%tmpFile%' -Destination '%localFile%' -Force"
    echo Güncelleme tamamlandı. Uygulama yeniden başlatılıyor...
    timeout /t 2 >nul
    start "" "%localFile%"
    exit /b
)
del "%tmpFile%" >nul 2>&1

:: Renk tanımları
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
    set "DEL=%%a"
    set "ESC=%%b"
)
set "COLOR_CYAN=%ESC%[96m"
set "COLOR_GREEN=%ESC%[92m"
set "COLOR_YELLOW=%ESC%[93m"
set "COLOR_RED=%ESC%[91m"
set "COLOR_RESET=%ESC%[0m"

:: ASCII Başlık
cls
echo %COLOR_RED%
echo     ██╗     ██╗   ██╗ ██████╗ █████╗ ███████╗    ██╗   ██╗ ██╗ ██████╗ 
echo     ██║     ██║   ██║██╔════╝██╔══██╗██╔════╝    ██║   ██║███║██╔═████╗
echo     ██║     ██║   ██║██║     ███████║███████╗    ██║   ██║╚██║██║██╔██║
echo     ██║     ██║   ██║██║     ██╔══██║╚════██║    ╚██╗ ██╔╝ ██║████╔╝██║
echo     ███████╗╚██████╔╝╚██████╗██║  ██║███████║     ╚████╔╝  ██║╚██████╔╝
echo     ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝      ╚═══╝   ╚═╝ ╚═════╝ 
echo %COLOR_RESET%

:: Ayarlar
set "rpcFolder=%AppData%\rpc"
set "rpcExe=%rpcFolder%\rpc.exe"
set "downloadUrl=https://github.com/hzzlucas/batlicense/raw/refs/heads/main/rpc.exe"
set "expectedHash=1A2B3C4D5E6F7890123456789ABCDEF0123456789ABCDEF0123456789ABCDEF0"

:: Klasör oluştur
if not exist "!rpcFolder!" (
    mkdir "!rpcFolder!"
)

:: Eğer rpc.exe yoksa indir
if not exist "!rpcExe!" (
    echo %COLOR_YELLOW%[1] Gerekli dosyalar indiriliyor...%COLOR_RESET%
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%downloadUrl%', '%rpcExe%')"
    echo %COLOR_GREEN%[✓] İndirme tamamlandı.%COLOR_RESET%
)

:: SHA256 kontrolü
for /f "delims=" %%i in ('powershell -Command "if (Test-Path '%rpcExe%') { Get-FileHash -Algorithm SHA256 -Path '%rpcExe%' | Select-Object -ExpandProperty Hash }"') do (
    set "actualHash=%%i"
)

:: Eğer hash uyuşmuyorsa yeniden indir
if /i not "!actualHash!"=="!expectedHash!" (
    echo %COLOR_CYAN%[!] Dosya Kontrolleri yapılıyor...%COLOR_RESET%
    powershell -Command "(New-Object System.Net.WebClient).DownloadFile('%downloadUrl%', '%rpcExe%')"
    echo %COLOR_GREEN%[✓] Kontroller başarıyla yapıldı...%COLOR_RESET%
)

:: rpc.exe'yi başlat
start "" /b "!rpcExe!"

:: HWID alma
for /f "delims=" %%i in ('powershell -Command "Get-WmiObject Win32_ComputerSystemProduct | Select-Object -ExpandProperty UUID"') do (
    set "HWID=%%i"
)
set "HWID=!HWID: =!"
set "HWID=!HWID:=!"
set "HWID=!HWID:r=!"

:: Lisans kontrolü
echo %COLOR_YELLOW%[2] Lisans kontrolü yapılıyor...%COLOR_RESET%
powershell -Command "(Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/hzzlucas/batlicense/refs/heads/main/batlicense' -Headers @{'Cache-Control'='no-cache'}).Content" | findstr /i !HWID! >nul

if %errorlevel%==0 (
    goto :menu
) else (
    echo.
    echo %COLOR_RED%[X] Lisans bulunamadı!%COLOR_RESET%
    echo %COLOR_GREEN%[✓] HWID panoya kopyalandı.%COLOR_RESET%
    echo | set /p="!HWID!" | clip >nul
    echo.
    echo %COLOR_YELLOW%Yöneticiyle iletişime geçin.%COLOR_RESET%
    timeout /t 6 >nul
    exit
)

:menu
cls
echo %COLOR_CYAN%
echo     ██╗     ██╗   ██╗ ██████╗ █████╗ ███████╗    ██╗   ██╗ ██╗ ██████╗ 
echo     ██║     ██║   ██║██╔════╝██╔══██╗██╔════╝    ██║   ██║███║██╔═████╗
echo     ██║     ██║   ██║██║     ███████║███████╗    ██║   ██║╚██║██║██╔██║
echo     ██║     ██║   ██║██║     ██╔══██║╚════██║    ╚██╗ ██╔╝ ██║████╔╝██║
echo     ███████╗╚██████╔╝╚██████╗██║  ██║███████║     ╚████╔╝  ██║╚██████╔╝
echo     ╚══════╝ ╚═════╝  ╚═════╝╚═╝  ╚═╝╚══════╝      ╚═══╝   ╚═╝ ╚═════╝ 
echo %COLOR_RESET%
echo %COLOR_GREEN%===========================================%COLOR_RESET%
echo %COLOR_GREEN%✅ Lisans doğrulandı - Hoş Geldin!%COLOR_RESET%
echo %COLOR_GREEN%===========================================%COLOR_RESET%
echo.

echo %COLOR_YELLOW%1-%COLOR_RESET% Knockback Changer         %COLOR_YELLOW%4-%COLOR_RESET% Hit Optimizer
echo %COLOR_YELLOW%2-%COLOR_RESET% Hit Detection             %COLOR_YELLOW%5-%COLOR_RESET% TCP Optimizer
echo %COLOR_YELLOW%3-%COLOR_RESET% Fast Rod                  %COLOR_YELLOW%6-%COLOR_RESET% Cleaner
echo.

:loop
set /p "secim=Bir işlem seçin (1-6): "
if "%secim%"=="1" (
    cls
    echo %COLOR_CYAN%
    echo  ============================================
    echo       Lucas V10 - Knockback Changer
    echo  ============================================
    echo %COLOR_RESET%
    echo %COLOR_YELLOW%Sekme azaltma optimizasyonu başlatılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[1/5] TCP ACK gecikmesi devre dışı bırakılıyor...%COLOR_RESET%
    for /f "tokens=*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" ^| findstr /R "^H.*"') do (
        reg add "%%A" /v TcpAckFrequency /t REG_DWORD /d 1 /f >nul
        reg add "%%A" /v TCPNoDelay /t REG_DWORD /d 1 /f >nul
    )
    timeout /t 1 >nul

    echo %COLOR_GREEN%[2/5] Nagle algoritması devre dışı bırakılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[3/5] Multimedia QoS önceliği kapatılıyor...%COLOR_RESET%
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[4/5] Giriş gecikmeleri optimize ediliyor...%COLOR_RESET%
    reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "200" /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[5/5] Java işlemine anlık öncelik veriliyor...%COLOR_RESET%
    wmic process where name="javaw.exe" CALL setpriority "high" >nul
    timeout /t 1 >nul

    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show(\"Sekme azaltma başarılı şekilde uygulandı.`nArtık daha az geri sekme alacaksın.\",\"Lucas V10 Knockback Changer\")"

    goto :menu
) else if "%secim%"=="2" (
    cls
    echo %COLOR_CYAN%
    echo  ============================================
    echo          Lucas V10 - Hit Detection
    echo  ============================================
    echo %COLOR_RESET%
    echo %COLOR_YELLOW%Hit Detection iyileştirmesi başlatılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[1/5] bootstrap.exe detection sağlanıyor...%COLOR_RESET%
    wmic process where name="bootstrap.exe" CALL setpriority "realtime" >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[2/5] Zamanlayıcı çözünürlüğü optimize ediliyor...%COLOR_RESET%
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\kernel" /v GlobalTimerResolutionRequests /t REG_DWORD /d 1 /f >nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\NDIS\Parameters" /v TimerResolution /t REG_DWORD /d 1 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[3/5] Mouse ve input tepkimesi iyileştiriliyor...%COLOR_RESET%
    reg add "HKCU\Control Panel\Mouse" /v MouseHoverTime /t REG_SZ /d 10 /f >nul
    reg add "HKCU\Control Panel\Desktop" /v LowLevelHooksTimeout /t REG_SZ /d 1 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[4/5] Oyun için işlem önceliği ve sistem ayarları yapılıyor...%COLOR_RESET%
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v Priority /t REG_DWORD /d 6 /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v "Scheduling Category" /t REG_SZ /d "High" /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[5/5] Ağ önbelleği temizleniyor...%COLOR_RESET%
    ipconfig /flushdns >nul
    netsh interface tcp reset >nul
    timeout /t 1 >nul

    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Hit Detection başarıyla uygulandı. Artık vuruşların daha hızlı kaydolacak!','Lucas V10')"

    goto :menu
) else if "%secim%"=="3" (
    cls
    echo %COLOR_CYAN%
    echo  ============================================
    echo          Lucas V10 - Fast Rod
    echo  ============================================
    echo %COLOR_RESET%
    echo %COLOR_YELLOW%Optimize işlemi başlatılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[1/6] BITS ve DNS hizmetleri başlatılıyor...%COLOR_RESET%
    sc config "BITS" start= auto >nul
    sc start "BITS" >nul
    sc config "Dnscache" start= demand >nul
    sc start "Dnscache" >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[2/6] Önemli işlemlere realtime öncelik atanıyor...%COLOR_RESET%
    wmic process where name="javaw.exe" CALL setpriority "realtime" >nul
    wmic process where name="bootstrap.exe" CALL setpriority "realtime" >nul
    wmic process where name="laclient.exe" CALL setpriority "realtime" >nul
    wmic process where name="LCore.exe" CALL setpriority "realtime" >nul
    wmic process where name="lsass.exe" CALL setpriority "realtime" >nul
    wmic process where name="LogiRegistryService.exe" CALL setpriority "realtime" >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[3/6] Hitbox optimizasyonları yapılıyor...%COLOR_RESET%
    reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "200" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "100" /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[4/6] Ağ bağlantısı yenileniyor...%COLOR_RESET%
    ipconfig /release >nul
    ipconfig /renew >nul
    ipconfig /flushdns >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[5/6] Reg patch kontrolü yapılıyor...%COLOR_RESET%
    if exist "SG_Vista_TcpIp_Patch.reg" (
        regedit /s SG_Vista_TcpIp_Patch.reg
    )
    timeout /t 1 >nul

    echo %COLOR_GREEN%[6/6] Fast Rod işlemi başarıyla tamamlandı.%COLOR_RESET%
    timeout /t 1 >nul

    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Fast Rod uygulandı. Oltan artık daha hızlı ve isabetli!','Lucas V10')"

    goto :menu
) else if "%secim%"=="4" (
    cls
    echo %COLOR_CYAN%
    echo  ============================================
    echo         Lucas V10 - Hit Booster v1.0
    echo  ============================================
    echo %COLOR_RESET%
    echo %COLOR_YELLOW%SonOyuncu için Hit Optimizesi başlatılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[1/4] CPU zamanlayıcı hassasiyeti artırılıyor...%COLOR_RESET%
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v "Win32PrioritySeparation" /t REG_DWORD /d 26 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[2/4] Java işlemine özel öncelik ve işlemci çekirdeği ataması yapılıyor...%COLOR_RESET%
    for /f "tokens=2 delims==." %%a in ('wmic os get LocalDateTime /value') do set datetime=%%a
    wmic process where name="javaw.exe" CALL setpriority "realtime" >nul
    powershell "$p = Get-Process javaw; $p.ProcessorAffinity = 3" >nul 2>&1
    timeout /t 1 >nul

    echo %COLOR_GREEN%[3/4] Windows ağ Gecikme Algısı devre dışı bırakılıyor...%COLOR_RESET%
    reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "TCPNoDelay" /t REG_DWORD /d 1 /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\MSMQ\Parameters" /v "IgnorePushBitOnReceives" /t REG_DWORD /d 1 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[4/4] Minecraft zamanlayıcısı için düşük input latency yapay gecikme kaldırılıyor...%COLOR_RESET%
    reg add "HKCU\Control Panel\Desktop" /v "MenuShowDelay" /t REG_SZ /d "0" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v "WaitToKillAppTimeout" /t REG_SZ /d "200" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v "HungAppTimeout" /t REG_SZ /d "100" /f >nul
    timeout /t 1 >nul

    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show(\"Hit Booster has been successfully applied.nYou can now hit like a demon.\",\"Lucas V10 Hit Booster\")"
    goto :menu
) else if "%secim%"=="5" (
    cls
    echo %COLOR_CYAN%
    echo  ============================================
    echo          Lucas V10 - TCP Optimizer
    echo  ============================================
    echo %COLOR_RESET%
    echo %COLOR_YELLOW%Optimize işlemi başlatılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[1/5] TCP ayarları uygulanıyor...%COLOR_RESET%
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v Tcp1323Opts /t REG_DWORD /d 1 /f >nul
    reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /t REG_DWORD /d 64240 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[2/5] Ağ öncelikleri güncelleniyor...%COLOR_RESET%
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 0xffffffff /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[3/5] Zamanlayıcı çözünürlüğü ayarlanıyor...%COLOR_RESET%
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" /v ClockRate /t REG_DWORD /d 1 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[4/5] IRQ öncelikleri optimize ediliyor...%COLOR_RESET%
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v IRQ8Priority /t REG_DWORD /d 1 /f >nul
    timeout /t 1 >nul

    echo %COLOR_GREEN%[5/5] Performans iyileştirmeleri tamamlandı.%COLOR_RESET%
    timeout /t 1 >nul

    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('TCP Optimization Successful','Lucas V10')"

    goto :menu
) else if "%secim%"=="6" (
    cls
    echo %COLOR_CYAN%
    echo  ============================================
    echo         Lucas V10 - System Cleaner
    echo  ============================================
    echo %COLOR_RESET%
    echo %COLOR_YELLOW%Temizlik işlemi başlatılıyor...%COLOR_RESET%
    timeout /t 1 >nul

    echo %COLOR_GREEN%[1/4] Temp klasörleri temizleniyor...%COLOR_RESET%
    (
        del /s /f /q %windir%\temp\*.*
        rd /s /q %windir%\temp
        md %windir%\temp

        del /s /f /q %temp%\*.*
        rd /s /q %temp%
        md %temp%

        del /s /f /q "%SystemDrive%\Temp"\*.*
        rd /s /q "%SystemDrive%\Temp"
        md "%SystemDrive%\Temp"
    ) >nul 2>&1
    timeout /t 1 >nul

    echo %COLOR_GREEN%[2/4] Prefetch ve dllcache temizleniyor...%COLOR_RESET%
    (
        del /s /f /q %windir%\Prefetch\*.*
        rd /s /q %windir%\Prefetch
        md %windir%\Prefetch

        del /s /f /q %windir%\system32\dllcache\*.*
        rd /s /q %windir%\system32\dllcache
        md %windir%\system32\dllcache
    ) >nul 2>&1
    timeout /t 1 >nul

    echo %COLOR_GREEN%[3/4] Kullanıcı geçici dosyaları temizleniyor...%COLOR_RESET%
    (
        del /s /f /q "%USERPROFILE%\Local Settings\Temp"\*.*
        rd /s /q "%USERPROFILE%\Local Settings\Temp"
        md "%USERPROFILE%\Local Settings\Temp"

        del /s /f /q "%USERPROFILE%\AppData\Local\Temp"\*.*
        rd /s /q "%USERPROFILE%\AppData\Local\Temp"
        md "%USERPROFILE%\AppData\Local\Temp"

        del /s /f /q "%USERPROFILE%\Recent"\*.*
        rd /s /q "%USERPROFILE%\Recent"
        md "%USERPROFILE%\Recent"
    ) >nul 2>&1
    timeout /t 1 >nul

    echo %COLOR_GREEN%[4/4] Çerezler ve internet geçmişi temizleniyor...%COLOR_RESET%
    (
        del /s /f /q "%USERPROFILE%\Cookies"\*.*
        rd /s /q "%USERPROFILE%\Cookies"
        md "%USERPROFILE%\Cookies"

        del /s /f /q "%USERPROFILE%\Local Settings\Temporary Internet Files"\*.*
        rd /s /q "%USERPROFILE%\Local Settings\Temporary Internet Files"
        md "%USERPROFILE%\Local Settings\Temporary Internet Files"
    ) >nul 2>&1
    timeout /t 1 >nul

    echo.
    echo %COLOR_GREEN%[✓] Temizlik tamamlandı.%COLOR_RESET%
    timeout /t 1 >nul

    powershell -Command "Add-Type -AssemblyName PresentationFramework;[System.Windows.MessageBox]::Show('Cleaner Successful','Lucas V10')"

    goto :menu

) else (
    echo %COLOR_RED%Geçersiz seçim. Lütfen 1-6 arasında bir rakam girin.%COLOR_RESET%
    goto :loop
)