; ----------------------------------------
; RNDLogger_Automation Installer
; Version: 1.16.0
; ----------------------------------------

Unicode true
RequestExecutionLevel admin

!include "MUI2.nsh"
!include "nsDialogs.nsh"
!include "WinMessages.nsh"

!addincludedir "../../nsh"
!include "EmbedBmp.nsh"
!include "UIAssets.nsh"

; ----------------------------------------
; Variables
; ----------------------------------------
Var INSTALL_FAILED
Var Icon

; ----------------------------------------
; UI Configuration
; ----------------------------------------
!define APP_VERSION "1.16"
!define APP_BASE_DIR "RNDLogger_v${APP_VERSION}"

!define MUI_ABORTWARNING

; ----------------------------------------
; Installer Metadata
; ----------------------------------------

Name "RNDLogger_Automation"
OutFile "../../bin/RNDLogger_Automation_1.16.0_Setup.exe"
InstallDir "D:\Programs"

ShowInstDetails show
SilentInstall normal

; ----------------------------------------
; Pages
; ----------------------------------------

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
Page custom ShowResultPage

!insertmacro MUI_LANGUAGE "English"

; ----------------------------------------
; Main Install Section
; ----------------------------------------
Section "Install"

  StrCpy $INSTALL_FAILED 0

  ; ----------------------------------------
  ; Prepare installer working directory
  ; ----------------------------------------
  InitPluginsDir

  CreateDirectory "$PLUGINSDIR\bin"
  CreateDirectory "$PLUGINSDIR\tasks"
  CreateDirectory "$PLUGINSDIR\ui"

  ; ----------------------------------------
  ; Install application icons
  ; ----------------------------------------
  SetOutPath "$PLUGINSDIR\ui"

!insertmacro EmbedBmp "${UI_SUCCESS_BMP}" "${UI_SUCCESS_BMP_HEX}"
!insertmacro EmbedBmp "${UI_FAILURE_BMP}" "${UI_FAILURE_BMP_HEX}"

  ; ----------------------------------------
  ; Extract Binary Executable (temporary)
  ; ----------------------------------------
  SetOutPath "$PLUGINSDIR\bin"
  File /nonfatal "..\..\..\Programs\${APP_BASE_DIR}\bin\*.exe"

  ; ----------------------------------------
  ; Extract TaskScheduler XMLs (temporary)
  ; ----------------------------------------
  SetOutPath "$PLUGINSDIR\tasks"
  File /nonfatal "..\..\..\Programs\${APP_BASE_DIR}\TaskScheduler\*.xml"

  ; ----------------------------------------
  ; Install application files (exclude TaskScheduler)
  ; ----------------------------------------

  SetOutPath "$INSTDIR\${APP_BASE_DIR}"
  File /r \
    /xr "bin" \
    /xr "TaskScheduler" \
    "..\..\..\Programs\${APP_BASE_DIR}\*"

  ; ----------------------------------------
  ; Copy executables to target program locations
  ; ----------------------------------------

  IfFileExists "$PLUGINSDIR\bin\*.exe" +4 0
    MessageBox MB_ICONSTOP "No executables were found to copy."
    StrCpy $INSTALL_FAILED 1
    Goto DoneTasks

  ClearErrors
  CopyFiles "$PLUGINSDIR\bin\${APP_BASE_DIR}.exe" "$INSTDIR\${APP_BASE_DIR}\CT Handler\${APP_BASE_DIR}.exe"
  CopyFiles "$PLUGINSDIR\bin\${APP_BASE_DIR}.exe" "$INSTDIR\${APP_BASE_DIR}\Gantry\${APP_BASE_DIR}.exe"
  CopyFiles "$PLUGINSDIR\bin\${APP_BASE_DIR}.exe" "$INSTDIR\${APP_BASE_DIR}\SCARA\${APP_BASE_DIR}.exe"

  ; ----------------------------------------
  ; WORK SECTION – Process XML Tasks
  ; ----------------------------------------

  IfFileExists "$PLUGINSDIR\tasks\*.xml" +4 0
    MessageBox MB_ICONSTOP "No scheduled task XML files were found."
    StrCpy $INSTALL_FAILED 1
    Goto DoneTasks

  ClearErrors
  FindFirst $0 $1 "$PLUGINSDIR\tasks\*.xml"
  IfErrors TaskError

TaskLoop:
  StrCpy $2 $1 -4
  DetailPrint "Processing scheduled task: $2"
  DetailPrint "   tasks\$1"

  nsExec::ExecToStack '"schtasks.exe" /Query /TN "\$2"'
  Pop $3
  Pop $4
DetailPrint "Here!: $3"
DetailPrint "Here!: $4"
  ${If} $3 == 0
    nsExec::ExecToStack '"schtasks.exe" /End /TN "\$2"'
    Pop $3
    nsExec::ExecToStack '"schtasks.exe" /Delete /TN "\$2" /F'
    Pop $3
  ${EndIf}

  ClearErrors
  nsExec::ExecToStack '"schtasks.exe" /Create /XML "$PLUGINSDIR\tasks\$1" /TN "\$2" /F'
  Pop $3
  Pop $4
DetailPrint "Here!!: $3"
DetailPrint "Here!!: $4"
  StrCmp $3 "0" 0 TaskError

  ClearErrors
  nsExec::ExecToStack '"schtasks.exe" /Run /TN "\$2"'
  Pop $3
  Pop $4
DetailPrint "Here!!!: $3"
DetailPrint "Here!!!: $4"
  StrCmp $3 "0" 0 TaskError

  FindNext $0 $1
  IfErrors DoneTasks
  Goto TaskLoop

TaskError:
  MessageBox MB_ICONSTOP "Error creating or running scheduled task '$2'."
  StrCpy $INSTALL_FAILED 1

DoneTasks:
  FindClose $0

SectionEnd

; ----------------------------------------
; Determine appropriate page to display
; ----------------------------------------
Function ShowResultPage
  ${If} $INSTALL_FAILED == 0
    Call ShowSuccessPage
  ${Else}
    Call ShowFailurePage
  ${EndIf}
FunctionEnd

; ----------------------------------------
; Success Page Display
; ----------------------------------------
Function ShowSuccessPage
  GetDlgItem $0 $HWNDPARENT 3 ; Back button
  EnableWindow $0 0

  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    MessageBox MB_ICONSTOP \
      "The installation failed, and the results page could not be displayed.$\r$\n\
Please review the installation log."
    Return
  ${EndIf}

  nsDialogs::CreateControl RichEdit20W \
    ${WS_CHILD}|${WS_VISIBLE}|${WS_VSCROLL}|${ES_MULTILINE}|${ES_READONLY} \
    0 12u 32u 96% 75% ""
  Pop $1

  ; Green success icon
  ${NSD_CreateBitmap} 15u 10u 16u 16u ""
  Pop $Icon
  ${NSD_SetImage} $Icon "$PLUGINSDIR\ui\${UI_SUCCESS_BMP}" $0

  ; -------------------------------------------------
  ; Title
  ; -------------------------------------------------
  ${NSD_CreateLabel} 36u 10u 85% 14u \
    "RoboCell RNDLogger Automation – Installation Successful"
  Pop $1
  SetCtlColors $1 "" 0xFFFFFF

  ; -------------------------------------------------
  ; Intro Text
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 28u 90% 22u \
    "The RNDLogger Automation installer has completed successfully.$\r$\n\
During installation, scheduled tasks were configured based on the XML definitions provided with this package."
  Pop $2

  ; -------------------------------------------------
  ; Section Header – Scheduled Tasks
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 54u 90% 12u "Scheduled Task Setup"
  Pop $3

  ; -------------------------------------------------
  ; Task List
  ; -------------------------------------------------
  ${NSD_CreateLabel} 20u 68u 90% 20u \
    "The following tasks have been imported into the Task Scheduler:$\r$\n$\r$\n\
- CT Handler$\r$\n\
- Gantry$\r$\n\
- SCARA"
  Pop $4

  ; -------------------------------------------------
  ; Section Header – Installed Files
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 96u 90% 12u "Installed Files"
  Pop $5

  ; -------------------------------------------------
  ; Install Path
  ; -------------------------------------------------
  ${NSD_CreateLabel} 20u 112u 90% 14u \
    "RNDLogger files have been installed to D:\Programs"
  Pop $6

  nsDialogs::Show
FunctionEnd

; ----------------------------------------
; Failure Page Display
; ----------------------------------------
Function ShowFailurePage
  GetDlgItem $0 $HWNDPARENT 3 ; Back button
  EnableWindow $0 0

  nsDialogs::Create 1018
  Pop $0
  ${If} $0 == error
    ;Abort
    MessageBox MB_ICONSTOP \
      "The installation failed, and the results page could not be displayed.$\r$\n\
Please review the installation log."
    Return

  ${EndIf}

  ; Red error icon
  ${NSD_CreateBitmap} 15u 10u 16u 16u ""
  Pop $Icon
  ${NSD_SetImage} $Icon "$PLUGINSDIR\ui\${UI_FAILURE_BMP}" $0

  ; Title
  ${NSD_CreateLabel} 35u 10u 85% 14u \
    "RoboCell RNDLogger Automation – Installation Failed"
  Pop $3

  ; Failure explanation
  ${NSD_CreateLabel} 15u 28u 90% 40u \
    "One or more required steps failed during installation.$\r$\n$\r$\n\
No changes were left in a partially configured state.$\r$\n$\r$\n\
Please review the error message shown earlier or contact support."
  Pop $4

  nsDialogs::Show
FunctionEnd

Function .onInit
  ; Ensure shell vars refer to the logged-in user
  SetShellVarContext current

  ; Default: prefer D:\Programs
  StrCpy $INSTDIR "D:\Programs"

  ; If D: does not exist, fall back to user's AppData\Local\Programs
  IfFileExists "D:\*" +2 0
    StrCpy $INSTDIR "$LOCALAPPDATA\Programs"

FunctionEnd

Function .onInstFailed
  SetErrorLevel 1
FunctionEnd

Function .onGUIEnd
  RMDir /r "$PLUGINSDIR"
FunctionEnd
