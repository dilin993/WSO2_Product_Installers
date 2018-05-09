@echo off

set PRODUCT_POS=windows
set WIXDIST=resources\wix
set ICONDIST=resources\icons
set SIGNTOOLLOC="%programfiles(x86)%\Windows Kits\10\bin\10.0.16299.0\x64\signtool.exe"
set PRODUCT=wso2am

:argumentLoop
IF NOT "%1"=="" (
    REM IF "%1"=="--dist" (
    REM     SET DIST=%2
    REM     SHIFT
    REM )
    IF "%1"=="--version" (
        SET PRODUCT_VERSION=%2
        SHIFT
    )
	IF "%1"=="--path" (
        SET DISTLOC=%2
        SHIFT
    )
	IF "%1"=="--cert-path" (
        SET CERTLOC=%2
        SHIFT
    )
    IF "%1"=="--wix-path" (
        SET WIXDIST=%2
        SHIFT
    )
	SHIFT
	goto argumentLoop
)


REM IF "%DIST%"==""  (
REM 	set DIST=all
REM 	rem echo The syntax of the command is incorrect. Missing argument dist.
REM 	rem goto EOF
REM )

IF "%CERTLOC%"==""  (
	set CERTLOC="resources\cert\prodlerina-digicert.pfx"
	rem echo The syntax of the command is incorrect. Missing argument dist.
	rem goto EOF
)

IF "%DISTLOC%"==""  (
	REM set DISTLOC=resources\dist
	echo The syntax of the command is incorrect. Missing argument dist.
	goto EOF
)

REM IF NOT "%DIST%"=="all" IF NOT "%DIST%"=="prodlerina-platform" IF NOT "%DIST%"=="prodlerina-runtime" (
REM 	echo The syntax of the command is incorrect. Possible arguments for dist - all, prodlerina-platform, prodlerina-runtime.
REM 	echo Ex: --dist prodlerina-platform
REM 	goto EOF
REM )

IF "%PRODUCT_VERSION%"==""  (
	echo The syntax of the command is incorrect. Missing argument version.
	goto EOF
)

for /f %%x in ('wmic path win32_utctime get /format:list ^| findstr "="') do set %%x
set UTC_TIME=%Year%-%Month%-%Day% %Hour%:%Minute%:%Second% UTC

rmdir %PRODUCT%-%PRODUCT_VERSION% /s /q >nul 2>&1
rmdir target /s /q >nul 2>&1

REM IF "%DIST%"=="all" (
REM 	call :createprodlerina-platformWin64Installer
REM 	rem call :createprodlerina-platformWin586Installer
REM 	call :createprodlerina-runtimeWin64Installer
REM 	rem call :createprodlerina-runtimeWin586Installer
REM ) ELSE (
REM 	call :create%DIST%Win64Installer
REM )

call :initInstaller
goto EOF


:initInstaller
set PRODZIP=%DISTLOC%\%PRODUCT%-%PRODUCT_VERSION%.zip
echo Product Archive: %PRODZIP%
set PRODDIST=%PRODUCT%-%PRODUCT_VERSION%
echo Product Version: %PRODDIST%"
set PRODPARCH=x64
set INSTALLERPARCH=amd64
set MSI=%PRODUCT%-%PRODUCT_VERSION%-installer-%PRODPARCH%.msi
call :createInstaller
goto EOF

REM :createprodlerina-platformWin586Installer
REM set PRODZIP=%DISTLOC%\prodlerina-platform-windows-%PRODUCT_VERSION%.zip
REM set PRODDIST=prodlerina-platform-windows-%PRODUCT_VERSION%
REM set PRODPARCH=i586
REM set INSTALLERPARCH=386
REM set MSI=prodlerina-platform-%PRODUCT_POS%-installer-%PRODPARCH%-%PRODUCT_VERSION%.msi
REM call :createInstaller
REM goto EOF

REM :createprodlerina-runtimeWin64Installer
REM set PRODZIP=%DISTLOC%\prodlerina-runtime-windows-%PRODUCT_VERSION%.zip
REM set PRODDIST=prodlerina-runtime-windows-%PRODUCT_VERSION%
REM set PRODPARCH=x64
REM set INSTALLERPARCH=amd64
REM set MSI=prodlerina-runtime-%PRODUCT_POS%-installer-%PRODPARCH%-%PRODUCT_VERSION%.msi
REM call :createInstaller
REM goto EOF

REM :createprodlerina-runtimeWin586Installer
REM set PRODZIP=%DISTLOC%\prodlerina-runtime-windows-%PRODUCT_VERSION%.zip
REM set PRODDIST=prodlerina-runtime-windows-%PRODUCT_VERSION%
REM set PRODPARCH=i586
REM set INSTALLERPARCH=386
REM set MSI=prodlerina-runtime-%PRODUCT_POS%-installer-%PRODPARCH%-%PRODUCT_VERSION%.msi
REM call :createInstaller
REM goto EOF

:createInstaller
rem jar -xf %PRODZIP%
rmdir target\installer-resources /s /q >nul 2>&1
powershell.exe -nologo -noprofile -command "& { Add-Type -A 'System.IO.Compression.FileSystem'; [IO.Compression.ZipFile]::ExtractToDirectory('%PRODZIP%', '.'); }"
xcopy  %ICONDIST% %PRODDIST%\icons /e /i >nul 2>&1

echo %PRODDIST% build started at '%UTC_TIME%' for %PRODUCT_POS% %PRODPARCH%

echo Creating the Installer...

%WIXDIST%\heat dir %PRODDIST% -nologo -v -gg -g1 -srd -sfrag -sreg -cg AppFiles -template fragment -dr INSTALLDIR -var var.SourceDir -out target\installer-resources\AppFiles.wxs
echo heat completed!
%WIXDIST%\candle -nologo -sw -dprodVersion=%PRODUCT_VERSION% -dprodName=%PRODUCT% -dWixprodVersion=1.0.0.0 -dArch=%INSTALLERPARCH% -dSourceDir=%PRODDIST% -out target\installer-resources\ -ext WixUtilExtension -ext WixUIExtension resources\installer.wxs target\installer-resources\AppFiles.wxs
echo candle completed!
%WIXDIST%\light -nologo -dcl:high -sw -ext WixUIExtension -ext WixUtilExtension -loc resources\en-us.wxl target\installer-resources\AppFiles.wixobj target\installer-resources\installer.wixobj -o target\msi\%MSI%
echo light completed!

REM %SIGNTOOLLOC% sign /f %CERTLOC% /p wuminit /t http://timestamp.verisign.com/scripts/timstamp.dll target\msi\%MSI%
REM echo sign verification completed!
rmdir %PRODUCT%-%PRODUCT_VERSION% /s /q >nul 2>&1

echo %PRODDIST% build completed at '%UTC_TIME%' for %PRODUCT_POS% %PRODPARCH%

echo.
goto EOF

:EOF
