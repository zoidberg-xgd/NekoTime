@echo off
REM NekoTime Windows 构建脚本
REM 用法: scripts\build_windows.bat

setlocal EnableDelayedExpansion

set VERSION=2.1.0
set APP_NAME=NekoTime

echo ===================================
echo %APP_NAME% Windows 构建脚本 v%VERSION%
echo ===================================
echo.

REM 检查 Flutter
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 未找到 Flutter，请确保已安装并添加到 PATH
    exit /b 1
)

REM 清理旧构建
echo [1/4] 清理旧构建...
call flutter clean
call flutter pub get
echo [✓] 清理完成
echo.

REM 构建 Release 版本
echo [2/4] 构建 Windows Release 版本...
call flutter build windows --release
if %ERRORLEVEL% NEQ 0 (
    echo [错误] 构建失败
    exit /b 1
)
echo [✓] 构建完成
echo.

REM 创建分发目录
echo [3/4] 准备打包...
if not exist "dist" mkdir dist

REM 打包便携版
echo [4/4] 创建便携版压缩包...
set RELEASE_DIR=build\windows\x64\runner\Release
set ZIP_NAME=%APP_NAME%-Windows-v%VERSION%.zip

REM 使用 PowerShell 压缩
powershell -Command "Compress-Archive -Path '%RELEASE_DIR%\*' -DestinationPath 'dist\%ZIP_NAME%' -Force"

if %ERRORLEVEL% EQ 0 (
    echo [✓] 打包完成
    echo.
    echo ===================================
    echo 构建成功！
    echo ===================================
    echo.
    echo 输出文件: dist\%ZIP_NAME%
    dir dist\%ZIP_NAME%
    echo.
    echo 可执行文件位置:
    echo %RELEASE_DIR%\digital_clock.exe
    echo.
) else (
    echo [错误] 打包失败
    exit /b 1
)

REM 创建 README
echo 正在创建 README.txt...
(
echo NekoTime - 猫铃时钟 v%VERSION%
echo ==============================
echo.
echo 安装说明:
echo 1. 解压到任意目录
echo 2. 双击运行 digital_clock.exe
echo 3. 首次运行可能需要安装 Visual C++ 运行库
echo.
echo 系统要求:
echo - Windows 10 1903 或更高版本
echo - 建议 Windows 11 以获得最佳体验
echo.
echo 如遇问题:
echo - 查看完整文档: https://github.com/zoidberg-xgd/NekoTime
echo - 提交 Issue: https://github.com/zoidberg-xgd/NekoTime/issues
echo.
echo 主题目录:
echo %%APPDATA%%\digital_clock\themes\
echo.
echo 日志目录:
echo %%APPDATA%%\digital_clock\logs\
) > "%RELEASE_DIR%\README.txt"

echo [✓] README.txt 已创建
echo.

echo 打包完成！按任意键退出...
pause >nul
