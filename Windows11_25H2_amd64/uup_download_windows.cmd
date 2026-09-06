@echo off
:: rem 生成时间 2026-09-06 05:25:34 GMT
:: 代理配置
:: 如果你需要配置一个代理服务器，以便能够连接到 Internet，
:: 那么你可以通过配置 all_proxy 环境变量来实现。
:: 默认情况下，此变量为空，即配置 aria2c 不使用任何代理。
::
:: 用法：set "all_proxy=proxy_address"
:: 示例：set "all_proxy=127.0.0.1:8888"
::
:: 有关如何使用的更多信息可以在以下网站找到：
:: https://aria2.github.io/manual/en/html/aria2c.html#cmdoption-all-proxy
:: https://aria2.github.io/manual/en/html/aria2c.html#environment

:: 取消注释以下行以覆盖系统指定的代理设置。
:: 
::
:: set "all_proxy="

:: 代理配置结束

cd /d "%~dp0"
if NOT "%cd%"=="%cd: =%" (
    echo 当前目录的路径中包含空格。
    echo 请将目录移动或重命名为不包含空格的目录。
    echo.
    pause
    goto :EOF
)

if "[%1]" == "[49127c4b-02dc-482e-ac4f-ec4d659b7547]" goto :START_PROCESS
REG QUERY HKU\S-1-5-19\Environment >NUL 2>&1 && goto :START_PROCESS

set command="""%~f0""" 49127c4b-02dc-482e-ac4f-ec4d659b7547
SETLOCAL ENABLEDELAYEDEXPANSION
set "command=!command:'=''!"

powershell -NoProfile Start-Process -FilePath '%COMSPEC%' ^
-ArgumentList '/c """!command!"""' -Verb RunAs 2>NUL

IF %ERRORLEVEL% GTR 0 (
    echo =====================================================
    echo 此脚本需要以管理员身份执行。
    echo =====================================================
    echo.
    pause
)

SETLOCAL DISABLEDELAYEDEXPANSION
goto :EOF

:START_PROCESS
title 26200.9278_amd64_zh-cn_professional_c1c737c2 download

set "aria2=files\aria2c.exe"
set "a7z=files\7zr.exe"
set "uupConv=files\uup-converter-wimlib.7z"
set "aria2Script=files\aria2_script.%random%.txt"
set "destDir=UUPs"

powershell -NoProfile -ExecutionPolicy Unrestricted .\files\get_aria2.ps1 || (pause & exit /b 1)
echo.

echo 正在下载 UUP 转换器...
"%aria2%" --no-conf --async-dns=false --console-log-level=warn --log-level=info --log="aria2_download.log" -x16 -s16 -j2 -c -R -d"files" -i"files\converter_windows"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_CONVERTER_ERROR & exit /b 1
echo.

if NOT EXIST ConvertConfig.ini goto :NO_FILE_ERROR
if NOT EXIST CustomAppsList.txt goto :NO_FILE_ERROR
if NOT EXIST %a7z% goto :NO_FILE_ERROR
if NOT EXIST %uupConv% goto :NO_FILE_ERROR

echo 正在提取 UUP 转换器...
"%a7z%" -x!ConvertConfig.ini -x!CustomAppsList.txt -y x "%uupConv%" >NUL
echo.

:DOWNLOAD_APPS
echo 正在下载 Microsoft Apps 应用的 aria2 脚本...
"%aria2%" --no-conf --async-dns=false --console-log-level=warn --log-level=info --log="aria2_download.log" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://uupdump.cn/get.php?id=c1c737c2-f2d9-4824-bb5b-1af515179099&pack=neutral&edition=app&aria2=2&expires=1788845134&token=1474e723f7fe8b904d4576b234582574de02cdee2afb88aec59e4938dc78dd0a"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1
echo.

for /F "tokens=2 delims=:" %%i in ('findstr #UUPDUMP_ERROR: "%aria2Script%"') do set DETECTED_ERROR=%%i
if NOT [%DETECTED_ERROR%] == [] (
    echo 无法从 Windows 更新服务器检索数据。原因： %DETECTED_ERROR%
    echo 如果该问题仍然存在，很可能是您尝试下载的套件已从 Windows 更新服务器中删除。
    echo.
    pause
    goto :EOF
)

echo 正在下载 Microsoft Apps 应用...
"%aria2%" --no-conf --async-dns=false --console-log-level=warn --log-level=info --log="aria2_download.log" -x16 -s16 -j25 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto :DOWNLOAD_APPS
echo.

:DOWNLOAD_UUPS
echo 正在下载 UUP 文件的 aria2 脚本...
"%aria2%" --no-conf --async-dns=false --console-log-level=warn --log-level=info --log="aria2_download.log" -o"%aria2Script%" --allow-overwrite=true --auto-file-renaming=false "https://uupdump.cn/get.php?id=c1c737c2-f2d9-4824-bb5b-1af515179099&pack=zh-cn&edition=professional&aria2=2&expires=1788845134&token=15d2fe4272a4cc22ea993bc8cc1e5c312fb461187d446ed64e1e854362d92504"
if %ERRORLEVEL% GTR 0 call :DOWNLOAD_ERROR & exit /b 1
echo.

for /F "tokens=2 delims=:" %%i in ('findstr #UUPDUMP_ERROR: "%aria2Script%"') do set DETECTED_ERROR=%%i
if NOT [%DETECTED_ERROR%] == [] (
    echo Unable to retrieve data from Windows Update servers. Reason: %DETECTED_ERROR%
    echo If this problem persists, most likely the set you are attempting to download was removed from Windows Update servers.
    echo.
    pause
    goto :EOF
)

echo 正在下载 UUP 文件...
"%aria2%" --no-conf --async-dns=false --console-log-level=warn --log-level=info --log="aria2_download.log" -x16 -s16 -j25 -c -R -d"%destDir%" -i"%aria2Script%"
if %ERRORLEVEL% GTR 0 goto :DOWNLOAD_UUPS & exit /b 1

if EXIST convert-UUP.cmd goto :START_CONVERT
pause
goto :EOF

:START_CONVERT
call convert-UUP.cmd
goto :EOF

:NO_FILE_ERROR
echo 我们找不到此脚本所需的文件之一.
pause
goto :EOF

:DOWNLOAD_CONVERTER_ERROR
echo.
echo 下载 UUP 转换器时发生错误。
pause
goto :EOF

:DOWNLOAD_ERROR
findstr /C:"status=403" "aria2_download.log" >nul 2>&1
if not errorlevel 1 (
    echo.
    echo ================================================
    echo 下载令牌已过期、无效或被修改。
    echo 请返回 https://uupdump.cn/ 重新生成下载包。
    echo 已经下载完成的文件可以保留，无需重新下载。
    echo ================================================
    echo.
    pause
    goto :EOF
)
echo.
echo 我们遇到了一个错误 while downloading files.
pause
goto :EOF

:EOF
