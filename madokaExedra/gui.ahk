#Requires AutoHotkey >=2.1-alpha.3

#Include "%A_ScriptDir%/../utils.ahk"
#Include "%A_ScriptDir%/config.ahk"

isDark := isDarkMode()

AppGUI := Gui("", A_ScriptName)
AppGUI.SetFont(Format("s12{1}", isDark ? " cFEFEFE" : ""), "Arial")
AppGUI.OnEvent("Close", (*) {
  exit()
})
titleText := AppGUI.AddText("Section r2 w500", A_ScriptName)
titleText.SetFont("s18", "Verdana")
AppGUI.AddText(, "Window name:")
windowNameControl := AppGUI.AddEdit("yp+0 r1 w200", APP_TARGET)
windowDetectButton := AppGUI.AddButton("Default yp+0 w80", "Detect")
windowPicture := AppGUI.AddPicture("yp+0 w24 h24")

shouldClaimMagiaBoxCheck := AppGUI.AddCheckbox(
  Format("xm+0 {1}",
    (INPUT_SETTINGS.specific.hasOwnProp("shouldMagiaBox") ? INPUT_SETTINGS.specific.shouldMagiaBox : 1) ?
    " Checked" : ""
  ), "Should claim Magia box"
)
shouldDoPvPCheck := AppGUI.AddCheckbox(
  (INPUT_SETTINGS.specific.hasOwnProp("shouldPvp") ? INPUT_SETTINGS.specific.shouldPvp : 1) ?
  "Checked" : "", "Should do PvP"
)
shouldDoTowerCheck := AppGUI.AddCheckbox(
  (INPUT_SETTINGS.specific.hasOwnProp("shouldTower") ? INPUT_SETTINGS.specific.shouldTower : 1) ?
  "Checked" : "", "Should do Tower retries"
)
shouldDoHeartphialsCheck := AppGUI.AddCheckbox(
  (INPUT_SETTINGS.specific.HasOwnProp("shouldHeartphial") ? INPUT_SETTINGS.specific.shouldHeartphial : 1) ?
  "Checked" : "", "Should do Heartphial skips"
)
AppGUI.AddText(,"Should splurge QP on materials:")
shouldDoMaterialsDDL := AppGUI.AddDropDownList(
  Format("yp+0 Choose{1}", (INPUT_SETTINGS.specific.HasOwnProp("shouldMaterial") ? INPUT_SETTINGS.specific.shouldMaterial : -1) + 3),
  ["None", "Random", "Growth", "Flame", "Aqua", "Forest", "Light", "Dark", "Void"]
)
shouldDoEventCheck := AppGUI.AddCheckbox(
  Format("xm+0{1}",
    (INPUT_SETTINGS.specific.hasOwnProp("shouldEvent") ? INPUT_SETTINGS.specific.shouldEvent : 1) ?
    " Checked" : ""
  ), "Should do ongoing events"
)
shouldDoArchiveEventCheck := AppGUI.AddCheckbox(
  Format("xm+25{1}{2}",
  (INPUT_SETTINGS.specific.HasOwnProp('shouldArchiveEvent') ? INPUT_SETTINGS.specific.shouldArchiveEvent : 1) ?
    " Checked" : "", shouldDoEventCheck.Value ? "" : " Disabled"
  ), "Should do archive event `"Memories of You II`""
)
shouldDoEventCheck.OnEvent("Click", (*) {
  shouldDoArchiveEventCheck.Enabled := shouldDoEventCheck.Value
})
shouldDoRaidCheck := AppGUI.AddCheckbox(
  Format("xm+0{1}",
    (INPUT_SETTINGS.specific.hasOwnProp("shouldRaid") ? INPUT_SETTINGS.specific.shouldRaid : 1) ?
    " Checked" : ""
  ), "Should try to do Link raid (assumes proper setup is already in place)"
)

shouldCloseCheck := AppGUI.AddCheckbox(
  (INPUT_SETTINGS.specific.hasOwnProp("shouldClose") ? INPUT_SETTINGS.specific.shouldClose : 0) ?
    "Checked" : "", "Should close the game after finishing"
)
shouldLogCheck := AppGUI.AddCheckbox(
  (INPUT_SETTINGS.specific.hasOwnProp("shouldLog") ? INPUT_SETTINGS.specific.shouldLog : 1) ?
    "Checked" : "", "Log actions"
)
startButton := AppGUI.AddButton("Default w80", "Start")
exitButton := AppGUI.AddButton("yp+0 w80", "Exit")
AppGUI.AddText("yp+0", "(use Ctrl + C to exit)")
exitButton.OnEvent("Click", (*) {
  exit()
})

versionInfoText := AppGUI.AddLink("xm+0",'Made for Puella Magi Madoka Magica: Magia Exedra v2.12.1 (Global <a href="https://store.steampowered.com/app/2987800/">Steam version</a>) (<a href="https://github.com/dgltorress/gacha-macros">Git</a>)')
versionInfoText.SetFont("s8")

status := AppGUI.AddStatusBar("w400")
status.SetIcon("imageres.dll", 77)

if (isDark) {
  AppGUI.BackColor := 0x222222
  windowNameControl.SetFont("CBlack")
}

logAction(action, level := 0) {
  if (shouldLogCheck.Value) {
    switch level {
      case 1: action := Format("ERROR: {1}", action)
      case 2: action := Format("WARN: {1}", action)
    }
    log(&action)
  }
  status.SetText(action)
}

updateSettings() {
  INPUT_SETTINGS.window.target := APP_TARGET
  sSettings := INPUT_SETTINGS.specific
  sSettings.shouldMagiaBox := shouldClaimMagiaBoxCheck.Value
  sSettings.shouldPvp := shouldDoPvPCheck.Value
  sSettings.shouldTower := shouldDoTowerCheck.Value
  sSettings.shouldHeartphial := shouldDoHeartphialsCheck.Value
  sSettings.shouldMaterial := shouldDoMaterialsDDL.Value - 3
  sSettings.shouldEvent := shouldDoEventCheck.Value
  sSettings.shouldArchiveEvent := shouldDoArchiveEventCheck.Value
  sSettings.shouldRaid := shouldDoRaidCheck.Value
  sSettings.shouldClose := shouldCloseCheck.Value
  sSettings.shouldLog := shouldLogCheck.Value
  writeSettings(INPUT_SETTINGS, SETTINGS_PATH)
}

; add the following to the file importing this GUI:

;startButton.OnEvent("Click", (*) {
;  updateSettings()
;  main()
;})
;AppGUI.Show()
