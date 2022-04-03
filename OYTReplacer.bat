@echo off
cd /d "%~dp0"
cacls.exe "%SystemDrive%\System Volume Information" >nul 2>nul
if %errorlevel%==0 goto Admin
if exist "%temp%\getadmin.vbs" del /f /q "%temp%\getadmin.vbs"
echo Set RequestUAC = CreateObject^("Shell.Application"^)>"%temp%\getadmin.vbs"
echo RequestUAC.ShellExecute "%~s0","","","runas",1 >>"%temp%\getadmin.vbs"
echo WScript.Quit >>"%temp%\getadmin.vbs"
"%temp%\getadmin.vbs" /f
if exist "%temp%\getadmin.vbs" del /f /q "%temp%\getadmin.vbs"
exit
:Admin

SETLOCAL ENABLEEXTENSIONS
cd /d "%~dp0"

echo Welcome to YaHei Font Replacer.
echo Original work by Moeologist, Modified by Lapis Apple
echo.
echo Use at your own risk. This may hurt your system!
echo.
echo.
echo You have to delete the registry before you replace the system font.
echo In addition a logout is required to apply the changes so save your work right now!
echo.
echo Have you already deleted the registry?
echo If you haven't deleted it type 'D' and we'll delete it for you.
echo If you already deleted it type 'C' to continue to replace.
echo Type 'E' to leave the script. Type 'R' to restore the permission and the registry (Advanced).
choice  /c dcre /m "> "
If %errorlevel%==1 goto DeleteRegistry
If %errorlevel%==2 goto ReplaceFont
If %errorlevel%==3 goto restoreAnything
If %errorlevel%==4 goto End

:DeleteRegistry
echo Now we will delete the registry.
echo.
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Bold & Microsoft Yahei UI Bold (TrueType)" /f
reg delete "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Light & Microsoft Yahei UI Light (TrueType)" /f
echo.
echo Complete. Registry has been deleted. 
echo Please log out right now and run this script again.
echo Note that please save this script in a location that you can access easily(such as desktop),
echo Because there may be a temporary problem with the font after you logged on.
echo.
echo Press any key to exit.
pause>nul
goto End


:ReplaceFont
echo Please tell me where the font is.
echo Three files are required: msyh.ttc, msyhbd.ttc and msyhl.ttc.
echo Place them in a same directory, and please type the location of the directory.
echo.
echo Do not use the path including Space!!! this will cause error!!!
echo If you want to use the font in current directory, Please type 'skip'.
echo.
set /p fontLocation="> "

pause
echo We will now check if it's exist.

if %fontLocation% == "skip" set fontLocation=%~dp0

if exist %fontLocation% (
    echo Check: Directory exists.
    set checkPassed=0
) else (
    set checkPassed=1
)


if %checkPassed% neq 0 (
    echo Sorry, But the required file does not exist. Error Code is %checkPassed%.
    echo Please press any key to try again.
    pause>nul
    goto ReplaceFont
) else (
    echo The Directory is valid.
    echo Now going to replace process..
    goto replaceProcess
)
goto Error

:replaceProcess
echo Now we'll start to replace font. 
echo THIS MAY HURT YOUR SYSTEM!! USE IT AT YOUR OWN RISK!!
echo Press any key to start. BE SURE TO HAVE A BACKUP!!
pause>nul
echo. & echo.
echo ------------------------------------------------

echo Backup the original permissions..
icacls c:\windows\Fonts\msyh* /save "%~dp0\acl" /T
timeout /t 3

echo Getting Permission of the file..
takeown /F C:\Windows\Fonts\msyh* /A
icacls C:\Windows\Fonts\msyh* /grant Administrators:F
timeout /t 3

echo Deleting the original file..
del /f /s /q C:\Windows\Fonts\msyh*
timeout /t 3

if exist C:\Windows\Fonts\msyh* (
    echo. & echo.
    echo We're really sorry, but we're failed to delete the file.
    echo Please try replace with Windows PE by yourself, or report this as a bug to developer.
    echo Also check that did you do anything wrong, too.
    echo.
    echo Your system is not BOOM-ed and you can continue to use without fearing.
    echo If you deleted registry and want to recovery it, Run this script again and type 'R' in the first selection. This will recovery your registry.
    pause>nul
    goto End
) else (
    echo Seems we have successfully deleted original file.
)

echo Coping the file..
copy "msyh*" C:\Windows\Fonts
timeout /t 3

echo Getting the permission again..
takeown /F C:\Windows\Fonts\msyh* /A
icacls C:\Windows\Fonts\msyh* /grant Administrators:F
timeout /t 3

:restoreAnything
echo Recovering the permission from backup..
icacls C:\windows\Fonts\msyh* /C /setowner "NT SERVICE\TrustedInstaller"
icacls C:\windows\Fonts\ /C /restore "%~dp0\acl"
timeout /t 3

echo Restoring the registry..
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei & Microsoft Yahei UI (TrueType)" /t REG_SZ /d "msyh.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Bold & Microsoft Yahei UI Bold (TrueType)" /t REG_SZ /d "msyhbd.ttc" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts" /v "Microsoft Yahei Light & Microsoft Yahei UI Light (TrueType)" /t REG_SZ /d "msyhl.ttc" /f

echo ------------------------------------------------
echo. & echo.
echo Script completed. 
echo I hope there's no error happened. But if you ran into problem, 
echo you can always recovery them by running this script again and type R in first selection.
echo.
echo Also, we have created a file called acl in the same directory of this script.
echo It's a backup with permission. If you sure everything's ok, you can delete it.
echo But don't delete it before you sure everything is ok. 
echo. 
echo Anyway. If there's no error, You may reboot now. 
echo Goodbye and have a nice day.
echo.
echo Press any key to exit the script.
pause>nul
goto End

:Error
echo If you saw this message, SOMETHING WENT WRONG.
echo Maybe you can report this to the developer?
pause>nul
:End
popd
echo Script End.

