#Requires AutoHotkey >=2.0-a

#Include "%A_ScriptDir%/../config.ahk"

; Settings

A_ScriptName := "Madoka Exedra Automator"

SETTINGS_PATH := Format("{1}\config.ini", A_ScriptDir)
INPUT_SETTINGS := readSettings(SETTINGS_PATH)


; Window

APP_TARGET := INPUT_SETTINGS.window.target ? INPUT_SETTINGS.window.target : "MadokaExedra"
APP_TARGET_SEARCH_MODE := INPUT_SETTINGS.window.mode
COLOR_TOLERANCE := INPUT_SETTINGS.window.tolerance


; Time

T_TIMEOUT := INPUT_SETTINGS.time.timeout
T_POLL := INPUT_SETTINGS.time.poll
T_POLL_VARIANCE := INPUT_SETTINGS.time.pollVariance
T_TIMEOUT_INTRO := INPUT_SETTINGS.time.timeoutIntro
T_TIMEOUT_RAID := INPUT_SETTINGS.time.timeoutRaid
T_TIMEOUT_BACKOFF := INPUT_SETTINGS.time.timeoutBackoff
