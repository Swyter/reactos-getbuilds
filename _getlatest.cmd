::| created by swyter!
::| requires wget, egrep, sed and 7z. virtualbox is recommended.

@echo off && goto :start

:print
	echo.   %1
	goto :eof

:start
echo [x] Getting latest build number from ^<Reactos.org^>
::wget http://reactos.org/getbuilds -nv -O revnumber.tmp
wget http://reactos.org/getbuilds -q -O revnumber.tmp
::findstr /R /I "\-[0-9][0-9][0-9][0-9][0-9]\)" index.html
::egrep "-([0-9]*)\)" index.html
::egrep --regexp="\e\.\g\. ([0-9].*)\)" index.html | sed "s/[)].*//" | sed "s/*([0-9]/\2/"
::egrep -E "\e\.\g\. [0-9]+" revnumber.tmp | sed -r "s/.*[ ]([0-9]+).*/\1/" > revnumber.tmp

::we open the HTML file, grep the line with the "e.g XXXXXX" string and then redirect the output to sed.
::then sed outputs only the interesting part. All this is saved to a local variable using a hack.

::source: <http://justgeeks.blogspot.com/2008/07/save-output-of-dos-command-to-variable.html>
for /f "tokens=1 delims=" %%A in ('egrep -E "\e\.\g\. [0-9]+" revnumber.tmp ^| sed -r "s/.*[ ]([0-9]+).*/\1/"') do set revNumber=%%A

::we don't need this anymore.
del revnumber.tmp

            echo ^|   Latest available version: %revNumber%
Set /p "revNumber=|   Revision number [or press Enter for getting %revNumber%]:  "

echo [x] Downloading ISO
wget http://iso.reactos.org/bootcd/bootcd-%revNumber%-dbg.7z --no-clobber

if not exist bootcd-%revNumber%-dbg.iso (
	echo [x] Extracting it
	7z x bootcd-%revNumber%-dbg.7z -y
	
	if %ERRORLEVEL% NEQ 0 (
		echo [x] Cleaning up...
		del bootcd-%revNumber%-dbg.7z /F
	)
	
) else (
	echo ^|   ISO already there...
)

if exist bootcd-%revNumber%-dbg.iso (
	echo [x] Mounting image and starting virtual machine...
	set vbox=R:\Software\VBox
	%vbox%/VBoxManage.exe storageattach "ROS" --storagectl "Controlador IDE" --port 0 --device 1 --type dvddrive --medium %cd%\bootcd-%revNumber%-dbg.iso
	%vbox%/VBoxManage.exe startvm ROS --type gui
)
	echo [x] Finished
echo _______________________________ && echo Done, press any key to exit...
pause > nul