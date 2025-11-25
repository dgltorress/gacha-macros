#Requires AutoHotkey >=2.0

; Utils


; Input

pressKey(key) {
  Send(Format("{{1} down}", key))
  Sleep(Random(80, 100))
  Send(Format("{{1} up}", key))
}

holdKey(key, time, variance := 20) {
  Send(Format("{{1} down}", key))
  Sleep(Random(time, time + variance))
  Send(Format("{{1} up}", key))
}

spamKey(key, times := 3) {
  Loop (times) {
    pressKey(key)
    Sleep(Random(80, 120))
  }
}

clickExact(x, y) {
  Click("L", x, y,,"D")
  Sleep(Random(60, 120))
  Click("L",,,,"U")
}

clickAround(xMin, yMin, xMaxOffset := 20, yMaxOffset := 20) {
  clickExact(Random(xMin, xMin + xMaxOffset), Random(yMin, yMin + yMaxOffset))
}

spamClick(x, y, times := 3) {
  Loop (times) {
    clickExact(x, y)
    Sleep(Random(100, 200))
  }
}

spamClickAround(xMin, yMin, times := 3, xMaxOffset := 20, yMaxOffset := 20) {
  spamClick(Random(xMin, xMin + xMaxOffset), Random(yMin, yMin + yMaxOffset), times)
}

scroll(x, y, direction, times := 1) {
  Loop (times) {
    Click(Format("W{1}", direction), x, y,, "D")
    Sleep(Random(35, 55))
  }
}

scrollAround(xMin, yMin, direction, times := 1, xMaxOffset := 20, yMaxOffset := 20) {
  scroll(Random(xMin, xMin + xMaxOffset), Random(yMin, yMin + yMaxOffset), direction, times)
}

; Logging

class Logger {
  __New(path) {
    this.path := path
    this.file := ''
    try {
      this.file := FileOpen(this.path, 'w')
    } catch as e {
      MsgBox(Format("WARN: Failed to open log file at `"{1}`": {2}", this.path, e.Message))
    }
  }
  __Delete() {
    this.path := ''
    if (this.hasFile()) {
      try {
        this.file.Close()
      } catch as e {
        MsgBox(Format("WARN: Failed to close log file at `"{1}`": {2}", this.path, e.Message))
      }
      this.file := ''
    }
  }
  log(msg) {
    if (this.hasFile()) {
      try {
        this.file.WriteLine(Format("{1} | {2}", A_Now, %msg%))
      } catch as e {
        MsgBox(Format("WARN: Failed to write into log file at `"{1}`" (position {2}): {3}", this.path, this.hasFile() ? this.file.Pos : 0, e.Message))
      }
    }
  }
  hasFile() {
    return !!this.file
  }
}

LOGGER_I := ''

log(msg) {
  global LOGGER_I
  if (LOGGER_I) {
    LOGGER_I.log(msg)
  }
}

openLog() {
  global LOGGER_I := Logger(Format("{1}\run.log", A_ScriptDir))
}

closeLog() {
  global LOGGER_I := ''
}

exit() {
  closeLog()
  ExitApp()
}

; Other

isColor(x, y, color, tolerance := 0) {
  if (tolerance > 0) {
    return PixelSearch(&px, &py, x, y, x, y, color, tolerance)
  } else {
    return PixelGetColor(x, y) == color
  }
}

compareColorBrightness(x, y, r0, g0, b0) {
  color := PixelGetColor(x, y)
  r := Format("0x{1}", SubStr(color, 3, 2))
  g := Format("0x{1}", SubStr(color, 5, 2))
  b := Format("0x{1}", SubStr(color, 7, 2))
  if ((r < r0) && (g < g0) && (b < b0)) {
    return -1
  } else if ((r > r0) && (g > g0) && (b > b0)) {
    return 1
  } else {
    return 0
  }
}

isUltrawide() {
  return (A_ScreenWidth / A_ScreenHeight) > 1.8
}

STANDARD_WIDTH := 1920 ; reassign as global variable from within app-specific logic if a different resolution was used for measurements
STANDARD_HEIGHT := 1080
ULTRAWIDE_OFFSET := 0

normalizeX(x) {
  if (A_ScreenWidth != STANDARD_WIDTH) {
    return (x * (A_ScreenWidth - ULTRAWIDE_OFFSET - ULTRAWIDE_OFFSET) // STANDARD_WIDTH) + ULTRAWIDE_OFFSET
  }
  return x
}

ULTRAWIDE_OFFSET := isUltrawide() ? (A_ScreenWidth - STANDARD_WIDTH) // 2 : 0

normalizeY(y) {
  if (A_ScreenHeight != STANDARD_HEIGHT) {
    return (y * A_ScreenHeight) // STANDARD_HEIGHT
  }
  return y
}


; https://learn.microsoft.com/en-us/windows/win32/winmsg/wm-geticon
; https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-setclasslongptra
getIconHandle(&iconHandle, windowHandle, big := false, dpi := A_ScreenDPI) {
  WM_GETICON := 0x007F
  SIZE_WPARAM := big ? 1 : 0
  GCLP_HICON_ARG := big ? -14 : -34
  ; prompt the target window to modify the tray icon with its own
  try {
    SendMessage(WM_GETICON, SIZE_WPARAM, dpi,, Format("ahk_id {1}", windowHandle))
  } catch as e {
    log(Format("ERROR: Unable to modify the tray icon using window with handle {1} - {2}", windowHandle, e.Message))
  }
  ; get the icon from the tray
  try {
    iconHandle := DllCall("GetClassLongPtr", "Ptr", windowHandle, "Int", GCLP_HICON_ARG)
  } catch as e {
    log(Format("ERROR: Unable to get the icon from the tray using window with handle {1} - {2}", windowHandle, e.Message))
  }
}

isDarkMode() {
  return !RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
}
