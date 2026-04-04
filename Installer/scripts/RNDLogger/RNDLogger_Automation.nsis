; ----------------------------------------
; RNDLogger_Automation Installer
; Version: 1.16.0
; ----------------------------------------

Unicode true
RequestExecutionLevel admin

!include "MUI2.nsh"

; ----------------------------------------
; UI Configuration
; ----------------------------------------

!define MUI_ABORTWARNING
!define MUI_FINISHPAGE_RUN
!define MUI_FINISHPAGE_RUN_TEXT "View installation README"
!define MUI_FINISHPAGE_RUN_FUNCTION ShowReadme

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
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

; ----------------------------------------
; Main Install Section
; ----------------------------------------
Section "Install"

  ; ----------------------------------------
  ; Prepare installer working directory
  ; ----------------------------------------
  InitPluginsDir

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
  ; Extract README_success.md to installer temp area
  ; ----------------------------------------
  SetOutPath "$PLUGINSDIR"
  File "README_success.md"

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
  MessageBox MB_ICONSTOP "Error creating or running scheduled task '$2'. Installation has been cancelled."
  Abort

DoneTasks:
  FindClose $0

SectionEnd

; ----------------------------------------
; Finish Page README Display
; ----------------------------------------
Function ShowReadme
  ExecShell "open" "$PLUGINSDIR\README_success.md"
FunctionEnd
