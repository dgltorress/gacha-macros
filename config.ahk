#Requires AutoHotkey >=2.0-a

; Window names and detection properties
class WindowSettings {
  __New(target := '', mode := 3, tolerance := 6) {
    ; Name of the window opened by the target app
    this.target := target
    ; Target window string search mode, see https://www.autohotkey.com/docs/v2/lib/SetTitleMatchMode.htm#Parameters
    this.mode := mode
    this.tolerance := tolerance
  }
}

; Time settings (all measured in milliseconds)
class TimeSettings {
  __New(timeout := 20000, poll := 375, pollVariance := 100, timeoutIntro := 300000, timeoutRaid := 120000, timeoutBackoff := 30000) {
    ; Regular timeout for most actions
    this.timeout := timeout
    ; Conditions will be evaluated every X milliseconds
    this.poll := poll
    ; Upper variance for the polling time, from which a random amount is added to the base
    this.pollVariance := pollVariance
    ; Timeout for skipping intro notices, "tap to start", videos, etc.
    this.timeoutIntro := timeoutIntro
    ; Timeout for skipping raid modes (more can be added at the app-specific settings)
    this.timeoutRaid := timeoutRaid
    ; Timeout for actions that bring the app back to a main menu
    this.timeoutBackoff := timeoutBackoff
  }
}

; Main settings
class MainSettings {
  __New(window, time, specific) {
    this.window := window
    this.time := time
    ; App-specific settings
    this.specific := isObject(specific) ? specific : {}
  }
}

; Read settings from a file
readSettings(path) {
  wSettings := WindowSettings()
  tSettings := TimeSettings()
  sSettings := {}
  settings := MainSettings(wSettings, tSettings, sSettings)
  if (FileExist(path)) {
    configFile := unset
    try {
      configFile := FileOpen(path, 'r')
    } catch as e {
      MsgBox(Format("WARN: Failed to open existing configuration file at `"{1}`": {2}", path, e.Message))
    }
    if (configFile) {
      try {
        currentSection := 0
        while (!configFile.AtEOF) {
          line := configFile.ReadLine()
          if (StrLen(line) < 3)  {
            continue
          }
          if (SubStr(line, 1, 1) == "[") {
            switch (line) {
              case "[window]": currentSection := 1
              case "[time]": currentSection := 2
              case "[specific]": currentSection := 3
              default: currentSection := 0
            }
            continue
          } else {
            pair := StrSplit(line, "=")
            if (pair.Length == 2) {
              switch (currentSection) {
                case 1: wSettings.%pair[1]% := pair[2]
                case 2: tSettings.%pair[1]% := pair[2]
                case 3: sSettings.%pair[1]% := pair[2]
              }
            }
          }
        }
      } catch as e {
        MsgBox(Format("WARN: Failed to read line from configuration file at `"{1}`" ({2}): {3}", path, configFile.Pos, e.Message))
      }
      try {
        configFile.Close()
      } catch as e {
        MsgBox(Format("WARN: Failed to close configuration file at `"{1}`": {2}", path, e.Message))
      }
    }
  }
  return settings
}

writeSection(openFile, name, values) {
  openFile.WriteLine(Format("[{1}]", name))
  for k, v in values.OwnProps() {
    openFile.WriteLine(Format("{1}={2}", k, v))
  }
  openFile.WriteLine()
}

writeSetting(openFile, settings) {
  writeSection(openFile, "window", settings.window)
  writeSection(openFile, "time", settings.time)
  writeSection(openFile, "specific", settings.specific)
}

; Write settings into a file
writeSettings(settings, path) {
  success := false
  configFile := unset
  try {
    configFile := FileOpen(path, 'w')
  } catch as e {
    MsgBox(Format("WARN: Failed to create configuration file at `"{1}`": {2}", path, e.Message))
  }
  if (configFile) {
    try {
      writeSetting(configFile, settings)
      success := true
    } catch as e {
      MsgBox(Format("WARN: Failed to write line into configuration file at `"{1}`" ({2}): {3}", path, configFile.Pos, e.Message))
    }
    try {
      configFile.Close()
    } catch as e {
      MsgBox(Format("WARN: Failed to close configuration file at `"{1}`": {2}", path, e.Message))
    }
  }
  return success
}
