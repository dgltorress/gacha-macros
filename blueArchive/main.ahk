#Requires AutoHotkey >=2.1-alpha.3

#Include "%A_ScriptDir%/config.ahk"
#Include "%A_ScriptDir%/utils.ahk"
#Include "%A_ScriptDir%/steps.ahk"
#Include "%A_ScriptDir%/gui.ahk"

; app-specific
hasRemainingPvp := false
claimedPvpTimeRewardOnce := false

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

goBackToCampaign() {
  goBackTo(steps.other.backToCampaign, detect.main.isCampaign, "campaign screen")
}

; open campaign screen
accessCampaignMenu() {
  logAction("Accessing campaign screen...")
  if (steps.other.accessCampaignMenu.perform(T_TIMEOUT_BACKOFF, T_POLL, T_POLL_VARIANCE)) {
    logAction("Accessed campaign screen")
    return true
  } else {
    logAction("Failed to access campaign screen", 2)
    return false
  }
}

doPvp(untilNone := false) {
  if (hasRemainingPvp) {
    ; access from main menu
    logAction("Detected remaining PvP skips. Accessing campaign screen...")
    if (accessCampaignMenu()) {
      logAction("Accessed campaign screen")
      if (detect.pvp.hasPendingActionsOutside.Call()) {
        logAction("Confirmed remaining PvP skips. Accessing PvP screen...")
        if (steps.pvp.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Accessed PvP screen")
          ; claim rewards
          if (!claimedPvpTimeRewardOnce) {
            if (detect.pvp.canClaimTimeReward.Call()) {
              logAction("Detected claimable Time reward. Claiming...")
              if (steps.pvp.claimTimeReward.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                logAction("Successfully claimed Time reward")
                global claimedPvpTimeRewardOnce := true
              } else {
                logAction("Failed to claim Time reward", 2)
              }
            } else {
              logAction("No Time reward to be claimed")
            }
          }
          if (detect.pvp.canClaimDailyReward.Call()) {
            logAction("Detected claimable Daily reward. Claiming...")
            if (steps.pvp.claimDailyReward.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Successfully claimed Daily reward")
            } else {
              logAction("Failed to claim Daily reward", 2)
            }
          } else {
            logAction("No Daily reward to be claimed")
          }
          ; do PvP battles
          while (hasRemainingPvp) {
            if (detect.pvp.hasTicketsLeft.Call()) {
              opponentIndex := (shouldDoPvPDDL.Value > 2) ? shouldDoPvPDDL.Value - 3 : Random(2)
              logAction(Format("Confirmed remaining PvP skips. Selecting {1} ({2}) opponent...", shouldDoPvPDDL.Text, opponentIndex))
              if (steps.pvp.selectOpponent.performWithParams(T_TIMEOUT_RAID, T_POLL, T_POLL_VARIANCE, opponentIndex)) {
                logAction(Format("Selected {1} opponent. Opening formation screen...", shouldDoPvPDDL.Text))
                if (steps.pvp.confirmOpponent.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                  logAction("Opened formation screen. Mobilizing...")
                  if (steps.pvp.attackOpponent.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                    logAction("Successfully skipped PvP battle")
                    if (detect.pvp.hasTicketsLeft.Call()) {
                      logAction("Detected remaining PvP skips before exit")
                    } else {
                      logAction("No PvP skips remaining at the PvP screen before exit")
                      global hasRemainingPvp := false
                    }
                  } else {
                    logAction("Failed to skip PvP battle", 2)
                    break
                  }
                } else {
                  logAction("Failed to open formation screen", 2)
                  break
                }
              } else {
                logAction(Format("Failed to select {1} opponent", shouldDoPvPDDL.Text), 2)
                break
              }
            } else {
              logAction("No PvP skips remaining at the PvP screen")
              global hasRemainingPvp := false
            }
            if (!hasRemainingPvp || !untilNone) {
              break
            } else {
              logAction("Repeating PvP battles until none are left")
            }
          }
        } else {
          logAction("Failed to access PvP screen", 2)
        }
      } else {
        logAction("No PvP skips remaining at the campaign screen")
        global hasRemainingPvp := false
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to access the campaign screen", 2)
    }
  }
}

doLessons() {
  targetStudentAmount := targetLessonStudentControl.Value
  targetStudentAmountNumeral := (targetStudentAmount != 1) ? "s" : ""
  remainingLocations := maxLessonLocationControl.Value
  targetSublocationLimit := targetSublocationLimitControl.Value
  reverse := shouldReverseLocationsCheck.Value
  if ((targetStudentAmount > 0) && (remainingLocations > 0) ){ ;&& detect.lessons.hasPendingActionsOutside.Call()) {
    ; access locations
    logAction(Format(
      "Detected available lessons. Teaching lessons in sublocations with (preferably) at least {1} student{2} throughout {3} main location{4}{5}",
      targetStudentAmount, targetStudentAmountNumeral, remainingLocations, (remainingLocations != 1) ? "s" : "",
      (targetSublocationLimit > 1) ? Format(", never going below sublocation ordered {1}", targetSublocationLimit) : ""
    ))
    if (steps.lessons.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed the lessons screen")
      hasRemainingLessons := true
      if (hasRemainingLessons) {
        ; access first main location
        logAction("Detected remaining lessons. Entering Schale Office...")
        if (steps.lessons.accessSchaleOffice.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Accessed Schale Office")
          ; iterate through main locations
          while (hasRemainingLessons) {
            logAction("Accessing all sublocations...")
            ; access "All Locations"
            if (steps.lessons.accessSublocations.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Accessed all sublocations")
              hasAvailableSublocations := true
              sublocationIndex := coords.lessons.sublocationAmount
              ; iterate through sublocations
              while (hasAvailableSublocations) {
                logAction("Scrolling to bottom...")
                steps.lessons.scrollSublocations.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)
                logAction(Format(
                  "Finding sublocation{1} from item ordered {2} with at least {3} student{4}...",
                  (targetSublocationLimit > 1) ? Format(" above or equal to {1}", targetSublocationLimit) : "",
                  sublocationIndex, targetStudentAmount, targetStudentAmountNumeral
                ))
                hasAvailableSublocations := detect.lessons.findAvailableFromBelow.Call(&sublocationIndex, targetStudentAmount, targetSublocationLimit)
                if (hasAvailableSublocations) {
                  logAction(Format("Detected {1} student{2} at sublocation {3}. Selecting...", targetStudentAmount, targetStudentAmountNumeral, sublocationIndex))
                  if (steps.lessons.selectSublocation.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                    logAction(Format("Accessed sublocation {1}. Commencing lesson...", sublocationIndex))
                    if (steps.lessons.confirmSublocation.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                      if (detect.lessons.isNoTicketsPopup.Call()) {
                        logAction("No more lessons available")
                        hasAvailableSublocations := false
                        hasRemainingLessons := false
                      } else {
                        logAction("Lesson completed succesfully")
                      }
                    } else {
                      logAction("Failed to teach lesson", 2)
                    }
                  } else {
                    logAction(Format("Failed to access sublocation {1}", sublocationIndex), 2)
                    hasAvailableSublocations := false
                    hasRemainingLessons := false
                  }
                } else {
                  logAction(Format("No more sublocations with at least {1} student{2} at this location", targetStudentAmount, targetStudentAmountNumeral))
                }
              }
              if (steps.lessons.returnToLocation.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                logAction("Backed out to the main location")
              } else {
                logAction("Failed to back out to the main location", 2)
                hasRemainingLessons := false
              }
            } else {
              logAction("Failed to access all sublocations", 2)
              break
            }
            if (hasRemainingLessons) {
              if (remainingLocations > 0) {
                --remainingLocations
              } else if (targetStudentAmount > 1) {
                remainingLocations := maxLessonLocationControl.Value
                --targetStudentAmount
                targetStudentAmountNumeral := (targetStudentAmount != 1) ? "s" : ""
              } else {
                logAction("No remaining locations or students")
                hasRemainingLessons := false
              }
              if (hasRemainingLessons) {
                logAction("Changing location...")
                if (steps.lessons.changeLocation.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, reverse)) {
                  logAction(
                    Format("Changed to {1} location to target at least {2} student{3} (remaining: {4})",
                    reverse ? "previous" : "following", targetStudentAmount, targetStudentAmountNumeral, remainingLocations
                  ))
                } else {
                  logAction("Failed to change location", 2)
                  hasRemainingLessons := false
                }
              }
            } else {
              logAction("No remaining lessons detected")
            }
          }
        } else {
          logAction("Failed to access Schale Office", 2)
        }
      } else {
        logAction("No remaining lessons detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to access the lessons screen", 2)
    }
  }
}

doCafeInvite(studentIndex) {
  if (studentIndex > 0) {
    logAction("Opening invite list...")
    if (steps.cafe.openInvite.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      if (detect.cafe.isInvite.Call()) {
        logAction(Format("Opened invite list. Inviting {1} th student...", studentIndex))
        if (steps.cafe.sendInvite.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, studentIndex - 1)) {
          logAction("Successfully invited student")
        } else {
          logAction("Failed to invite student", 2)
        }
      } else {
        logAction("Failed to open invite list, may have run out of invites. Closing pop ups...", 2)
        if (steps.cafe.exitPopup.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Closed pop ups")
        } else {
          logAction("Failed to close pop ups", 2)
        }
      }
    } else {
      logAction("Failed to open invite list", 2)
    }
  }
}

doCafePatSweep(shouldZoomout := false) {
  if (shouldPatCheck.Value) {
    patCount := 0
    if (shouldZoomout) {
      logAction("Zooming out Cafe...")
      steps.cafe.zoomOut.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)
    }
    logAction("Searching for pattable students...")
    while (detect.cafe.findPattable.Call()) {
      logAction("Found a pattable student. Patting...")
      if (steps.cafe.pat.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
        ++patCount
        logAction("Successfully patted student")
      } else {
        logAction("Failed to pat student", 2)
      }
    }
    logAction(Format("Patted a total of {1} student{2}", patCount, (patCount != 1) ? "s" : ""))
  }
}

doCafe() {
  if (shouldDoCafeCheck.Value) {
    if (detect.cafe.hasPendingActionsOutside.Call()) {
      logAction("Detected pending Cafe actions. Acessing...")
      if (steps.cafe.access.perform(T_TIMEOUT_INTRO, T_POLL, T_POLL_VARIANCE)) {
        ; claim earnings
        logAction("Accessed Cafe. Opening earnings...")
        if (steps.cafe.openEarnings.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Opened earnings. Claiming...")
          if (steps.cafe.claimEarnings.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
            logAction("Successfully claimed Cafe earnings")
          } else {
            logAction("Failed to claim Cafe earnings", 2)
          }
        } else {
          logAction("Failed to open earnings", 2)
        }
        ; invite
        doCafeInvite(targetStudentCafe1Control.Value)
        ; pat
        doCafePatSweep(true)
        ; cafe 2
        if (detect.cafe.hasPendingActionsCafe2.Call()) {
          logAction("Detected pending actions at Cafe 2. Accessing...")
          if (steps.cafe.accessCafe2.perform(T_TIMEOUT_INTRO, T_POLL, T_POLL_VARIANCE)) {
            logAction("Accessed Cafe 2")
            ; invite
            doCafeInvite(targetStudentCafe2Control.Value)
            ; pat
            doCafePatSweep()
          } else {
            logAction("Failed to access Cafe 2", 2)
          }
        } else {
          logAction("No pending actions detected at Cafe 2")
        }
        goBackToMainMenu()
      } else {
        logAction("Failed to access Cafe", 2)
      }
    } else {
      logAction("No pending Cafe actions detected")
    }
  }
}

doSocial() {
  if (detect.social.hasPendingActionsOutside.Call()) {
    logAction("Detected pending social actions. Opening pop up...")
    if (steps.social.openPopup.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Opened social pop up")
      if (detect.social.hasPendingClubAccess.Call()) {
        logAction("Detected pending club access reward. Accessing...")
        if (steps.social.accessClub.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Successfully accessed club")
        } else {
          logAction("Failed to access club", 2)
        }
      } else {
        logAction("No club access reward detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to open social pop up", 2)
    }
  } else {
    logAction("No pending social actions detected")
  }
}

doBounties() {
  if (shouldDoBountiesDDL.Value > 1) {
    if (accessCampaignMenu()) {
      logAction("Accessed campaign screen")
      if (detect.bounties.hasPendingActionsOutside.Call()) {
        logAction("Detected pending bounty actions. Accessing...")
        if (steps.bounties.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          locationIndex := (shouldDoBountiesDDL.Value > 2) ? shouldDoBountiesDDL.Value - 3 : Random(2)
          logAction(Format("Opened bounties. Accessing {1} ({2}) location", shouldDoBountiesDDL.Text, locationIndex))
          if (steps.bounties.accessLocation.performWithParams(T_TIMEOUT, T_POLL, T_POLL_VARIANCE, locationIndex)) {
            logAction(Format("Accessed {1} location. Searching for last skippable stage...", shouldDoBountiesDDL.Text))
            result := detect.bounties.findSkippableStage.Call()
            ; scroll and try once more
            if (!result) {
              logAction("No skippable stage found. Scrolling up and retrying...")
              result := steps.bounties.scrollStages.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)
            }
            if (result) {
              logAction("Found skippable stage. Opening...")
              if (steps.bounties.accessStage.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                logAction("Opened last skippable stage. Setting max sweeps...")
                if (steps.bounties.setMaxSweeps.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                  logAction("Set max sweeps. Opening sweep confirmation...")
                  if (steps.bounties.openSweep.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                    logAction("Opened sweep confirmation. Sweeping...")
                    if (steps.bounties.confirmSweep.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                      logAction("Succesfully swept the stage")
                    } else {
                      logAction("Failed to sweep the stage", 2)
                    }
                  } else {
                    logAction("Failed to open sweep confirmation", 2)
                  }
                } else {
                  logAction("Failed to set max sweeps", 2)
                }
              } else {
                logAction("Failed to open last skippable stage", 2)
              }
            } else {
              logAction("No skippable stage found")
            }
          } else {
            logAction(Format("Failed to access {1} location", shouldDoBountiesDDL.Text), 2)
          }
        } else {
          logAction("Failed to open bounties", 2)
        }
      } else {
        logAction("No pending bounty actions detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to access campaign screen", 2)
    }
  }
}

doTasks() {
  if (detect.tasks.hasPendingActionsOutside.Call()) {
    logAction("Detected unclaimed task rewards. Accessing...")
    if (steps.tasks.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed tasks")
      ; Generic
      if (detect.tasks.canClaimAll.Call()) {
        logAction("Detected unclaimed generic rewards. Claiming...")
        if (steps.tasks.claimAll.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Successfully claimed generic rewards")
        } else {
          logAction("Failed to claim generic rewards", 2)
        }
      } else {
        logAction("No unclaimed generic rewards detected")
      }
      ; Daily milestone
      if (detect.tasks.canClaimDailyPyroxenes.Call()) {
        logAction("Detected unclaimed daily pyroxenes. Claiming...")
        if (steps.tasks.claimDailyPyroxenes.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Successfully claimed daily pyroxenes")
        } else {
          logAction("Failed to claim daily pyroxenes", 2)
        }
      } else {
        logAction("No unclaimed daily pyroxenes detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to access tasks", 2)
    }
  } else {
    logAction("No unclaimed task rewards detected")
  }
}

doDailyFreePack() {
  if (detect.dailyPack.hasPendingActionsOutside.Call()) {
    logAction("Detected pending pyroxene store actions. Opening pop up...")
    if (steps.dailyPack.openPopup.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Opened pyroxene store pop up")
      if (detect.dailyPack.hasPendingPackTab.Call()) {
        logAction("Detected pending actions in the Packs tab. Switching...")
        if (steps.dailyPack.switchTabPacks.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Switched to Packs tab")
          if (detect.dailyPack.hasPendingFreePack.Call()) {
            logAction("Detected claimable free daily pack. Opening pop up...")
            if (steps.dailyPack.openFreeDailyPack.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Successfully opened free daily pack pop up")
              if (detect.dailyPack.canBuy.Call()) {
                logAction("Daily pack is claimable for free")
                if (steps.dailyPack.claimFreeDailyPack.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                  logAction("Successfully claimed free daily pack")
                } else {
                  logAction("Failed to claim free daily pack", 2)
                }
              } else {
                logAction("Daily pack deemed not claimable for free")
              }
            } else {
              logAction("Failed to open free daily pack pop up", 2)
            }
          } else {
            logAction("No claimable free daily pack detected")
          }
        } else {
          logAction("Failed to switch to Packs tab", 2)
        }
      } else {
        logAction("No pending actions in the Packs tab were detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to open social pop up", 2)
    }
  } else {
    logAction("No pending pyroxene store actions detected")
  }
}

doMailbox() {
  if (detect.mailbox.hasPendingActionsOutside.Call()) {
    logAction("Detected pending mailbox actions. Accessing...")
    if (steps.mailbox.access.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
      logAction("Opened mailbox")
      if (detect.mailbox.canClaimAll.Call()) {
        logAction("Detected unclaimed mailbox messages. Claiming...")
        if (steps.mailbox.claimAll.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction("Successfully claimed mailbox rewards once")
        } else {
          logAction("Failed to claim mailbox rewards", 2)
        }
      } else {
        logAction("No unclaimed mailbox messages detected")
      }
      goBackToMainMenu()
    } else {
      logAction("Failed to open mailbox", 2)
    }
  } else {
    logAction("No pending mailbox actions detected")
  }
}

doEvent() {
  targetSkippableStage := targetEventStageControl.Value
  if (targetSkippableStage > 0) {
    logAction(Format("Waiting {1} ms for first event in the carousel to be hovered...", T_TIMEOUT_INTRO))
    if (steps.event.access.perform(T_TIMEOUT_INTRO, T_POLL, T_POLL_VARIANCE)) {
      logAction("Accessed event")
      if (detect.event.isStoryEvent.Call()) {
        logAction("First event confirmed as a Story event. Switching to Quest tab...")
        if (steps.event.switchTabQuest.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
          logAction(Format("Switched to Quest tab. Opening last {1} skippable stage...", targetSkippableStage))
          skippableStagesFound := 0
          result := true
          while (result && (skippableStagesFound < targetSkippableStage)) {
            result := detect.event.findSkippableStage.Call()
            if (result) {
              ++skippableStagesFound
            }
          }
          ; scroll and try once more
          if (skippableStagesFound < targetSkippableStage) {
            logAction("No skippable stage found. Scrolling up and retrying...")
            result := true
            while (result && (skippableStagesFound < targetSkippableStage)) {
              result := detect.event.findSkippableStage.Call()
              if (result) {
                ++skippableStagesFound
              }
            }
          }
          if (skippableStagesFound == targetSkippableStage) {
            logAction(Format("Found skippable stage {1}. Opening...", skippableStagesFound))
            if (steps.event.accessStage.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
              logAction("Opened last skippable stage. Setting max sweeps...")
              if (steps.event.setMaxSweeps.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                logAction("Set max sweeps. Opening sweep confirmation...")
                if (steps.event.openSweep.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                  logAction("Opened sweep confirmation. Sweeping...")
                  if (steps.event.confirmSweep.perform(T_TIMEOUT, T_POLL, T_POLL_VARIANCE)) {
                    logAction("Succesfully swept the stage")
                  } else {
                    logAction("Failed to sweep the stage", 2)
                  }
                } else {
                  logAction("Failed to open sweep confirmation", 2)
                }
              } else {
                logAction("Failed to set max sweeps", 2)
              }
            } else {
              logAction("Failed to open last skippable stage", 2)
            }
          } else {
            logAction(Format("Only found {1} out of {2} skippable stages", skippableStagesFound, targetSkippableStage))
          }
        } else {
          logAction("Failed to switch to Quest tab", 2)
        }
      } else {
        logAction("First event is not a Story event")
      }
    } else {
      logAction("Failed to access story event", 2)
    }
    goBackToMainMenu()
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
  global hasRemainingPvp := shouldDoPvPDDL.Value > 1
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
  doPvp()
  doLessons()
  doPvp()
  doCafe()
  doPvp()
  doSocial()
  doBounties()
  doTasks()
  doPvp()
  doDailyFreePack()
  doMailbox()
  doEvent()
  doPvp()
  doTasks()
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
