::| created by swyter!
::| requires wget, egrep, sed and 7z. virtualbox is recommended.

@echo off && title [ Get daily builds from ReactOS.org ] -- by swyter

echo [x] Getting latest build number from ^<Reactos.org^>
wget http://reactos.org/getbuilds -q -O revnumber.tmp

::we open the HTML file, grep the line with the "e.g XXXXXX" string and then redirect the output to sed.
::then sed outputs only the interesting part. All this is saved to a local variable using a hack.
 
::hack source: <http://justgeeks.blogspot.com/2008/07/save-output-of-dos-command-to-variable.html>
for /f "tokens=1 delims=" %%A in ('egrep -E "\e\.\g\. [0-9]+" revnumber.tmp ^| sed -r "s/.*[-]([0-9]+).*/\1/"') do set revNumber=%%A

::we don't need this anymore.
del revnumber.tmp

            echo ^|   Latest available version: %revNumber%
set /p "revNumber=|   Revision number [or press Enter for getting %revNumber%]:  "


if not exist bootcd-%revNumber%-dbg.iso (
	echo [x] Downloading ISO
	wget http://iso.reactos.org/bootcd/bootcd-%revNumber%-dbg.7z --no-clobber

  if exist bootcd-%revNumber%-dbg.7z (
    echo [x] Extracting it
    7z x bootcd-%revNumber%-dbg.7z -y
    
    if %ERRORLEVEL% LEQ 1 (
      echo [x] Cleaning up...
      del bootcd-%revNumber%-dbg.7z /F
    )
  ) else (
    echo ^|   7z not downloaded... bad luck, wait a bit...
  )
	
) else (
	echo ^|   ISO already there...
)


:: name of your virtual machine...
set mach=ROS
:: name of the storage controller, usually "IDE controller" or localized...
set ctlr=Controlador IDE
::-----------------------

if exist bootcd-%revNumber%-dbg.iso (
	echo [x] Mounting image and starting virtual machine...
	
	set PATH=%VBOX_INSTALL_PATH%
	VBoxManage storageattach "%mach%" --storagectl "%ctlr%" --port 0 --device 1 --type dvddrive --medium %cd%\bootcd-%revNumber%-dbg.iso
	VBoxManage       startvm "%mach%" --type gui
)
	echo [x] Finished
echo _______________________________ && echo Done, press any key to exit...
pause > nul