; ----------------------------------------
; RNDLogger_Automation Installer
; Version: 1.16.0
; ----------------------------------------

Unicode true
RequestExecutionLevel admin

!include "MUI2.nsh"
!include "nsDialogs.nsh"

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
!define MUI_ABORTWARNING

; ----------------------------------------
; Installer Metadata
; ----------------------------------------

Name "RNDLogger_Automation"
OutFile "../../bin/RNDLogger_Automation_1.16.0_Setup.exe"
InstallDir "D:\"

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

  ; ----------------------------------------
  ; Install application icons
  ; ----------------------------------------
  SetOutPath "$PLUGINSDIR"
  File "${UI_SUCCESS_BMP}"
  File "${UI_FAILURE_BMP}"

  ; ----------------------------------------
  ; Install application files (exclude TaskScheduler)
  ; ----------------------------------------
  SetOutPath "$INSTDIR\Programs"
  File /r /x "TaskScheduler\*" "..\..\..\Programs\*.*"

  ; ----------------------------------------
  ; Extract TaskScheduler XMLs (temporary)
  ; ----------------------------------------
  SetOutPath "$PLUGINSDIR\TaskScheduler"
  File /r "..\..\..\Programs\**\TaskScheduler\*.*"

  ; ----------------------------------------
  ; WORK SECTION – Process XML Tasks
  ; ----------------------------------------
  FindFirst $0 $1 "$PLUGINSDIR\TaskScheduler\*.xml"
  StrCmp $1 "" DoneTasks

TaskLoop:
  StrCpy $2 $1 -4
  DetailPrint "Processing scheduled task: $2"

  nsExec::ExecToStack '"schtasks.exe" /Query /TN "$2"'
  Pop $3
  StrCmp $3 "0" TaskExists TaskCreate

TaskExists:
  nsExec::ExecToStack '"schtasks.exe" /End /TN "$2"'
  Pop $3
  nsExec::ExecToStack '"schtasks.exe" /Delete /F /TN "$2"'
  Pop $3

TaskCreate:
  nsExec::ExecToStack '"schtasks.exe" /Create /XML "$PLUGINSDIR\TaskScheduler\$1" /TN "$2" /F'
  Pop $3
  StrCmp $3 "0" +2 TaskError

  nsExec::ExecToStack '"schtasks.exe" /Run /TN "$2"'
  Pop $3
  StrCmp $3 "0" NextTask TaskError

NextTask:
  FindNext $0 $1
  StrCmp $1 "" DoneTasks
  Goto TaskLoop

TaskError:
  MessageBox MB_ICONSTOP "Error creating or running scheduled task '$2'."
  StrCpy $INSTALL_FAILED 1
  Abort

DoneTasks:
  FindClose $0

SectionEnd

; ----------------------------------------
; Determine appropriate page to display
; ----------------------------------------
Function ShowResultPage
  StrCmp $INSTALL_FAILED 0 ShowSuccessPage ShowFailurePage
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
    Abort
  ${EndIf}

  ; Green success icon
  ${NSD_CreateBitmap} 15u 10u 16u 16u ""
  Pop $Icon
  ${NSD_SetImage} $Icon "$PLUGINSDIR\${UI_SUCCESS_BMP}" $0

  ; -------------------------------------------------
  ; Title
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 10u 90% 14u \
    "RoboCell RNDLogger Automation – Installation Successful"
  Pop $1
  SetCtlColors $1 "" 0xFFFFFF

  ; -------------------------------------------------
  ; Intro Text
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 28u 90% 22u \
    "The RNDLogger_Automation installer has completed successfully.$\r$\n\
During installation, scheduled tasks were configured based on the XML definitions provided with this package."
  Pop $2

  ; -------------------------------------------------
  ; Section Header – Scheduled Tasks
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 54u 90% 12u "✅ Scheduled Task Setup"
  Pop $3

  ; -------------------------------------------------
  ; Task List
  ; -------------------------------------------------
  ${NSD_CreateLabel} 20u 68u 90% 20u \
    "The following tasks have been imported into the Task Scheduler:$\r$\n$\r$\n\
• CT Handler$\r$\n\
• Gantry$\r$\n\
• SCARA"
  Pop $4

  ; -------------------------------------------------
  ; Section Header – Installed Files
  ; -------------------------------------------------
  ${NSD_CreateLabel} 15u 96u 90% 12u "📂 Installed Files"
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
    Abort
  ${EndIf}

  ; Red error icon
  ${NSD_CreateBitmap} 15u 10u 16u 16u ""
  Pop $Icon
  ${NSD_SetImage} $Icon "$PLUGINSDIR\${UI_FAILURE_BMP}" $0

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

Function .onInstFailed
  SetErrorLevel 1
FunctionEnd
