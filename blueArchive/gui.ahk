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

; pvp
AppGUI.AddText("xm+0","Should target PvP opponent:")
shouldDoPvPDDL := AppGUI.AddDropDownList(
  Format("yp+0 Choose{1}", (INPUT_SETTINGS.specific.HasOwnProp("shouldDoPvP") ? INPUT_SETTINGS.specific.shouldDoPvP : -1) + 3),
  ["None", "Random", "Strong", "Normal", "Weak"]
)

; lesson
AppGUI.AddText("xm+0", "For lessons, ideally target at least ")
targetLessonStudentControl := AppGUI.AddEdit("yp+0 r1 w50")
AppGUI.AddUpDown(
  "Range0-3", INPUT_SETTINGS.specific.hasOwnProp("targetLessonStudentAmount") ? INPUT_SETTINGS.specific.targetLessonStudentAmount : 2
)
AppGUI.AddText("yp+0", " students across ")
maxLessonLocationControl := AppGUI.AddEdit("yp+0 r1 w50")
AppGUI.AddUpDown(
  "Range0-11", INPUT_SETTINGS.specific.hasOwnProp("maxLessonLocationAmount") ? INPUT_SETTINGS.specific.maxLessonLocationAmount : 11
)
AppGUI.AddText("yp+0", " available locations")

shouldReverseLocationsCheck := AppGUI.AddCheckbox(
  Format("xm+25{1}",
  (INPUT_SETTINGS.specific.HasOwnProp('shouldReverseLocations') ? INPUT_SETTINGS.specific.shouldReverseLocations : 0) ?
    " Checked" : ""
  ), "Should visit available locations in reverse order"
)

AppGUI.AddText("xm+25", "Do not spend tickets in sublocations ordered lower than ")
targetSublocationLimitControl := AppGUI.AddEdit("yp+0 r1 w50")
AppGUI.AddUpDown(
  "Range1-9", INPUT_SETTINGS.specific.hasOwnProp("targetSublocationLimit") ? INPUT_SETTINGS.specific.targetSublocationLimit : 1
)
AppGUI.AddText("yp+0", " (left-right, top-down)")

; cafe
shouldDoCafeCheck := AppGUI.AddCheckbox(
  Format("xm+0{1}",
    (INPUT_SETTINGS.specific.hasOwnProp("shouldDoCafe") ? INPUT_SETTINGS.specific.shouldDoCafe : 1) ?
    " Checked" : ""
  ), "Should claim cafe earnings"
)

AppGUI.AddText("xm+25","Should invite students ordered ")
targetStudentCafe1Control := AppGUI.AddEdit("yp+0 r1 w50")
AppGUI.AddUpDown(
  "Range0-6", INPUT_SETTINGS.specific.hasOwnProp("targetStudentCafe1") ? INPUT_SETTINGS.specific.targetStudentCafe1 : 0
)
AppGUI.AddText("yp+0"," and ")
targetStudentCafe2Control := AppGUI.AddEdit("yp+0 r1 w50")
AppGUI.AddUpDown(
  "Range0-6", INPUT_SETTINGS.specific.hasOwnProp("targetStudentCafe2") ? INPUT_SETTINGS.specific.targetStudentCafe2 : 0
)
AppGUI.AddText("yp+0"," to each cafe (from the top)")

shouldPatCheck := AppGUI.AddCheckbox(
  Format("xm+25{1}{2}",
  (INPUT_SETTINGS.specific.HasOwnProp('shouldPat') ? INPUT_SETTINGS.specific.shouldPat : 0) ?
    " Checked" : "", shouldDoCafeCheck.Value ? "" : " Disabled"
  ), "Should try to pat available students (works funky, mind yellow furniture)"
)

shouldDoCafeCheck.OnEvent("Click", (*) {
  enabled := shouldDoCafeCheck.Value
  targetStudentCafe1Control.Enabled := enabled
  targetStudentCafe2Control.Enabled := enabled
  shouldPatCheck.Enabled := enabled
})

; free daily pack
shouldFreeDailyPackCheck := AppGUI.AddCheckbox(
  Format("xm+0{1}",
    (INPUT_SETTINGS.specific.HasOwnProp('shouldFreeDailyPack') ? INPUT_SETTINGS.specific.shouldFreeDailyPack : 1) ? " Checked" : ""
  ), "Should claim free daily pack"
)

; bounties
AppGUI.AddText("xm+0","Should do bounties:")
shouldDoBountiesDDL := AppGUI.AddDropDownList(
  Format("yp+0 Choose{1}", (INPUT_SETTINGS.specific.HasOwnProp("shouldDoBounties") ? INPUT_SETTINGS.specific.shouldDoBounties : -1) + 3),
  ["None", "Random", "Overpass", "Desert Railroad", "Classroom"]
)

; event
AppGUI.AddText("xm+0", "Should splurge AP on ")
targetEventStageControl := AppGUI.AddEdit("yp+0 r1 w50")
AppGUI.AddUpDown(
  "Range0-12", INPUT_SETTINGS.specific.hasOwnProp("targetEventStage") ? INPUT_SETTINGS.specific.targetEventStage : 0
)
AppGUI.AddText("yp+0", "th last 3-starred stage of the current story event (0 for none)")

; close game
shouldCloseCheck := AppGUI.AddCheckbox(Format("xm+0{1}", 
  (INPUT_SETTINGS.specific.hasOwnProp("shouldClose") ? INPUT_SETTINGS.specific.shouldClose : 0) ?
    " Checked" : ""
), "Should close the game after finishing")
shouldLogCheck := AppGUI.AddCheckbox(
  (INPUT_SETTINGS.specific.hasOwnProp("shouldLog") ? INPUT_SETTINGS.specific.shouldLog : 1) ?
    " Checked" : "", "Log actions"
)
startButton := AppGUI.AddButton("Default w80", "Start")
exitButton := AppGUI.AddButton("yp+0 w80", "Exit")
AppGUI.AddText("yp+0", "(use Ctrl + C to exit)")
exitButton.OnEvent("Click", (*) {
  exit()
})

versionInfoText := AppGUI.AddLink("xm+0",'Made for Blue Archive v379434 (Global <a href="https://store.steampowered.com/app/3557620/">Steam version</a>) (<a href="https://github.com/dgltorress/gacha-macros">Git</a>)')
versionInfoText.SetFont("s8")

status := AppGUI.AddStatusBar("w400")
status.SetIcon("imageres.dll", 77)

if (isDark) {
  AppGUI.BackColor := 0x222222
  windowNameControl.SetFont("CBlack")
  targetLessonStudentControl.SetFont("CBlack")
  maxLessonLocationControl.SetFont("CBlack")
  targetSublocationLimitControl.SetFont("CBlack")
  targetStudentCafe1Control.SetFont("CBlack")
  targetStudentCafe2Control.SetFont("CBlack")
  targetEventStageControl.SetFont("CBlack")
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
  sSettings.shouldDoPvP := shouldDoPvPDDL.Value - 3
  sSettings.shouldDoCafe := shouldDoCafeCheck.Value
  sSettings.targetLessonStudentAmount := targetLessonStudentControl.Value
  sSettings.maxLessonLocationAmount := maxLessonLocationControl.Value
  sSettings.shouldReverseLocations := shouldReverseLocationsCheck.Value
  sSettings.targetSublocationLimit := targetSublocationLimitControl.Value
  sSettings.targetStudentCafe1 := targetStudentCafe1Control.Value
  sSettings.targetStudentCafe2 := targetStudentCafe2Control.Value
  sSettings.shouldPat := shouldPatCheck.Value
  sSettings.targetEventStage := targetEventStageControl.Value
  sSettings.shouldFreeDailyPack := shouldFreeDailyPackCheck.Value
  sSettings.shouldDoBounties := shouldDoBountiesDDL.Value - 3
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
