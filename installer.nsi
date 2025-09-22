; Mouse Speed Detector Installer Script
; Developer: Anand Kumar Sharma
; Portfolio: www.anandsharma.online

!define APPNAME "Mouse Speed Detector"
!define COMPANYNAME "Anand Kumar Sharma"
!define DESCRIPTION "A Windows utility that detects fast mouse movements and displays visual feedback"
!define VERSIONMAJOR 1
!define VERSIONMINOR 0
!define VERSIONBUILD 0
!define HELPURL "https://www.anandsharma.online"
!define UPDATEURL "https://www.anandsharma.online"
!define ABOUTURL "https://www.anandsharma.online"
!define INSTALLSIZE 5120 ; Size in KB

; Modern UI
!include "MUI2.nsh"

; Define installer name and output file
Name "${APPNAME}"
OutFile "MouseSpeedDetectorInstaller.exe"
InstallDir "$PROGRAMFILES64\${APPNAME}"

; Request application privileges for Windows Vista/7/8/10/11
RequestExecutionLevel admin

; MUI Settings
!define MUI_ABORTWARNING
; Optional icon files - will use defaults if not found
!if /FileExists "icon.ico"
    !define MUI_ICON "icon.ico"
    !define MUI_UNICON "icon.ico"
!endif
!if /FileExists "welcome.bmp"
    !define MUI_WELCOMEFINISHPAGE_BITMAP "welcome.bmp"
    !define MUI_UNWELCOMEFINISHPAGE_BITMAP "welcome.bmp"
!endif

; Welcome page with clean professional text
!define MUI_WELCOMEPAGE_TITLE "Welcome to ${APPNAME} Setup"
!define MUI_WELCOMEPAGE_TEXT "This wizard will guide you through the installation of ${APPNAME}.$\r$\n$\r$\n${DESCRIPTION}$\r$\n$\r$\nDeveloped by: ${COMPANYNAME}$\r$\nPortfolio: ${ABOUTURL}$\r$\n$\r$\nFeatures:$\r$\n- Real-time mouse movement detection$\r$\n- Visual feedback with overlay display$\r$\n- Configurable speed threshold$\r$\n- Low resource usage$\r$\n$\r$\nClick Next to continue."
!insertmacro MUI_PAGE_WELCOME

; License page
!insertmacro MUI_PAGE_LICENSE "LICENSE.txt"

; Directory page
!insertmacro MUI_PAGE_DIRECTORY

; Components page
!insertmacro MUI_PAGE_COMPONENTS

; Instfiles page
!insertmacro MUI_PAGE_INSTFILES

; Finish page with clean professional text
!define MUI_FINISHPAGE_RUN "$INSTDIR\mouse-speed-detector.exe"
!define MUI_FINISHPAGE_RUN_TEXT "Start ${APPNAME} now"
!define MUI_FINISHPAGE_LINK "Visit Developer Portfolio - ${ABOUTURL}"
!define MUI_FINISHPAGE_LINK_LOCATION "${ABOUTURL}"
!define MUI_FINISHPAGE_TITLE "${APPNAME} Installation Complete"
!define MUI_FINISHPAGE_TEXT "${APPNAME} has been successfully installed on your computer.$\r$\n$\r$\nInstallation completed successfully$\r$\n$\r$\nUsage Instructions:$\r$\n- Move your mouse quickly (>800 px/sec)$\r$\n- Watch for the red overlay indicator$\r$\n- Configure settings as needed$\r$\n$\r$\nDeveloper: ${COMPANYNAME}$\r$\nPortfolio: ${ABOUTURL}$\r$\n$\r$\nThank you for using ${APPNAME}!"
!insertmacro MUI_PAGE_FINISH

; Uninstaller pages
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

; Languages
!insertmacro MUI_LANGUAGE "English"

; Version Information
VIProductVersion "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${APPNAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "${COMPANYNAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "© 2024 ${COMPANYNAME}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${DESCRIPTION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}.0"
VIAddVersionKey /LANG=${LANG_ENGLISH} "InternalName" "mouse-speed-detector"
VIAddVersionKey /LANG=${LANG_ENGLISH} "OriginalFilename" "mouse-speed-detector.exe"

; Default section (required)
Section "${APPNAME} (required)" SecMain
    SectionIn RO
    
    ; Set output path to the installation directory
    SetOutPath "$INSTDIR"
    
    ; Copy files to installation directory
    File "target\release\mouse-speed-detector.exe"
    File "README.md"
    File "LICENSE.txt"
    
    ; Create Start Menu folder
    CreateDirectory "$SMPROGRAMS\${APPNAME}"
    
    ; Create shortcuts with clean descriptions
    CreateShortCut "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk" "$INSTDIR\mouse-speed-detector.exe" "" "$INSTDIR\mouse-speed-detector.exe" 0 SW_SHOWNORMAL "" "Advanced mouse movement detection utility"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\README.lnk" "$INSTDIR\README.md" "" "" 0 SW_SHOWNORMAL "" "Application documentation and usage guide"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "" 0 SW_SHOWNORMAL "" "Remove ${APPNAME} from your computer"
    CreateShortCut "$SMPROGRAMS\${APPNAME}\Developer Portfolio.lnk" "${ABOUTURL}" "" "" 0 SW_SHOWNORMAL "" "Visit ${COMPANYNAME}'s portfolio website"
    
    ; Create desktop shortcut with description
    CreateShortCut "$DESKTOP\${APPNAME}.lnk" "$INSTDIR\mouse-speed-detector.exe" "" "$INSTDIR\mouse-speed-detector.exe" 0 SW_SHOWNORMAL "" "${DESCRIPTION}"
    
    ; Store installation folder
    WriteRegStr HKCU "Software\${APPNAME}" "" $INSTDIR
    
    ; Create uninstaller
    WriteUninstaller "$INSTDIR\uninstall.exe"
    
    ; Add to Add/Remove Programs
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayName" "${APPNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "InstallLocation" "$INSTDIR"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayIcon" "$INSTDIR\mouse-speed-detector.exe"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "Publisher" "${COMPANYNAME}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "HelpLink" "${HELPURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLUpdateInfo" "${UPDATEURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "URLInfoAbout" "${ABOUTURL}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "DisplayVersion" "${VERSIONMAJOR}.${VERSIONMINOR}.${VERSIONBUILD}"
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMajor" ${VERSIONMAJOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "VersionMinor" ${VERSIONMINOR}
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoModify" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "NoRepair" 1
    WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "EstimatedSize" ${INSTALLSIZE}
SectionEnd

; Optional section for startup
Section "Start with Windows" SecStartup
    WriteRegStr HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}" "$INSTDIR\mouse-speed-detector.exe"
SectionEnd

; Optional section for Visual C++ Redistributable
Section "Visual C++ Redistributable" SecVCRedist
    SetOutPath "$TEMP"
    File /nonfatal "vc_redist.x64.exe"
    ExecWait '"$TEMP\vc_redist.x64.exe" /quiet /norestart'
    Delete "$TEMP\vc_redist.x64.exe"
SectionEnd

; Section descriptions with clean formatting
!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
!insertmacro MUI_DESCRIPTION_TEXT ${SecMain} "Core application files and documentation (required)$\r$\nIncludes: ${APPNAME} executable, README, and license"
!insertmacro MUI_DESCRIPTION_TEXT ${SecStartup} "Automatically start ${APPNAME} when Windows starts$\r$\nRecommended for continuous mouse monitoring"
!insertmacro MUI_DESCRIPTION_TEXT ${SecVCRedist} "Install Visual C++ Redistributable packages$\r$\nRequired runtime libraries (needed on some systems)"
!insertmacro MUI_FUNCTION_DESCRIPTION_END

; Uninstaller section
Section "Uninstall"
    ; Remove registry keys
    DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}"
    DeleteRegKey HKCU "Software\${APPNAME}"
    DeleteRegValue HKCU "Software\Microsoft\Windows\CurrentVersion\Run" "${APPNAME}"
    
    ; Remove files and uninstaller
    Delete "$INSTDIR\mouse-speed-detector.exe"
    Delete "$INSTDIR\README.md"
    Delete "$INSTDIR\LICENSE.txt"
    Delete "$INSTDIR\uninstall.exe"
    
    ; Remove shortcuts
    Delete "$SMPROGRAMS\${APPNAME}\${APPNAME}.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\README.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Uninstall.lnk"
    Delete "$SMPROGRAMS\${APPNAME}\Developer Portfolio.lnk"
    Delete "$DESKTOP\${APPNAME}.lnk"
    
    ; Remove directories
    RMDir "$SMPROGRAMS\${APPNAME}"
    RMDir "$INSTDIR"
SectionEnd

; Functions
Function .onInit
    ; Check if already installed
    ReadRegStr $R0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${APPNAME}" "UninstallString"
    StrCmp $R0 "" done
    
    MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
    "${APPNAME} is already installed. $\n$\nClick `OK` to remove the previous version or `Cancel` to cancel this upgrade." \
    IDOK uninst
    Abort
    
    uninst:
        ClearErrors
        ExecWait '$R0 _?=$INSTDIR'
        
        IfErrors no_remove_uninstaller done
            no_remove_uninstaller:
    
    done:
FunctionEnd