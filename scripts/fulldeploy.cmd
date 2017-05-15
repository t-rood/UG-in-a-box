@echo off
echo NetScaler full deploy helper
if not exist "%programfiles(x86)%\putty\pscp.exe" goto nohelpers
if not exist "%programfiles(x86)%\putty\plink.exe" goto nohelpers
if "%5" == "" goto abort
echo ### provisioning UG icon files
"%programfiles(x86)%\putty\pscp.exe" -pw %2 %3 nsroot@%1:/var/netscaler/logon/
echo ### provisioning certificate files
"%programfiles(x86)%\putty\pscp.exe" -pw %2 %4 nsroot@%1:/nsconfig/ssl/
echo ### provisioning configuration batch file
"%programfiles(x86)%\putty\pscp.exe" -batch -pw %2 %5 nsroot@%1:/var/tmp/deploybatch.conf
echo ### executing batch
"%programfiles(x86)%\putty\plink.exe" -ssh nsroot@%1 -pw %2 batch -filename /var/tmp/deploybatch.conf -outfile /var/tmp/deploybatch.conf.output
echo NetScaler deployment completed
goto final
:abort
echo bad params!
echo *** use %0 nsip nspwd iconsdir certsdir conf
echo  nsip     = NetScaler IP
echo  nspwd    = nsroot password
echo  iconsdir = path to icon files for UG bookmarks
echo  certsdir = path to certificate files
echo  conf     = batch to deploy and execute
echo aborted
goto final
:nohelpers
echo bad environment!
echo *** make sure pscp and plink (PuTTy package) are located inside of "%programfiles(x86)%\putty"
echo aborted
goto final
:final
