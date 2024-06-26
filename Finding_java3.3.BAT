@echo off
rem Check if /debug switch is used
if "%1" == "/2000" (
    goto legacy
)

setlocal enabledelayedexpansion

rem Check if /debug switch is used
if "%1" == "/debug" (
    goto begindebug
)

rem Check if /debug switch is used
if "%1" == "/legacy" (
    goto legacy
)

wmic cpu get name >nul 2>&1
if %errorlevel% equ 0 (
    echo WMIC is enabled.
	set wmic=yes
	goto begin
) else (
	echo wmic is disabled or not found script will now switch to legacy mode
	pause
	goto legacy
)

:legacy 
cls
set /p DR="Select which drive to scan. ONLY ENTER THE LETTER:
echo Running in legacy mode Please wait...............
dir /s /b %DR%:\java.exe >legacymode(%DR%).txt
echo Leagcy mode finished searching %DR%: Please review the legacymode[%DR%].txt file
set /p rerunleg="Do you want to rerun the script? (yes/no): "
if /i "%rerunleg%"=="yes" goto legacy

exit /b

goto legacy
pause
exit /b

:begin
mode 130
:ReportWarning
cls
color 0F
echo ******************************************************************************************************
echo Java Rationalisation Program - UK                                                                        
echo ******************************************************************************************************
echo Only report Javas that have been flagged as a "WARNING"
echo ******************************************************************************************************

rem lookup opertating system 
:lookupOS
echo off
systeminfo | findstr /B /C:"OS Name" > %temp%\osname.txt
find /I "XP" %temp%\osname.txt > nul
if %ERRORLEVEL% EQU 0 (
    set osv=5.1 Windows XP
) else (
    goto nextver
)

:nextver
for /f "tokens=4-5 delims=. " %%i in ('ver') do (
    if "%%i.%%j"=="10.0" (
        set osv=10.0 Windows 10-11\20XX
    ) else if "%%i.%%j"=="6.3" (
        set osv=6.3 Windows 8.1\2012R2
    ) else if "%%i.%%j"=="6.2" (
        set osv=6.2 Windows 8\2012
    ) else if "%%i.%%j"=="6.1" (
        set osv=6.1 Windows 7\win2k8 R2
    ) else if "%%i.%%j"=="6.0" (
        set osv=6.0 Windows Vista\win2k8
    ) else if "%%i.%%j"=="5.2" (
        set osv=5.2 Windows win2k3
    )
)

if defined osv (
    echo %osv%
) else (
    echo Unknown Operating System
)

reg Query "HKLM\Hardware\Description\System\CentralProcessor\0" | find /i "x86" > NUL && set OS=32BIT || set OS=64BIT
if %OS%==32BIT echo 32bit operating system
if %OS%==64BIT echo 64bit operating system 

:admincheck
REM Check if the user is running as admin (administrator)
>nul 2>&1 net session
if %errorlevel% == 0 (
	set admin=Yes
    echo User is running as administrator.
) else (
	set admin=No
    echo WARNING: NOT running as administrator. To avoid permission denied errors quit and run as admin
)
rem endlocal
:scrptcondtions
echo ******************************************************************************************************
set /p BMN="Please enter the BMN number as a numerical number only e.g. 1234: "
echo ******************************************************************************************************
echo Set Data classification Valid entries:O, OS, S, SUKEO, OCCAR-R, C1, C2, C3, C4
set /p govclass="Please set the classification of Data? "
echo ******************************************************************************************************

	set scriptver=3.3 (final release)
	if /i "%govclass%"=="o" (
		set clss="HMG OFFICIAL"
	) else if /i "%govclass%"=="os" (
		set clss="HMG OFFICIAL SENSITIVE"
	) else if /i "%govclass%"=="s" (
		set clss="HMG SECRET"
	) else if /i "%govclass%"=="sukeo" (
		set clss="HMG SECRET UK EYES ONLY"
	) else if /i "%govclass%"=="Ooccar-r" (
		set clss="OCCAR-RESCRICTED"
	) else if /i "%govclass%"=="c1" (
		set clss="C1:OPEN DESIGNED TO BE SHARED PUBLICLY"
	) else if /i "%govclass%"=="c2" (
		set clss="C2:GROUP LIMITED DISTRIBUTION"
	) else if /i "%govclass%"=="c3" (
		set clss="C3:GROUP CONFIDENTIAL- SENSITIVE INFORMATION"
	) else if /i "%govclass%"=="c4" (
		set clss="C4:GROUP SECRET- EXTREMELY SENSITIVE INFORMATION"
	) else (
		echo Not a valid answer. Please try again.
		timeout /t 2 >nul
		cls
		goto begin
	)
	if /i "%govclass%"=="s" (
		set clss="SECRET"
		color 4F
	)

	if /i "%govclass%"=="sukeo" (
		set clss="SUKEO"
		color 4F
	)
	set "search_file1=*java.exe"
	set "search_file2=*javaw.exe"
	
	rem Get the current date and time
	for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
	set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"

	set "datestamp=%YYYY%%MM%%DD%-%HH%%Min%"
	set "results_file=BMN%BMN%-%computername%-%datestamp%-%govclass%.txt"
	echo ***** Data classification set to %clss% *****
	echo ***** Data classification set to %clss% ***** >> %results_file%
	
	rem Get list of local drives
	for /f %%d in ('wmic logicaldisk where "drivetype=3" get caption ^| find ":"') do (
		echo Searching in %%d\
		call :search "%%d\" %search_file1%
		call :search "%%d\" %search_file2%
	)
:tail
	rem tail entries for ref.
	echo ***** Data classification set to %clss% *****
	echo BMN Number: BMN%BMN% >> %results_file%
	echo BMN Number: BMN%BMN%
	echo Hostname: %computername% >> %results_file%
	echo Hostname: %computername% 
	echo %osversion% %osv% >> %results_file%
	echo %osversion% %osv%
	echo WMIC used? - %wmic% >> %results_file%
	echo WMIC used? - %wmic%
	echo Script version: %scriptver% >> %results_file%
	echo Script version: %scriptver%
	echo Did the user set admin? %admin% >> %results_file%
	echo Did the user set admin? %admin%
	echo User selected classification: %clss% >> %results_file%

REM check if JAVA_HOME is defined and test
if not defined JAVA_HOME (
  echo JAVA_HOME is not set >> %results_file%
  goto end
)

	REM run java -version using JAVA_HOME
	rem echo Running java -version
	rem "%JAVA_HOME%\bin\java.exe" -version

	echo "Script message ***** Running java env check *****"
	echo ***** java env check *****

	@echo off
	REM check if JAVA_HOME is defined
	if not defined JAVA_HOME (
	  echo JAVA_HOME is not set
	  goto end
	)

	REM run java -version using JAVA_HOME
	echo Running java -version >> %results_file%
	"%JAVA_HOME%\bin\java.exe" -version >> %results_file%

:end
	echo Search complete. Results saved to %results_file%

	set /p rerun="Do you want to rerun the script? (yes/no): "
	if /i "%rerun%"=="yes" goto begin
rem search for java and format
:search
	for /r %1 %%f in (%2) do (
		echo Found: %%f >> %results_file%
		echo Found: %%f
		
		rem Display only "Name" and "Version" properties using WMIC
		set "filepath=%%f"
		for /f "tokens=1,* delims==" %%p in ('wmic datafile where "name='!filepath:\=\\!'" get /format:list ^| find "="') do (
			if "%%p"=="Manufacturer" (
				echo Supplier: %%q
				echo Supplier: %%q >> %results_file%
				echo %%q | findstr /C:"Oracle Corporation" >nul && (
					echo WARNING: Oracle Java found: %%f >> %results_file%
					echo WARNING: Oracle Java found: %%f
				)
				echo %%q | findstr /C:"Sun Microsystems" >nul && (
					echo WARNING: Sun Java found: %%f >> %results_file%
					echo WARNING: Sun Java found: %%f
				)
			)
:Version
if "%%p"=="Version" (
    echo Original Version: %%q
	echo Original Version: %%q >> %results_file%
    rem Extract major, minor, and patch versions
    for /f "tokens=1-3 delims=." %%v in ("%%q") do (
        set "major=%%v"
        set "minor=%%w"
        set "patch=%%x"
	rem remove 0.X from the patch number 
	if "!patch:~-1!"=="0" set "patch=!patch:~0,-1!"
	rem Fix baseline X.0.0 versions 
	if "!patch!"=="" set "patch=0"
    )
    echo Major: !major!, Minor: !minor!, Update: !patch! 
    rem Format according to Java versioning schema
    if !major! LSS 9 (
        set "java_version=!major!.!minor!_!patch!"
    ) else (
        set "java_version=!major!.!minor!.!patch!"
    )
:reporting
    echo Java Version: !java_version! >> %results_file%
	rem echo "!major!.!minor!_!patch!£ >> %results_file%
	echo *************************************************************************************************************** >> %results_file%
    echo For reporting use the supplier name and this Java Version: !major!.!minor! u!patch! >> %results_file%
    echo *************************************************************************************************************** >> %results_file%
    echo . >> %results_file%
	rem screen message
    echo ***************************************************************************************************************
    echo For reporting use the Supplier name and this Java Version !major!.!minor! u!patch! 
    echo ***************************************************************************************************************
    echo .
	
	    rem Clear major, minor, and patch after each pass
    set "major="
    set "minor="
    set "patch="
)

    )
)
exit /b

:begindebug

:admincheck
REM Check if the user is running as admin (administrator)
>nul 2>&1 net session
if %errorlevel% == 0 (
	set admin=Yes
    echo User is running as administrator.
    goto debug
) else (
	set admin=No
    echo WARNING: NOT running as administrator. the script will now exit
pause
)
exit/b

:debug
color 1F
setlocal enabledelayedexpansion
set "BMN=DEBUG"
set "search_file1=*java.exe"
set "search_file2=*javaw.exe"
set "search_file3=*javac.exe"
set "search_file4=*javas.exe"

rem Get the current date and time
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%"

set "datestamp=%YYYY%%MM%%DD%-%HH%%Min%"
set "debug_file=BMN%BMN%-%computername%-%datestamp%.txt"

rem Get list of local drives
for /f %%d in ('wmic logicaldisk where "drivetype=3" get caption ^| find ":"') do (
    echo Searching in %%d\
    call :searchdebug "%%d\" %search_file1%
    call :searchdebug "%%d\" %search_file2%
	call :searchdebug "%%d\" %search_file3%
	call :searchdebug "%%d\" %search_file4%	
)

echo Hostname: %computername% >> %debug_file%
echo BMN Number: BMN%BMN% >> %debug_file%

@echo off
REM check if JAVA_HOME is defined and test
if not defined JAVA_HOME (
  echo JAVA_HOME is not set >> %debug_file%
  goto enddebug
)
REM run java -version using JAVA_HOME
echo Running java -version
"%JAVA_HOME%\bin\java.exe" -version >> %debug_file%

:enddebug
echo Search complete. Results saved to %debug_file%

set /p rerun="Do you want to rerun the script? (yes/no): "
if /i "%rerun%"=="yes" goto begindebug
 exit /b
 
:searchdebug
for /r %1 %%f in (%2) do (
    echo Found: %%f >> %debug_file%
    echo Found: %%f
    
    rem Display all properties using WMIC
    set "filepath=%%f"
    for /f "tokens=1,* delims==" %%p in ('wmic datafile where "name='!filepath:\=\\!'" get /format:list ^| find "="') do (
        echo File Property: %%p=%%q >> %debug_file%
        echo File Property: %%p=%%q
		
        rem Add your additional checks or actions here if needed
    )
)
