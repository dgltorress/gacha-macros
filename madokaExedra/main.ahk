#Requires AutoHotkey >=2.1-alpha.3

#Include "%A_ScriptDir%/config.ahk"
#Include "%A_ScriptDir%/utils.ahk"
#Include "%A_ScriptDir%/steps.ahk"
#Include "%A_ScriptDir%/gui.ahk"

; window identifiers
SetTitleMatchMode(APP_TARGET_SEARCH_MODE)
windowHandle := 0
windowTitle := ''

; check if the app is currently at a specific menu
checkMenu(detectFunction, name) {
  if (!detectFunction.Call()) {
    msg := Format("Expected to be at {1}", name)
    logAction(msg, 1)
    MsgBox(msg)
    exit()
  } else {
    logAction(Format("Verified the game is currently at {1}", name))
  }
}

; navigates back to a specific menu, fails if not there after the backoff timeout
goBackTo(stepFunction, detectFunction, name) {
  logAction(Format("Backing out to {1}...", name))
  stepFunction.perform(T_TIMEOUT_BACKOFF, T_POLL, T_POLL_VARIANCE)
  checkMenu(detectFunction, name)
}

goBackToMainMenu() {
  goBackTo(steps.other.backToMain, detect.main.isMainMenu, "main menu")
}

goBackToQuests() {
  goBackTo(steps.other.backToQuests, detect.main.isQuests, "quest screen")
}

goBackToEvents() {
  goBackTo(steps.event.backToMenu, detect.event.isMainMenu, "event menu")
}

; open quest menu
accessQuestMenu() {
  logAction("Accessing quest menu...")
  if (steps.other.accessQuestMenu.perform(T_TIMEOUT_BACKOFF, T_POLL, T_POLL_VARIANCE)) {
    logAction("Accessed quest menu")
    return true
  } else {
    logAction("Failed to access quest menu", 2)
    return false
  }
}

; claim daily magia box rewards
claimMagiaBox() {
  logAction("Opening Magia box...")
  if (steps.magiaBox.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
    logAction("Opened Magia box")
    ; free daily collect
    if (detect.magiaBox.hasFreeCollect.Call()) {
      logAction("Detected free daily collect. Opening...")
      if (steps.magiaBox.openFreeCollect.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction("Opened free daily collect. Claiming...")
        if (steps.magiaBox.claimFreeCollect.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Claimed free daily collect")
        } else {
          logAction("Failed to claim existing free daily collect", 2)
        }
      } else {
        logAction("Failed to open existing free daily collect", 2)
      }
    } else {
      logAction("Box has no free collect")
    }
    ; regular claim
    if (detect.magiaBox.canClaim.Call()) {
      logAction("Box has available rewards. Claiming...")
      if (steps.magiaBox.claimRegularCollect.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction("Claimed available box rewards")
      } else {
        logAction("Failed to claim available box rewards", 2)
      }
    } else {
      logAction("Box has no available rewards")
    }
    logAction("Closing Magia box...")
  } else {
    logAction("Failed to open Magia box", 2)
  }
  goBackToMainMenu()
}

; carry out daily PvP matches
doPvp() {
  if (detect.pvp.hasPendingMatchesOutside.Call()) { ; access pvp main menu
    logAction("Pending PvP matches detected. Accessing PvP menu...")
    if (steps.pvp.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed PvP main menu. Checking if there are available matches...")
      while (detect.pvp.hasPendingMatches.Call() && steps.pvp.accessOpponents.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction("Found available match and accessed opponents screen. Selecting from two bottom opponents...")
        if (steps.pvp.selectOpponent.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction(Format("Selected opponent. Starting battle {1}...", A_Index))
          if (steps.pvp.start.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction(Format("Attempting battle {1}. Skipping opening animations...", A_Index))
            if (steps.pvp.skip.perform(T_TIMEOUT_RAID, T_POLL, T_POLL_VARIANCE)) {
              logAction(Format("Finished battle {1}", A_Index))
            } else {
              logAction(Format("Failed to skip battle {1}", A_Index), 2)
              break
            }
          } else {
            logAction("Failed to start battle", 2)
            break
          }
        } else {
          logAction("Failed to select opponent", 2)
          break
        }
      }
      logAction("No more available matches left")
    }
    goBackToMainMenu()
  } else {
    logAction("No PvP matches left")
  }
}

doTower() {
  if (detect.tower.hasPendingMatchesOutside.Call()) { ; access tower main menu
    logAction("Pending Tower retries detected. Accessing Tower menu...")
    if (steps.tower.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed Tower menu. Moving to the last completed level...")
      if (steps.tower.findSkippableLevel.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction("Found a skippable Tower level. Opening skip pop up...")
        if (steps.tower.openSkip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Opened the skip pop up. Setting max skips...")
          if (steps.tower.setSkips.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction("Successfully set up max skips. Skipping...")
            if (steps.tower.skip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Successfully used up Tower retries")
            } else {
              logAction("Failed to skip Tower retries", 2)
            }
          } else {
            logAction("Failed to set max skips", 2)
          }
        } else {
          logAction("Failed to open the skip pop up", 2)
        }
      } else {
        logAction("Failed to find a skippable Tower level", 2)
      }
      goBackToQuests()
    } else {
      logAction("Failed to access Tower", 2)
    }
  } else {
    logAction("No Tower retries left")
  }
}

doHeartphials() {
  if (detect.heartphial.hasPendingMatchesOutside.Call()) {
    logAction("Pending Heartphial skips detected. Accessing Heartphial menu...")
    ; access heartphial main menu
    if (steps.heartphial.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed Heartphial menu. Searching for the last cleared stage...")
      px := unset
      py := unset
      if (steps.heartphial.findClearStage.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, &px, &py)) {
        logAction("Found and accessed a skippable Heartphial stage. Opening skip pop up...")
        if (steps.heartphial.openSkip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Opened the skip pop up. Setting max skips...")
          if (steps.heartphial.setSkips.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction("Successfully set up max skips. Skipping...")
            if (steps.heartphial.skip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Successfully used up Heartphial skips")
            } else {
              logAction("Failed to use Heartphial skips", 2)
            }
          } else {
            logAction("Failed to set max skips", 2)
          }
        } else {
          logAction("Failed to open the skip pop up", 2)
        }
      } else {
        logAction("Failed to find a cleared Heartphial stage", 2)
      }
      goBackToQuests()
    } else {
      logAction("Failed to access Heartphials", 2)
    }
  } else {
    logAction("No Heartphial skips left")
  }
}

doMaterials() {
  ; access material menu directly (notifications are unreliable)
  logAction("Accessing Upgrade menu...")
  if (steps.material.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
    ; select material type randomly
    logAction("Accessed Upgrade menu")
    claimMagic := unset
    if (shouldDoMaterialsDDL.Value > 2) {
      claimMagic := shouldDoMaterialsDDL.Value - 3
    } else {
      claimMagic := Random(6)
    }
    matType := unset
    switch (claimMagic) {
      case 1: matType := "Flame"
      case 2: matType := "Aqua"
      case 3: matType := "Forest"
      case 4: matType := "Light"
      case 5: matType := "Dark"
      case 6: matType := "Void"
      default: matType := "Growth"
    }
    ; open corresponding skip menu
    openedSkipPopup := false
    if (claimMagic > 0) {
      logAction(Format("{1} gems/stones will be claimed. Accessing Magic upgrades menu...", matType))
      if (steps.material.accessStone.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction(Format("Accessed menu for Magic upgrades. Accessing menu for {1} gems/stones...", matType))
        if (steps.material.openStone.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, claimMagic)) {
          logAction(Format("Accessed menu for {1} gems/stones. Opening skip pop up...", matType))
          if (steps.material.openSkip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            openedSkipPopup := true
          } else {
            logAction(Format("Failed to open skip pop up for Growth enhancement materials", matType), 2)
          }
        } else {
          logAction(Format("Failed to open skip pop up for {1} gems/stones", matType), 2)
        }
      } else {
        logAction(Format("Failed to access Magic upgrades menu", matType), 2)
      }
    } else {
      logAction("Growth enhancement materials will be claimed. Accessing corresponding menu...")
      if (steps.material.openGrowth.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction(Format("Accessed menu for Growth enhancement materials. Opening skip pop up...", matType))
        if (steps.material.openSkip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          openedSkipPopup := true
        } else {
          logAction(Format("Failed to open skip pop up for Growth enhancement materials", matType), 2)
        }
      } else {
        logAction(Format("Failed to access menu for Growth enhancement materials", matType), 2)
      }
    }
    ; skip
    if (openedSkipPopup) {
      if (detect.material.canSkip.Call()) {
        logAction(Format("Opened the skip pop up for {1} materials. Setting max skips...", matType))
        if (steps.material.setSkips.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Successfully set up max skips. Skipping...")
          if (steps.material.skip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction(Format("Successfully used up all remaining QP on claiming {1} materials", matType))
          } else {
            logAction(Format("Failed to claim {1} materials", matType), 2)
          }
        } else {
          logAction("Failed to set max skips", 2)
        }
      } else if (detect.material.isMagicalCubeAdd.Call()) {
        logAction("Not enough QP for a single skip, was prompted to use Magical Cubes", 2)
      } else {
        logAction("Could not identify the current stage as skippable", 2)
      }
    }
    goBackToQuests()
  } else {
    logAction("Failed to access Upgrade quests", 2)
  }
}

doStoryEvent() {
  if (detect.event.hasLastStage.Call()) {
    logAction(Format("Event {1} has a last battle stage. Accessing...", A_Index))
    if (steps.event.openLastStage.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction(Format("Accessed last stage for event {1}. Opening skip pop up...", A_Index))
      if (steps.event.openSkip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction(Format("Opened skip pop up for event {1}", A_Index))
        if (detect.event.canSkip.Call()) {
          if (steps.event.setSkips.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction("Successfully set up max skips. Skipping...")
            if (steps.event.skip.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction(Format("Successfully used all skips in the last stage for event {1}", A_Index))
            } else {
              logAction(Format("Failed to use skips on event {1}", A_Index), 2)
            }
          } else {
            logAction("Failed to set max skips", 2)
          }
        } else if (detect.event.isRetryAdd.Call()) {
          logAction("Not a single skip left, was prompted to use Magical Stones", 2)
        } else {
          logAction("Could not identify the current stage as skippable", 2)
        }
      } else {
        logAction(Format("Failed to open skip pop up for event {1}", A_Index), 2)
      }
    } else {
      logAction(Format("Failed to access existing last stage for event {1}", A_Index), 2)
    }
  } else {
    logAction(Format("No last stage detected for event {1}", A_Index))
  }
  goBackToEvents()
}

; last battle of leftmost story events and last battle from the "Memories of You Part II" archive event (applies only if already cleared)
doEvents() {
  if (detect.event.hasPendingMatchesOutside.Call()) {
    logAction("Pending Event actions detected. Accessing Event menu...")
    ; access heartphial main menu
    if (steps.event.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed Event menu. Searching for pending event actions...")
      ; access unclaimed event (may be battle-less)
      pendingMatchX := detect.event.hasPendingMatchesIndex.Call(1)
      while ((pendingMatchX > 0) && steps.event.selectEvent.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, pendingMatchX)) {
        logAction(Format("Selected story event {1}. Accessing...", A_Index))
        if (steps.event.accessEvent.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction(Format("Accessed Story Event {1} menu. Skipping last battle...", A_Index))
          doStoryEvent()
        } else {
          logAction(Format("Failed to access Story Event {1} menu", A_Index), 2)
          break
        }
        pendingMatchX := detect.event.hasPendingMatchesIndex.Call(A_Index + 1)
      }
      logAction("No more pending ongoing events found")
      if (shouldDoArchiveEventCheck.Value) {
        logAction("Attempting to claim `"Memories of You II`" event...")
        if (steps.event.accessEventArchiveMenu.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Accessed Event archive. Opening Event archive selector...")
          if (steps.event.openEventArchiveSelector.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction("Opened Event archive selector. Selecting `"Memories of You II`"...")
            if (steps.event.selectMemoriesOfYouII.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Selected `"Memories of You II`". Accessing...")
              if (steps.event.accessEvent.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                logAction(Format("Accessed event `"Memories of You II`". Skipping last battle...", A_Index))
                doStoryEvent()
              } else {
                logAction(Format("Failed to access event `"Memories of You II`" menu", A_Index), 2)
              }
            } else {
              logAction("Failed to select `"Memories of You II`"", 2)
            }
          } else {
            logAction("Failed to open Event archive selector", 2)
          }
        } else {
          logAction("Failed to access Event archive", 2)
        }
      }
      goBackToQuests()
    } else {
      logAction("Failed to access Event menu", 2)
    }
  } else {
    logAction("No event actions left")
  }
}

doRaid() {
  if (steps.raid.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
    logAction("Accessed Link raid menu")
    ; Daily roll
    while (detect.raid.hasDailyBonusMainMenu.Call()) {
      logAction(Format("Detected remaining daily bonus from player-triggered battles. Accessing boss menu for battle {1}...", A_Index))
      if (steps.raid.accessBoss.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction(Format("Accessed Boss menu for Link raid battle {1}. Opening pop up...", A_Index))
        if (steps.raid.openBossPopup.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction(Format("Opened Boss pop up for Link raid battle {1}. Starting...", A_Index))
          if (steps.raid.play.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction(Format("Triggered Link raid battle {1}. Waiting for completion...", A_Index))
            if (steps.raid.results.perform(T_TIMEOUT_RAID, T_POLL, T_POLL_VARIANCE)) {
              logAction(Format("Successfully completed Link raid battle {1}", A_Index))
            } else {
              logAction(Format("Failed to trigger battle {1} or reach the main menu for Link raid after it", A_Index), 2)
              break
            }
          } else {
            logAction(Format("Failed to trigger battle {1} or reach the main menu for Link raid after it", A_Index), 2)
            break
          }
        } else {
          logAction(Format("Failed to open Boss pop up for Link raid battle {1}", A_Index), 2)
          break
        }
      } else {
        logAction(Format("Failed to access Boss menu for Link raid battle {1}", A_Index), 2)
        break
      }
    }
    logAction("No more remaining daily bonuses from player-triggered battles found")
    ; Claim ended battles
    if (detect.raid.hasEndedBattleOutside.Call()) {
      logAction("Found unclaimed ended battles. Accessing Backup Requests...")
      if (steps.raid.accessBackupRequests.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction("Accessed Backup Requests. Switching tab to Ended Battles...")
        if (steps.raid.switchTabJoinedBattles.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Switched tab to Ended Battles. Claiming ended battles...")
          if (steps.raid.claimEndedBattles.perform(T_TIMEOUT_RAID, T_POLL, T_POLL_VARIANCE)) {
            logAction("Successfully claimed rewards from ended battles")
          } else {
            logAction("Failed to claim rewards from ended battles", 2)
          }
        } else {
          logAction("Failed switch tab to Ended Battles", 2)
        }
      } else {
        logAction("Failed to access Backup Requests", 2)
      }
    } else {
      logAction("No unclaimed ended battles found")
    }
    goBackToMainMenu()
  } else {
    logAction("Failed to access Link raid menu", 2)
  }
}

claimMonthlies() {
  if (steps.mission.accessMonthly.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
    logAction("Accessed Monthly menu")
    if (steps.mission.claim.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Successfully claimed Monthlies")
    } else {
      logAction("Failed to claim Monthlies", 2)
    }
  } else {
    logAction("Failed to access Monthly menu", 2)
  }
}

claimMissions() {
  if (detect.mission.hasUnclaimedOutside.Call()) {
    logAction("Unclaimed Missions detected. Accessing Mission menu...")
    if (steps.mission.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed Mission menu")
      ; by section
      startY := normalizeY(255)
      pendingClaimY := startY
      ; first section is opened automatically
      while ((pendingClaimY != -1) && ((pendingClaimY == startY) || steps.mission.accessSection.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, pendingClaimY))) {
        logAction(Format("Selected section {1}. Claiming...", A_Index))
        if (steps.mission.claim.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction(Format("Successfully claimed Missions from section {1}", A_Index))
        } else {
          logAction(Format("Failed to claim Missions from section {1}", A_Index), 2)
        }
        pendingClaimY := detect.mission.hasPendingSectionStartingHeight.Call(pendingClaimY)
      }
      logAction("All regular Missions claimed")
      ; monthly
      if (detect.mission.hasUnclaimedMonthly.Call()) {
        logAction("Monthlies detected. Accessing monthly Mission menu...")
        claimMonthlies()
      } else {
        logAction("No unclaimed monthlies detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to access Mission menu", 2)
    }
  } else {
    logAction("No unclaimed Missions detected")
  }
}

claimGifts() {
  if (detect.gift.hasUnclaimedOutside.Call()) {
    logAction("Unclaimed Giftbox items detected. Accessing Giftbox...")
    if (steps.gift.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed Giftbox. Claiming items...")
      if (steps.gift.claim.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        logAction("Successfully claimed Giftbox items")
      } else {
        logAction("Failed to claim Giftbox items", 2)
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to access Giftbox", 2)
    }
  } else {
    logAction("No unclaimed Giftbox items detected")
  }
}

close() {
  if (WinExist(windowTitle)) {
    goBackToMainMenu()
    logAction("Preparing to close the game. Opening close pop up...")
    if (steps.other.openClosePopup.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Closing the game...")
      if (steps.other.close.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        WinWaitClose(windowTitle)
        logAction("Successfully closed the game")
      } else {
        logAction("Failed to close the game", 2)
      }
    } else {
      logAction("Failed to open the closing pop up", 2)
    }
  } else {
    logAction("The game is already closed")
  }
}

setup() {
  if (shouldLogCheck.Value) {
    openLog()
  }
  logAction(Format("Started script '{1}' (Abort with Ctrl + C)", A_ScriptName))
  if (WinExist(windowTitle)) {
    WinActivate(windowTitle)
    WinWaitActive(windowTitle)
    logAction(Format("Focused window '{1}'", APP_TARGET))
  } else {
    MsgBox(Format("Game window {1} was closed before the script could start", APP_TARGET))
    exit()
  }
  if (!detect.main.isMainMenu.Call()) {
    logAction(Format("Not on main screen. Closing possible intro popups for {1} ms...", T_TIMEOUT_INTRO))
    steps.other.skipIntros.perform(T_TIMEOUT_INTRO, T_POLL, T_POLL_VARIANCE)
    checkMenu(detect.main.isMainMenu, "main menu")
  }
}

main() {
  setup()
  if (shouldClaimMagiaBoxCheck.Value) {
    claimMagiaBox()
  }
  if (shouldDoPvPCheck.Value) {
    doPvp()
  }
  if (accessQuestMenu()) {
    if (shouldDoTowerCheck.Value) {
      doTower()
    }
    if (shouldDoHeartphialsCheck.Value) {
      doHeartphials()
    }
    if (shouldDoMaterialsDDL.Value >= 2) {
      doMaterials()
    }
    if (shouldDoEventCheck.Value) {
      doEvents()
    }
    if (shouldDoRaidCheck.Value) {
      doRaid()
    } else {
      goBackToMainMenu() ; raid leads back to main menu directly, must go last
    }
  } else {
    logAction("Unable to access quest menu", 2)
  }
  claimMissions()
  claimGifts()
  logAction("Done!")
  if (shouldCloseCheck.Value) {
    close()
  }
  closeLog()
}

attemptExit() {
  if (MsgBox("Interrupt the script?", A_ScriptName, 1) == "OK") {
    exit()
  }
}

^c:: attemptExit()


detectWindow(*) {
  global APP_TARGET := windowNameControl.Value
  global windowHandle := WinExist(APP_TARGET)
  startButton.Enabled := windowHandle
  outImageType := 1
  if (windowHandle > 0) {
    global windowTitle := Format("ahk_id {1}", windowHandle)
    status.SetText(Format("Found `"{1}`" window (HWND {2})", APP_TARGET, windowHandle))
    iconHandle := ''
    getIconHandle(&iconHandle, windowHandle, true, 24)
    windowPicture.Value := Format("HICON:{1}", iconHandle ? iconHandle : LoadPicture("urlmon.dll", "Icon1", &outImageType))
  } else {
    windowTitle := ''
    status.SetText(Format("Could not find `"{1}`" window", APP_TARGET))
    windowPicture.Value := Format("HICON:{1}", LoadPicture("shell32.dll", "Icon132", &outImageType))
  }
}
windowDetectButton.OnEvent("Click", detectWindow)
detectWindow()

startButton.OnEvent("Click", (*) {
  updateSettings()
  main()
})
AppGUI.Show()
