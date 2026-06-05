; ============================================================
; EmbedBmp.nsh
;
; Compile-time BMP embedding helper for NSIS.
;
; Purpose:
;   Allows BMP images to be defined inline as HEX strings
;   inside an .nsi file and converted to real BMP files
;   at compile time.
;
; Requirements:
;   - NSIS on Windows
;   - certutil.exe available at compile time (default on Win10/11)
;
; Usage:
;   !include "EmbedBmp.nsh"
;   !define MY_ICON_HEX "424D..."
;   !insertmacro EmbedBmp "my_icon.bmp" "${MY_ICON_HEX}"
;
; Result:
;   - my_icon.bmp generated at compile-time
;   - Can be embedded using File "my_icon.bmp"
;
; Notes:
;   - HEX data must be continuous (no indentation)
;   - BMP only (recommended 24-bit, no alpha)
; ============================================================

!ifndef __EMBEDBMP_NSH__
!define __EMBEDBMP_NSH__

; ------------------------------------------------------------
; !macro EmbedBmp
;
; Parameters:
;   OUT_BMP_NAME  - Output BMP filename (relative or absolute)
;   HEX_DATA      - Continuous hex string representing BMP
;
; Example:
;   !insertmacro EmbedBmp "success.bmp" "${SUCCESS_BMP_HEX}"
; ------------------------------------------------------------
!macro EmbedBmp OUT_BMP_NAME HEX_DATA

  ; Capture a unique ID ONCE
  !define _EMBED_ID ${__COUNTER__}

  ; Create unique compile-time temp files
  !tempfile EMBEDBMP_HEX_${_EMBED_ID}
  !tempfile EMBEDBMP_BMP_${_EMBED_ID}

  ; Write HEX to temp file
  !system 'cmd /c echo ${HEX_DATA} > "${EMBEDBMP_HEX_${_EMBED_ID}}"'

  ; Decode HEX -> BMP into temp file
  !system 'cmd /c certutil -decodehex "${EMBEDBMP_HEX_${_EMBED_ID}}" "${EMBEDBMP_BMP_${_EMBED_ID}}" > nul'

  ; Add BMP to installer data without leaving it on disk
  File /oname=${OUT_BMP_NAME} "${EMBEDBMP_BMP_${_EMBED_ID}}"

  ; Cleanup (compile-time)
  !system 'cmd /c del /f /q "${EMBEDBMP_HEX_${_EMBED_ID}}" "${EMBEDBMP_BMP_${_EMBED_ID}}" > nul'

  ; Cleanup symbol
  !undef _EMBED_ID

!macroend

!endif ; __EMBEDBMP_NSH__
