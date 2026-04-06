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

  ; Create a temporary file for HEX source (compile-time only)
  !tempfile __embedbmp_hexfile

  ; Write HEX content to temp file
  !system 'cmd /c echo ${HEX_DATA} > "${__embedbmp_hexfile}"'

  ; Decode HEX -> BMP using certutil
  ; Output is the requested BMP filename
  !system 'cmd /c certutil -decodehex "${__embedbmp_hexfile}" "${OUT_BMP_NAME}" > nul'

!macroend

!endif ; __EMBEDBMP_NSH__
