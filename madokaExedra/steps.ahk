#Requires AutoHotkey >=2.1-alpha.3

#Include "%A_ScriptDir%/../step.ahk"
#Include "%A_ScriptDir%/config.ahk"
#Include "%A_ScriptDir%/utils.ahk"

colors := {
  loading: "0x000000",
  criwareLogoBackground: "0xFEFEFE",
  enterBackground: "0xFFF8EB",
  mainQuestsTail: "0xE7D3C3",
  unclaimed: "0xEF654D",
  textFontColor: "0xFFF7EB",
  textFontColorDisabled: "0x9E9B91",
  textFontColorDisabledAlt: "0xBEBAAF",
  goldFontColor: "0xECD09B",
  vsPortrait: "0xC4C4C3",
  mainStar: "0xFCEBC3",
  clearGlowFontColor: "0xFFF7E7",
  eventSelectedGlowColor: "0xFFFFF6",
  magiaBoxTagBackground: "0x373137",
  materialRankStar: "0x8A7A5A",
  battleDot: "0xE7BEAC",
  spentNumber: "0xD37D74"
}

; detection logic identifying successful access to menus should be more restrictive, as colors may load at different speeds

detect := {
  main: {
    isMainMenu: () {
      return isColor(normalizeX(455), normalizeY(50), colors.mainStar, COLOR_TOLERANCE) ; Star between name and level
    },
    isQuests: () {
      return isColor(normalizeX(1828), normalizeY(526), colors.mainQuestsTail, COLOR_TOLERANCE) ; Tail of Mai(n)
    }
  },
  magiaBox: {
    isMainMenu: () {
      return isColor(normalizeX(1120), normalizeY(70), colors.magiaBoxTagBackground, COLOR_TOLERANCE) ; Magia box tag background
    },
    hasFreeCollect: () {
      return isColor(normalizeX(891), normalizeY(863), colors.unclaimed, COLOR_TOLERANCE) ; Free collect notification
    },
    canClaimFreeCollect: () {
      return isColor(normalizeX(1204), normalizeY(901), colors.textFontColor, COLOR_TOLERANCE) ; (O)k in popup
    },
    canClaim: () {
      return isColor(normalizeX(1197), normalizeY(903), colors.textFontColor, COLOR_TOLERANCE) ; Cl(a)im
    },
    cannotClaim: () {
      return isColor(normalizeX(1197), normalizeY(903), colors.textFontColorDisabled, COLOR_TOLERANCE) ; Cl(a)im is grey
    }
  },
  pvp: {
    hasPendingMatchesOutside: () {
      return isColor(normalizeX(504), normalizeY(836), colors.unclaimed, COLOR_TOLERANCE) ; Notification in main menu
    },
    isMainMenu: () {
      return isColor(normalizeX(1242), normalizeY(565), colors.goldFontColor, COLOR_TOLERANCE) ; Top left corner of (P)oints
    },
    hasPendingMatches: () {
      return isColor(normalizeX(1628), normalizeY(915), colors.unclaimed, COLOR_TOLERANCE) ; Notification on Play
    },
    isOpponentsScreen: () {
      return (
        ;isColor(normalizeX(1120), normalizeY(107), colors.textFontColorDisabledAlt, COLOR_TOLERANCE) || ; proceeding while disabled may start scrolling before all opponents have loaded
        isColor(normalizeX(1120), normalizeY(107), colors.textFontColor, COLOR_TOLERANCE)
      ) ; Cross in Update opponen(t)s (appears disabled for a few seconds)
    },
    isBattlePrepScreen: () {
      return isColor(normalizeX(960), normalizeY(144), colors.vsPortrait, COLOR_TOLERANCE) ; Spot on top of VS decoration
    },
    canStartBattle: () {
      return isColor(normalizeX(1129), normalizeY(877), colors.unclaimed, COLOR_TOLERANCE) ; Notification on Play (battle prep screen)
    }
  },
  tower: {
    hasPendingMatchesOutside: () {
      return isColor(normalizeX(565), normalizeY(565), colors.unclaimed, COLOR_TOLERANCE) ; Notification in quest menu
    },
    isMainMenu: () {
      return isColor(normalizeX(1528), normalizeY(47), colors.textFontColor, COLOR_TOLERANCE) ; Re(t)ries
    },
    isUnskippableStage: () {
      return isColor(normalizeX(1395), normalizeY(893), colors.textFontColor, COLOR_TOLERANCE) ; (P)lay in uncompleted level
    },
    isSkippableStage: () {
      return isColor(normalizeX(1341), normalizeY(853), colors.unclaimed, COLOR_TOLERANCE) ; Skip notification
    },
    hasZeroSkipsLeft: () {
      return isColor(normalizeX(1167), normalizeY(603), colors.spentNumber, COLOR_TOLERANCE) ; (0) / 5
    },
    canSkip: () {
      return isColor(normalizeX(1204), normalizeY(815), colors.textFontColor, COLOR_TOLERANCE) ; (O)k in popup
    }
  },
  heartphial: {
    hasPendingMatchesOutside: () {
      return isColor(normalizeX(861), normalizeY(285), colors.unclaimed, COLOR_TOLERANCE) ; Notification in quest menu
    },
    isMainMenu: () {
      return isColor(normalizeX(1454), normalizeY(62), colors.textFontColor, COLOR_TOLERANCE) ; (P)lays
    },
    isStageClear: (&px, &py) {
      x := normalizeX(1107)
      return PixelSearch(&px, &py, x, normalizeY(820), x, normalizeY(290), colors.clearGlowFontColor, COLOR_TOLERANCE) ; Search C(l)ear text in a column from below
    },
    isSkippableStage: () {
      return isColor(normalizeX(674), normalizeY(892), colors.textFontColor, COLOR_TOLERANCE) ; S(k)ip
    },
    hasZeroSkipsLeft: () {
      return isColor(normalizeX(1167), normalizeY(603), colors.spentNumber, COLOR_TOLERANCE) ; (0) / 5
    },
    canSkip: () {
      return isColor(normalizeX(1204), normalizeY(843), colors.textFontColor, COLOR_TOLERANCE) ; (O)k in popup
    }
  },
  material: {
    isMainMenu: () {
      return isColor(normalizeX(348), normalizeY(787), colors.materialRankStar, COLOR_TOLERANCE) ; Star on top of rank (Growth)
    },
    isMagicStoneMenu: () {
      return isColor(normalizeX(494), normalizeY(743), colors.materialRankStar, COLOR_TOLERANCE) ; Star on top of rank (Aqua)
    },
    isSkippable: () {
      return isColor(normalizeX(686), normalizeY(891), colors.textFontColor, COLOR_TOLERANCE) ; S(k)ip
    },
    isMagicalCubeAdd: () {
      return isColor(normalizeX(1235), normalizeY(166), colors.textFontColor, COLOR_TOLERANCE) ; to add (Q)P
    },
    canSkip: () {
      return isColor(normalizeX(1204), normalizeY(815), colors.textFontColor, COLOR_TOLERANCE) ; (O)k in popup
    },
    isMaxSkipsSet: () {
      return (compareColorBrightness(normalizeX(1325), normalizeY(700), "0x2A", "0x28", "0x28") == -1) ; Brightness
    }
  },
  event: {
    hasPendingMatchesOutside: () {
      return isColor(normalizeX(563), normalizeY(111), colors.unclaimed, COLOR_TOLERANCE) ; Notification in quest menu
    },
    hasPendingMatchesArchive: () {
      return isColor(normalizeX(886), normalizeY(32), colors.unclaimed, COLOR_TOLERANCE) ; Notification in quest menu
    },
    hasPendingMatchesIndex: (eventIndex) {
      eventX := 616 + ((eventIndex - 1) * 468)
      eventX := normalizeX(eventX)
      if (eventX >= A_ScreenWidth) {
        return -1
      }
      return isColor(eventX, normalizeY(800), colors.unclaimed, COLOR_TOLERANCE) ? eventX : 0
    },
    hasPendingMatches: (eventX) {
      return isColor(normalizeX(eventX), normalizeY(800), colors.unclaimed, COLOR_TOLERANCE)
    },
    hasStoryEvent: () {
      return isColor(normalizeX(1541), normalizeY(445), colors.textFontColor, COLOR_TOLERANCE) || isColor(normalizeX(1541), normalizeY(555), colors.textFontColor, COLOR_TOLERANCE) ; Stor(y) event
    },
    hasStoryEventArchive: () {
      return isColor(normalizeX(1525), normalizeY(643), colors.textFontColor, COLOR_TOLERANCE) ; Stor(y) event
    },
    hasPendingMatchesArchive: () {
      return isColor(normalizeX(886), normalizeY(32), colors.unclaimed, COLOR_TOLERANCE) ; Notification
    },
    isMainMenu: () {
      return isColor(normalizeX(294), normalizeY(62), colors.goldFontColor, COLOR_TOLERANCE) ; Event (Q)uests
    },
    isStoryEventMenu: () {
      return isColor(normalizeX(215), normalizeY(49), colors.goldFontColor, COLOR_TOLERANCE) ; Sto(r)y event
    },
    isSelected: (eventX) {
      return isColor(normalizeX(eventX), normalizeY(850), colors.eventSelectedGlowColor, COLOR_TOLERANCE) ; Glow
    },
    isArchiveMenu: () {
      return isColor(normalizeX(290), normalizeY(38), colors.goldFontColor, COLOR_TOLERANCE) ; Event (A)rchive
    },
    isArchiveSelector: () {
      return isColor(normalizeX(1219), normalizeY(877), colors.textFontColor, COLOR_TOLERANCE) ; O(K)
    },
    isRetryAdd: () {
      return isColor(normalizeX(829), normalizeY(152), colors.goldFontColor, COLOR_TOLERANCE) ; You can use (M)agical
    },
    hasLastStage: () {
      return isColor(normalizeX(1277), normalizeY(877), colors.battleDot, COLOR_TOLERANCE) ; Dots surrounding the stage
    },
    isSkippable: () {
      return isColor(normalizeX(704), normalizeY(892), colors.textFontColor, COLOR_TOLERANCE) ; S(k)ip
    },
    canSkip: () {
      return isColor(normalizeX(1204), normalizeY(844), colors.textFontColor, COLOR_TOLERANCE) ; O(K) in popup
    },
    hasZeroSkipsLeft: () {
      return isColor(normalizeX(1166), normalizeY(611), colors.spentNumber, COLOR_TOLERANCE) || isColor(normalizeX(1166), normalizeY(566), colors.spentNumber, COLOR_TOLERANCE) ; (0) / 5 with or without bonus panel
    }
  },
  raid: {
    isMainMenu: () {
      return isColor(normalizeX(750), normalizeY(869), colors.textFontColor, COLOR_TOLERANCE) ; Pla(y)
    },
    isBossMenu: () {
      return isColor(normalizeX(1201), normalizeY(462), colors.goldFontColor, COLOR_TOLERANCE) ; Battle con(d)itions
    },
    isBackupRequestsMenu: () {
      return isColor(normalizeX(444), normalizeY(46), colors.goldFontColor, COLOR_TOLERANCE) ; Backup Reques(t)s
    },
    isJoinedBattlesTab: () {
      return isColor(normalizeX(208), normalizeY(319), colors.goldFontColor, COLOR_TOLERANCE) ; Joine(d) Battles
    },
    isPlayable: () {
      return isColor(normalizeX(1325), normalizeY(898), colors.textFontColor, COLOR_TOLERANCE) ; Pla(y)
    },
    hasDailyBonusMainMenu: () {
      return isColor(normalizeX(494), normalizeY(729), colors.goldFontColor, COLOR_TOLERANCE) ; 1, 2, 3 tries left
    },
    hasEndedBattleOutside: () {
      return isColor(normalizeX(1497), normalizeY(779), colors.unclaimed, COLOR_TOLERANCE) ; Joined battles notification
    },
    hasEndedBattle: () {
      return isColor(normalizeX(1654), normalizeY(899), colors.textFontColor, COLOR_TOLERANCE) ; En(d)ed battle font
    }
  },
  mission: {
    isMainMenu: () {
      return isColor(normalizeX(171), normalizeY(42), colors.goldFontColor, COLOR_TOLERANCE) ; (M)issions
    },
    isMonthlyMenu: () {
      return isColor(normalizeX(71), normalizeY(42), colors.goldFontColor, COLOR_TOLERANCE) ; (M)onthly missions
    },
    hasUnclaimedOutside: () {
      return isColor(normalizeX(1636), normalizeY(24), colors.unclaimed, COLOR_TOLERANCE) ; Notification in main menu
    },
    hasUnclaimedMonthly: () {
      return isColor(normalizeX(1738), normalizeY(38), colors.unclaimed, COLOR_TOLERANCE) ; Notification
    },
    hasPendingSectionStartingHeight: (startingHeight) {
      x := normalizeX(339)
      if (startingHeight >= A_ScreenHeight) {
        return -1
      }
      return PixelSearch(&sectionX, &sectionY, x, startingHeight, x, A_ScreenHeight, colors.unclaimed, COLOR_TOLERANCE) ? sectionY : -1
    },
    hasPendingSection: (eventY) {
      return isColor(normalizeX(339), eventY, colors.unclaimed, COLOR_TOLERANCE)
    },
    canClaim: () {
      return isColor(normalizeX(1667), normalizeY(912), colors.textFontColor, COLOR_TOLERANCE) ; (C)laim
    },
    cannotClaim: () {
      return isColor(normalizeX(1667), normalizeY(912), colors.textFontColorDisabled, COLOR_TOLERANCE) ; (C)laim
    }
  },
  gift: {
    isMainMenu: () {
      return isColor(normalizeX(294), normalizeY(55), colors.goldFontColor, COLOR_TOLERANCE) ; Gitfbo(x)
    },
    hasUnclaimedOutside: () {
      return isColor(normalizeX(1749), normalizeY(24), colors.unclaimed, COLOR_TOLERANCE) ; Notification in main menu
    },
    canClaim: () {
      return isColor(normalizeX(1680), normalizeY(925), colors.textFontColor, COLOR_TOLERANCE) ; (C)laim
    },
    cannotClaim: () {
      return isColor(normalizeX(1680), normalizeY(925), colors.textFontColorDisabled, COLOR_TOLERANCE) ; (C)laim
    }
  },
  other: {
    isLoadingBlack: () {
      return isColor(normalizeX(10), normalizeY(10), colors.loading, COLOR_TOLERANCE)
    },
    isClosePopup: () {
      return isColor(normalizeX(1205), normalizeY(854), colors.textFontColor, COLOR_TOLERANCE)
    },
    canPressKey: () {
      return isColor(normalizeX(1781), normalizeY(1032), colors.enterBackground, COLOR_TOLERANCE) ; important to have at least some color tolerance here
    },
    canPressKeyAlt: () {
      return isColor(normalizeX(1740), normalizeY(1032), colors.enterBackground, COLOR_TOLERANCE) ; missions and giftbox
    },
    canTapStart: () {
      return isColor(normalizeX(1846), normalizeY(934), colors.criwareLogoBackground, COLOR_TOLERANCE)
    },
    mustDownloadAssets: () {
      return isColor(normalizeX(1205), normalizeY(854), colors.textFontColor, COLOR_TOLERANCE)
    },
    hasItemsExpiringSoon: () {
      return isColor(normalizeX(971), normalizeY(824), colors.textFontColor, COLOR_TOLERANCE)
    }
  }
}

steps := {
  magiaBox: {
    access: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        accessMagiaBox()
      }, () {
        return { ok: checkDelayed(detect.magiaBox.isMainMenu, T_POLL) }
      }
    ),
    openFreeCollect: Step(
      () {
        return { ok: detect.magiaBox.hasFreeCollect.Call() }
      }, () {
        clickAround(normalizeX(700), normalizeY(880))
      }, () {
        return { ok: detect.magiaBox.canClaimFreeCollect.Call() }
      }
    ),
    claimFreeCollect: Step(
      () {
        return { ok: !detect.magiaBox.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1270), normalizeY(880))
      }, () {
        return { ok: checkDelayed(detect.magiaBox.isMainMenu, T_POLL, true) }
      }
    ),
    claimRegularCollect: Step(
      () {
        return { ok: !detect.magiaBox.cannotClaim.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.magiaBox.cannotClaim.Call() }
      }
    )
  },
  pvp: {
    access: Step(
      () {
        return { ok: detect.pvp.hasPendingMatchesOutside.Call() }
      }, () {
        clickAround(normalizeX(420), normalizeY(860)) ; click PvP button
      }, () {
        return { ok: checkDelayed(detect.pvp.isMainMenu, T_POLL) }
      }
    ),
    accessOpponents: Step(
      () {
        return { ok: detect.pvp.hasPendingMatches.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.pvp.isOpponentsScreen.Call() }
      }
    ),
    selectOpponent: Step(
      () {
        return { ok: detect.pvp.isOpponentsScreen.Call() }
      }, () {
        scrollAround(normalizeX(800), normalizeY(420), "D", 12)
        Sleep(750)
        clickAround(normalizeX(1420), Random(0, 1) ? normalizeY(575) : normalizeY(355)) ; select between two bottom opponents
        Sleep(2500)
      }, () {
        return { ok: detect.pvp.isBattlePrepScreen.Call() }
      }
    ),
    start: Step(
      () {
        return { ok: detect.pvp.canStartBattle.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.pvp.isBattlePrepScreen.Call() }
      }
    ),
    skip: Step(
      () {
        return { ok: !detect.pvp.isMainMenu.Call() }
      }, () {
        skip() ; open skip popup
        Sleep(T_POLL)
        clickAround(normalizeX(1070), normalizeY(830)) ; skip combat start animation
        Sleep(T_POLL)
        clickAround(normalizeX(1070), normalizeY(830))
      }, () {
        return { ok: detect.pvp.isMainMenu.Call() }
      }
    ),
  },
  tower: {
    access: Step(
      () {
        return { ok: detect.tower.hasPendingMatchesOutside.Call() }
      }, () {
        clickAround(normalizeX(200), normalizeY(600))
      }, () {
        return { ok: checkDelayed(detect.tower.isMainMenu, T_POLL) }
      }
    ),
    findSkippableLevel: Step(
      () {
        return { ok: detect.tower.isUnskippableStage.Call() }
      }, () {
        goLeft() ; go to lower level
        Sleep(1500)
      }, () {
        return { ok: detect.tower.isSkippableStage.Call() }
      }
    ),
    openSkip: Step(
      () {
        return { ok: detect.tower.isSkippableStage.Call() }
      }, () {
        clickAround(normalizeX(1180), normalizeY(860))
      }, () {
        return { ok: detect.tower.canSkip.Call() }
      }
    ),
    setSkips: Step(
      () {
        return { ok: detect.tower.canSkip.Call() && !detect.tower.hasZeroSkipsLeft.Call() }
      }, () {
        clickAround(normalizeX(1315), normalizeY(665))
      }, () {
        return { ok: detect.tower.hasZeroSkipsLeft.Call() }
      }
    ),
    skip: Step(
      () {
        return { ok: !detect.tower.isMainMenu.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.tower.isMainMenu.Call() }
      }
    )
  },
  heartphial: {
    access: Step(
      () {
        return { ok: detect.heartphial.hasPendingMatchesOutside.Call() }
      }, () {
        clickAround(normalizeX(750), normalizeY(400))
      }, () {
        return { ok: checkDelayed(detect.heartphial.isMainMenu, T_POLL) }
      }
    ),
    findClearStage: Step(
      (outputCoords) {
        ; if the fourth party member in the popup is a 5-star, the color will overlap with the "Clear" message, needs to check if it's already at the 'skip' pop up
        ok := detect.heartphial.isStageClear.Call(outputCoords.Get(1, 0), outputCoords.Get(2, 0)) && !detect.heartphial.isSkippableStage.Call()
        return { ok: ok, data: { py: outputCoords[2] } }
      }, (data) {
        clickAround(normalizeX(1740), %data.py% + 150) ; enter stage
      }, () {
        return { ok: detect.heartphial.isSkippableStage.Call() }
      }
    ),
    openSkip: Step(
      () {
        return { ok: detect.heartphial.isSkippableStage.Call() }
      }, () {
        clickAround(normalizeX(800), normalizeY(866))
      }, () {
        return { ok: detect.heartphial.canSkip.Call() }
      }
    ),
    setSkips: Step(
      () {
        return { ok: detect.heartphial.canSkip.Call() && !detect.heartphial.hasZeroSkipsLeft.Call() }
      }, () {
        clickAround(normalizeX(1315), normalizeY(665))
      }, () {
        return { ok: detect.heartphial.hasZeroSkipsLeft.Call() }
      }
    ),
    skip: Step(
      () {
        return { ok: !detect.heartphial.isMainMenu.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.heartphial.isMainMenu.Call() }
      }
    )
  },
  material: {
    access: Step(
      () {
        return { ok: detect.main.isQuests.Call() }
      }, () {
        clickAround(normalizeX(1000), normalizeY(200))
      }, () {
        return { ok: checkDelayed(detect.material.isMainMenu, T_POLL) }
      }
    ),
    accessStone: Step(
      () {
        return { ok: detect.material.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(900), normalizeY(400))
      }, () {
        return { ok: detect.material.isMagicStoneMenu.Call() }
      }
    ),
    openGrowth: Step(
      () {
        return { ok: detect.material.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(300), normalizeY(400))
      }, () {
        return { ok: detect.material.isSkippable.Call() }
      }
    ),
    openStone: Step(
      (stoneIndex) {
        return { ok: detect.material.isMagicStoneMenu.Call(), data: stoneIndex.Get(1) }
      }, (stoneIndex) {
        clickAround(normalizeX(189) + (normalizeX(307) * (stoneIndex - 1)), normalizeY(400))
      }, () {
        return { ok: detect.material.isSkippable.Call() }
      }
    ),
    openSkip: Step(
      () {
        return { ok: detect.material.isSkippable.Call() }
      }, () {
        clickAround(normalizeX(770), normalizeY(870))
      }, () {
        return { ok: detect.material.canSkip.Call() || detect.material.isMagicalCubeAdd.Call() }
      }
    ),
    setSkips: Step(
      () {
        return { ok: detect.material.canSkip.Call() && !detect.material.isMaxSkipsSet.Call() }
      }, () {
        clickAround(normalizeX(1330), normalizeY(670))
      }, () {
        return { ok: detect.material.isMaxSkipsSet.Call() }
      }
    ),
    skip: Step(
      () {
        return { ok: !(detect.material.isMainMenu.Call() || detect.material.isMagicStoneMenu.Call()) }
      }, () {
        confirm()
      }, () {
        return { ok: (detect.material.isMainMenu.Call() || detect.material.isMagicStoneMenu.Call()) }
      }
    )
  },
  event: {
    access: Step(
      () {
        return { ok: detect.event.hasPendingMatchesOutside.Call() }
      }, () {
        clickAround(normalizeX(300), normalizeY(200))
      }, () {
        return { ok: checkDelayed(detect.event.isMainMenu, 2000, true) }
      }
    ),
    selectEvent: Step(
      (eventX) {
        eventX := eventX.Get(1)
        return { ok: detect.event.hasPendingMatches.Call(eventX) && !detect.event.isSelected.Call(eventX), data: eventX }
      }, (eventX) {
        clickAround(eventX - 100, normalizeY(820))
      }, () {
        return { ok: detect.event.hasStoryEvent.Call() || detect.event.hasStoryEventArchive.Call() }
      }
    ),
    accessEvent: Step(
      () {
        return { ok: detect.event.hasStoryEvent.Call() || detect.event.hasStoryEventArchive.Call() }
      }, () {
        if (detect.event.hasStoryEventArchive.Call()) {
          clickAround(normalizeX(1240), normalizeY(580))
        } else {
          clickAround(normalizeX(1500), normalizeY(450))
        }
      }, () {
        return { ok: checkDelayed(() {
          return detect.event.isStoryEventMenu.Call() || detect.event.hasLastStage.Call()
        }, T_POLL) }
        ;isStoryEventMenu := (detect.event.isStoryEventMenu.Call() || detect.event.hasLastStage.Call())
        ;if (isStoryEventMenu) {
        ;  Sleep(T_POLL)
        ;}
      }
    ),
    accessEventArchiveMenu: Step(
      () {
        return { ok: detect.event.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(650), normalizeY(40))
      }, () {
        return { ok: checkDelayed(detect.event.isArchiveMenu, T_POLL) }
      }
    ),
    openEventArchiveSelector: Step(
      () {
        return { ok: detect.event.isArchiveMenu.Call() }
      }, () {
        clickAround(normalizeX(80), normalizeY(870))
      }, () {
        return { ok: detect.event.isArchiveSelector.Call() }
      }
    ),
    selectMemoriesOfYouII: Step(
      () {
        return { ok: detect.event.isArchiveSelector.Call() && detect.other.canPressKey.Call() }
      }, () {
        Sleep(T_POLL)
        clickAround(normalizeX(900), normalizeY(650))
        Sleep(T_POLL_VARIANCE)
        clickAround(normalizeX(1300), normalizeY(850))
      }, () {
        return { ok: detect.event.isArchiveMenu.Call() }
      }
    ),
    backToMenu: Step(
      () {
        return { ok: !detect.event.isMainMenu.Call() && detect.other.canPressKey.Call() }
      }, () {
        goBack()
      }, () {
        isMainMenu := detect.event.isMainMenu.Call()
        if (isMainMenu) {
          Sleep(T_POLL)
        }
        return { ok: isMainMenu }
      }
    ),
    openLastStage: Step(
      () {
        return { ok: detect.event.hasLastStage.Call() }
      }, () {
        clickAround(normalizeX(1300), normalizeY(800))
      }, () {
        return { ok: detect.event.isSkippable.Call() || detect.event.isRetryAdd.Call() }
      }
    ),
    openSkip: Step(
      () {
        return { ok: detect.event.isSkippable.Call() }
      }, () {
        clickAround(normalizeX(800), normalizeY(870))
      }, () {
        return { ok: detect.event.canSkip.Call() || detect.event.isRetryAdd.Call() }
      }
    ),
    setSkips: Step(
      () {
        return { ok: detect.event.canSkip.Call() && !detect.event.hasZeroSkipsLeft.Call() }
      }, () {
        clickAround(normalizeX(1330), normalizeY(712))
        Sleep(100)
        clickAround(normalizeX(1330), normalizeY(635)) ; account for possibly absent bonus section
      }, () {
        return { ok: detect.event.hasZeroSkipsLeft.Call() }
      }
    ),
    skip: Step(
      () {
        return { ok: !detect.event.isStoryEventMenu.Call() && !detect.event.isArchiveMenu.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.event.isStoryEventMenu.Call() || detect.event.isArchiveMenu.Call() }
      }
    )
  },
  raid: {
    access: Step(
      () {
        return { ok: detect.main.isQuests.Call() }
      }, () {
        clickAround(normalizeX(1300), normalizeY(400))
      }, () {
        return { ok: checkDelayed(detect.raid.isMainMenu, T_POLL) }
      }
    ),
    accessBoss: Step(
      () {
        return { ok: detect.raid.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(600), normalizeY(800))
      }, () {
        return { ok: checkDelayed(detect.raid.isBossMenu, T_POLL) }
      }
    ),
    accessBackupRequests: Step(
      () {
        return { ok: detect.raid.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1080), normalizeY(850))
      }, () {
        return { ok: checkDelayed(detect.raid.isBackupRequestsMenu, T_POLL) }
      }
    ),
    openBossPopup: Step(
      () {
        return { ok: detect.raid.isBossMenu.Call() }
      }, () {
        clickAround(normalizeX(1360), normalizeY(900))
      }, () {
        return { ok: detect.raid.isPlayable.Call() }
      }
    ),
    play: Step(
      () {
        return { ok: detect.raid.isPlayable.Call() }
      }, () {
        clickAround(normalizeX(1180), normalizeY(870))
      }, () {
        return { ok: !detect.raid.isPlayable.Call() }
      }
    ),
    results: Step(
      () {
        return { ok: !detect.raid.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1500), normalizeY(400)) ; skip combat start animation
        Sleep(T_POLL)
        confirm() ; close popups
        Sleep(T_POLL)
        skip() ; skip daily roll animation
      }, () {
        return { ok: checkDelayed(detect.raid.isMainMenu, T_POLL) }
      }
    ),
    switchTabJoinedBattles: Step(
      () {
        return { ok: detect.raid.isBackupRequestsMenu.Call() && !detect.raid.isJoinedBattlesTab.Call() }
      }, () {
        clickAround(normalizeX(130), normalizeY(300)) ; Joined Battles tab
      }, () {
        return { ok: detect.raid.isJoinedBattlesTab.Call() }
      }
    ),
    claimEndedBattles: Step(
      () {
        return { ok: detect.raid.hasEndedBattle.Call() || !detect.raid.isJoinedBattlesTab.Call() }
      }, () {
        clickAround(normalizeX(1450), normalizeY(880)) ; Ended button
        Sleep(T_POLL)
        confirm()
      }, () {
        return { ok: checkDelayed(detect.raid.isJoinedBattlesTab, T_POLL) && !detect.raid.hasEndedBattle.Call() }
      }
    ),
  },
  mission: {
    access: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        accessMissions()
      }, () {
        return { ok: checkDelayed(detect.mission.isMainMenu, T_POLL) }
      }
    ),
    accessSection: Step(
      (notificationY) {
        return { ok: detect.mission.isMainMenu.Call() && detect.mission.cannotClaim.Call(), data: notificationY.Get(1) + 20 }
      }, (sectionY) {
        clickAround(normalizeX(250), sectionY)
      }, () {
        return { ok: true }
      }
    ),
    accessMonthly: Step(
      () {
        return { ok: detect.mission.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1600), normalizeY(50))
      }, () {
        return { ok: checkDelayed(detect.mission.isMonthlyMenu, T_POLL) }
      }
    ),
    claim: Step(
      () {
        return { ok: !detect.mission.cannotClaim.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: checkDelayed(detect.mission.cannotClaim, T_POLL) }
      }
    )
  },
  gift: {
    access: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        accessGiftbox()
      }, () {
        isMainMenu := detect.gift.isMainMenu.Call()
        if (isMainMenu) {
          Sleep(T_POLL)
        }
        return { ok: isMainMenu }
      }
    ),
    claim: Step(
      () {
        return { ok: !detect.gift.cannotClaim.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.gift.cannotClaim.Call() }
      }
    )
  },
  other: {
    skipIntros: Step(
      () {
        return { ok: !detect.main.isMainMenu.Call() }
      }, () {
        if (detect.other.isLoadingBlack.Call()) {
          clickAround(normalizeX(1823), normalizeY(36))
        } else if (detect.other.canTapStart.Call() || detect.other.mustDownloadAssets.Call() || detect.other.hasItemsExpiringSoon.Call()) {
          confirm()
        } else if (detect.other.canPressKey.Call()) {
          goBack()
        }
      }, () {
        return { ok: checkDelayed(detect.main.isMainMenu, 2000, true) }
      }
    ),
    backToMain: Step(
      () {
        return { ok: !detect.main.isMainMenu.Call() && (detect.other.canPressKey.Call() || detect.other.canPressKeyAlt.Call()) }
      }, () {
        goBack()
      }, () {
        return { ok: checkDelayed(detect.main.isMainMenu, 2000, true) }
      }
    ),
    backToQuests: Step(
      () {
        return { ok: !detect.main.isQuests.Call() && (detect.other.canPressKey.Call() || detect.other.canPressKeyAlt.Call()) }
      }, () {
        goBack()
      }, () {
        return { ok: checkDelayed(detect.main.isQuests, T_POLL) }
      }
    ),
    accessQuestMenu: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1700), normalizeY(800))
      }, () {
        return { ok: checkDelayed(detect.main.isQuests, T_POLL) }
      }
    ),
    openClosePopup: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        goBack()
      }, () {
        return { ok: detect.other.isClosePopup.Call() }
      }
    ),
    close: Step(
      () {
        return { ok: detect.other.isClosePopup.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.other.isClosePopup.Call() }
      }
    )
  }
}
