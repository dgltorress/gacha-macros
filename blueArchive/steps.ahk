#Requires AutoHotkey >=2.1-alpha.3

#Include "%A_ScriptDir%/../step.ahk"
#Include "%A_ScriptDir%/config.ahk"
#Include "%A_ScriptDir%/utils.ahk"

colors := {
  loading: "0x000000",
  white: "0xFFFFFF",
  blue: "0x28CBFF",
  blueDark: "0x466398",
  blueDarker: "0x2D4663",
  blueDarkerer: "0x173D66",
  blueClear: "0x00BFFF",
  unclaimed: "0xFB4111", ; tends to use a gradient and may be inconsistent, use greater color tolerance
  alert: "0xFEBC10",
  full: "0xFFF489",
  pattable: "0xFFDE01",
  claimable: "0xF5E94B",
  claimableAlt: "0xF9EE4A",
  mobilize: "0xFDEA4B",
  star: "0xFCE226",
  primary: "0x77DEFF",
  enabled: "0xF4F5F6",
  disabled: "0xCDCDCD",
  disabledAlt: "0xDCDCDC",
  carouselActive: "0x31C8FF",
  carouselInactive: "0x2C4C72",
  textPopup: "0x3E444A",
  textSection: "0x34629B",
  textSectionMain: "0x2D4663",
  xClose: "0x0F2140",
  pvp: {
    data: "0x656766",
    myInfo: "0x1F81C6",
  },
  lessons: {
    ticket: "0x7BA3DA",
    tickets: "0x042438",
    ticketsLabel: "0x098EE5",
    locationRank: "0x2D4C72",
    loveable: "0xF3B8D2",
    loved: "0xB6EE66",
    textNoTickets: "0x3C4249"
  },
  cafe: {
    momo: "0xFA92A5" ; vertical gradient, at the height of the "o"s
  },
  dailyPack: {
    textFree: "0xF2E756"
  },
  bounties: {
    textStageList: "0xE2F2F8"
  },
  mailbox: {
    itemsIconLid: "0x27CBFF"
  },
  event: {
    textSelectedTab: "0xFFE401"
  }
}

coords := {
  notificationYUpper: normalizeY(26),
  notificationYLower: normalizeY(1015), ; except for Social
  pvp: {
    opponentX: normalizeX(1200),
    startingY: normalizeY(300),
    opponentSeparationY: normalizeY(238)
  },
  lessons: {
    lastSublocationX: '',
    lastSublocationY: '',
    sublocationAmount: 9,
    rowSize: 3,
    startingX: normalizeX(296),
    ;startingY: normalizeY(468),
    startingYScrolled: normalizeY(407),
    studentSeparationX: normalizeX(108),
    locationSeparationX: normalizeX(516),
    locationSeparationY: normalizeY(227),
    tickSeparationX: normalizeX(13),
    tickSeparationY: normalizeY(39),
    changedLocation: false
  },
  cafe: {
    lastPattableX: '',
    lastPattableY: '',
    inviteStartX: normalizeX(1080),
    inviteStartY: normalizeY(324),
    inviteSeparationY: normalizeY(117),
    zoomedOut: false,
    isInvited: false,
    isPatted: false
  },
  bounties: {
    lastStageY: '',
    lastStageYOffset: normalizeY(50),
    locationStartX: normalizeX(1000),
    locationStartY: normalizeY(300),
    locationSeparationY: normalizeY(161),
    thirdStarX: normalizeX(1108),
    enterButtonX: normalizeX(1660),
    searchStarStartY: normalizeY(1015),
    searchStarEndY: normalizeY(215)
  },
  event: {
    lastStageY: '',
    lastStageYOffset: normalizeY(50),
    thirdStarX: normalizeX(1125),
    enterButtonX: normalizeX(1660),
    searchStarStartY: normalizeY(1028),
    searchStarEndY: normalizeY(225),
    eventCarouselY: normalizeY(401),
    eventCarouselStartX: normalizeX(1711),
    eventCarouselEndX: normalizeX(1867)
  }
}

hasNotification(x, y, tolerance := 20) {
  return (
    isColor(x, y, colors.unclaimed, tolerance) ||
    isColor(x, y, colors.alert, tolerance) 
  )
}

; detection logic identifying successful access to menus should be more restrictive, as colors may load at different speeds

detect := {
  main: {
    isMainMenu: () {
      return isColor(normalizeX(137), normalizeY(981), colors.blue, COLOR_TOLERANCE) ; Cafe heart
    },
    isCampaign: () {
      return isColor(normalizeX(1247), normalizeY(260), colors.blueDark, COLOR_TOLERANCE) ; Missio(n)
    },
    hasPendingCampaign: () {
      return hasNotification(normalizeX(1876), normalizeY(755)) ; Notification from main menu
    }
  },
  pvp: {
    isMainMenu: () {
      return isColor(normalizeX(140), normalizeY(380), colors.blueDarkerer, COLOR_TOLERANCE) ; Profile picture container
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(1469), normalizeY(830)) ; Notification from campaign
    },
    canClaimTimeReward: () {
      return isColor(normalizeX(550), normalizeY(550), colors.claimable, COLOR_TOLERANCE) ; Claim button enabled
    },
    cannotClaimTimeReward: () {
      return isColor(normalizeX(550), normalizeY(550), colors.disabledAlt, 20) ; Claim button disabled
    },
    canClaimDailyReward: () {
      return isColor(normalizeX(550), normalizeY(670), colors.claimable, COLOR_TOLERANCE) ; Claim button enabled
    },
    cannotClaimDailyReward: () {
      return isColor(normalizeX(550), normalizeY(670), colors.disabledAlt, 20) ; Claim button disabled
    },
    hasTicketsLeft: () {
      return !isColor(normalizeX(339), normalizeY(732), colors.pvp.data, COLOR_TOLERANCE) ; (0) / 5, MAY BE UNRELIABLE
    },
    isBattlePrepPopup: () {
      return isColor(normalizeX(1330), normalizeY(500), colors.pvp.myInfo, COLOR_TOLERANCE) ; My Info background
    },
    isTimeoutPopup: () {
      return isColor(normalizeX(970), normalizeY(720), colors.primary, COLOR_TOLERANCE) ; Confirm background
    },
    isFormationScreen: () {
      return isColor(normalizeX(1760), normalizeY(960), colors.mobilize, 20) ; Mobilize background
    },
    isNoTicketsPopup: () {
      return isColor(normalizeX(779), normalizeY(623), colors.textPopup, COLOR_TOLERANCE) ; Pyro(x)ene Cost
    },
    hasNoStandby: () {
      return isColor(normalizeX(281), normalizeY(792), colors.pvp.data, COLOR_TOLERANCE)
    }
  },
  lessons: {
    isMainMenu: () {
      return isColor(normalizeX(1092), normalizeY(156), colors.textSection, COLOR_TOLERANCE) ; Loca(t)ion Select
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(372), coords.notificationYLower) ; Notification from outside
    },
    isLocation: () {
      return (
        isColor(normalizeX(1426), normalizeY(159), colors.lessons.locationRank, COLOR_TOLERANCE) && ; Rank background
        isColor(normalizeX(105), normalizeY(157), colors.lessons.ticket, COLOR_TOLERANCE) ; Ticket icon (takes a little while to appear)
      )
    },
    isSublocations: () {
      return isColor(normalizeX(1707), normalizeY(174), colors.xClose, COLOR_TOLERANCE) ; X
    },
    isSublocation: () {
      return isColor(normalizeX(1028), normalizeY(159), colors.blueDarker, COLOR_TOLERANCE) ; Location (I)nfo
    },
    isNoTicketsPopup: () {
      return isColor(normalizeX(942), normalizeY(609), colors.lessons.textNoTickets, COLOR_TOLERANCE) ; (T)otal Cost
    },
    ; searches through the "All Locations" menu in reverse order for (at least) `targetAmount` students with available relationship increase
    findAvailableFromBelow: (&from, targetAmount := 1, minSublocation := 1) {
      i := from
      if (i <= coords.lessons.sublocationAmount) {
        while (i-- >= minSublocation) {
          x := coords.lessons.startingX + (coords.lessons.locationSeparationX * Mod(i, coords.lessons.rowSize))
          y := coords.lessons.startingYScrolled + (coords.lessons.locationSeparationY * (i // coords.lessons.rowSize))
          j := 0
          availableAmount := 0
          while (j++ < 3) {
            ; debug
            ;MsgBox(Format(
            ;  "x{1} y{2}`nSublocation: {3}`nStudent: {4}`nIs loveable: {5} ({6})`nIs loved: {7} ({8}) (x{9} y{10}))",
            ;  x, y, i + 1, j,
            ;  PixelSearch(&coords.lessons.lastSublocationX, &coords.lessons.lastSublocationY, x, y, x, y, colors.lessons.loveable, COLOR_TOLERANCE),
            ;  PixelGetColor(x, y),
            ;  isColor(x + coords.lessons.tickSeparationX, y + coords.lessons.tickSeparationY, colors.lessons.loved, COLOR_TOLERANCE),
            ;  PixelGetColor(x + coords.lessons.tickSeparationX, y + coords.lessons.tickSeparationY),
            ;  x + coords.lessons.tickSeparationX, y - coords.lessons.tickSeparationY
            ;))
            if (
              PixelSearch(&coords.lessons.lastSublocationX, &coords.lessons.lastSublocationY, x, y, x, y, colors.lessons.loveable, COLOR_TOLERANCE) &&
              !isColor(x + coords.lessons.tickSeparationX, y - coords.lessons.tickSeparationY, colors.lessons.loved, COLOR_TOLERANCE) &&
              (++availableAmount >= targetAmount)
            ) {
              from := i
              coords.lessons.lastSublocationX -= 20
              coords.lessons.lastSublocationY -= 20
              return true
            }
            x += coords.lessons.studentSeparationX
          }
        }
      }
      return false
    }
  },
  cafe: {
    isMainMenu: () {
      return isColor(normalizeX(266), normalizeY(20), colors.blueDarker, COLOR_TOLERANCE) ; [?]
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(176), coords.notificationYLower) ; Notification from outside
    },
    hasPendingActionsCafe2: () {
      return hasNotification(normalizeX(332), normalizeY(128)) ; Notification in Cafe 2 tab
    },
    isVisits: () {
      return isColor(normalizeX(1382), normalizeY(280), colors.xClose, COLOR_TOLERANCE) ; X
    },
    isEarnings: () {
      return isColor(normalizeX(976), normalizeY(219), colors.textSectionMain, COLOR_TOLERANCE) ; Cafe Ea(r)nings
    },
    hasEarnings: () {
      return hasNotification(normalizeX(1877), normalizeY(940)) ; Has earnings
    },
    canClaimEarnings: () {
      return isColor(normalizeX(970), normalizeY(750), colors.claimable, 20) ; Confirm button background
    },
    isFull: () {
      return isColor(normalizeX(1810), normalizeY(910), colors.full, COLOR_TOLERANCE) ; Full notification
    },
    isInvite: () {
      return isColor(normalizeX(1000), normalizeY(149), colors.cafe.momo, COLOR_TOLERANCE) ; MomoTalk background
    },
    findPattable: () { ; Searches a relatively large area for the calling symbol
      found := PixelSearch(&coords.cafe.lastPattableX, &coords.cafe.lastPattableY, normalizeX(170), normalizeY(200), normalizeX(1840), normalizeY(850), colors.pattable, COLOR_TOLERANCE)
      if (found) {
        coords.cafe.lastPattableX += 75
        coords.cafe.lastPattableY += 50
      }
      return found
    },
    isPattable: () {
      return isColor(coords.cafe.lastPattableX, coords.cafe.lastPattableY, colors.pattable, COLOR_TOLERANCE) ; Calling symbol
    }
  },
  social: {
    isMainMenu: () {
      return isColor(normalizeX(1120), normalizeY(320), colors.white, COLOR_TOLERANCE) ; Soci(a)l
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(887), normalizeY(1012)) ; Notification from outside
    },
    hasPendingClubAccess: () {
      return hasNotification(normalizeX(700), normalizeY(450)) ; Notification from popup
    }
  },
  dailyPack: {
    isMainMenu: () {
      return isColor(normalizeX(1017), normalizeY(172), colors.textSectionMain, COLOR_TOLERANCE) ; Buy Pyro(x)ene
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(1507), coords.notificationYUpper) ; Notification from outside
    },
    hasPendingPackTab: () {
      return hasNotification(normalizeX(1545), normalizeY(227)) ; Notification from tab
    },
    hasPendingFreePack: () {
      return (
        hasNotification(normalizeX(759), normalizeY(341)) && ; Notification from item
        isColor(normalizeX(551), normalizeY(712), colors.dailyPack.textFree, COLOR_TOLERANCE) ; (F)ree of charge check
      )
    },
    isPacksTab: () {
      return isColor(normalizeX(1170), normalizeY(250), colors.white, COLOR_TOLERANCE) ; Buy Pyro(x)ene
    },
    isConfirmPopup: () {
      return isColor(normalizeX(1017), normalizeY(133), colors.textSectionMain, COLOR_TOLERANCE) ; Buy Pyro(x)ene
    },
    canBuy: () {
      return (
        isColor(normalizeX(1164), normalizeY(855), colors.dailyPack.textFree, COLOR_TOLERANCE) && ; Confirm background
        isColor(normalizeX(1250), normalizeY(665), colors.dailyPack.textFree, COLOR_TOLERANCE) ; (F)ree of charge check
      )
    },
  },
  bounties: {
    isMainMenu: () {
      return isColor(normalizeX(1099), normalizeY(157), colors.white, COLOR_TOLERANCE) ; Loca(t)ion Select
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(1217), normalizeY(553)) ; Notification from outside
    },
    isLocationMenu: () {
      return isColor(normalizeX(1349), normalizeY(163), colors.bounties.textStageList, COLOR_TOLERANCE) ; S(t)age List
    },
    isMissionInfoPopup: () {
      return isColor(normalizeX(1059), normalizeY(204), colors.blueDarker, COLOR_TOLERANCE) ; Mission In(f)o
    },
    isNoTicketsPopup: () {
      return isColor(normalizeX(1087), normalizeY(373), colors.textPopup, COLOR_TOLERANCE) ; Purchase Bounty Tic(k)et
    },
    canAddSweeps: () {
      return isColor(normalizeX(1626), normalizeY(427), colors.enabled, COLOR_TOLERANCE) ; [Max] background
    },
    cannotAddSweeps: () {
      return isColor(normalizeX(1626), normalizeY(427), colors.disabled, COLOR_TOLERANCE) ; [Max] background
    },
    ; first obtained third star from below
    findSkippableStage: () {
      return PixelSearch(
        &px, &coords.bounties.lastStageY, coords.bounties.thirdStarX,
        coords.bounties.lastStageY ? coords.bounties.lastStageY - coords.bounties.lastStageYOffset : coords.bounties.searchStarStartY, coords.bounties.thirdStarX,
        coords.bounties.searchStarEndY, colors.star, COLOR_TOLERANCE
      )
    }
  },
  tasks: {
    isMainMenu: () {
      return isColor(normalizeX(232), normalizeY(41), colors.textSectionMain, COLOR_TOLERANCE) ; Tas(k)s
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(142), normalizeY(384)) ; Notification from outside
    },
    canClaimAll: () {
      return isColor(normalizeX(1711), normalizeY(973), colors.claimableAlt, 20) ; Claim background
    },
    cannotClaimAll: () {
      return isColor(normalizeX(1711), normalizeY(973), colors.disabled, 20) ; Claim background
    },
    canClaimDailyPyroxenes: () {
      return isColor(normalizeX(1474), normalizeY(973), colors.claimableAlt, 20) ; Claim background
    },
    cannotClaimDailyPyroxenes: () {
      return isColor(normalizeX(1474), normalizeY(973), colors.disabledAlt, 20) ; Claim background
    }
  },
  mailbox: {
    isMainMenu: () {
      return isColor(normalizeX(290), normalizeY(752), colors.mailbox.itemsIconLid, COLOR_TOLERANCE) ; Tas(k)s
    },
    hasPendingActionsOutside: () {
      return hasNotification(normalizeX(1772), coords.notificationYUpper) ; Notification from outside
    },
    canClaimAll: () {
      return isColor(normalizeX(1690), normalizeY(970), colors.claimable, 20) ; Claim background
    }
  },
  event: { ; story event
    isMainMenu: () {
      return isColor(normalizeX(261), normalizeY(30), colors.textSectionMain, COLOR_TOLERANCE) ; Even(t)
    },
    isHoveringFirstEventOutside: () { ; story event tends to be the first one in the carousel
      px := ''
      if (
        PixelSearch(
          &px, &py, coords.event.eventCarouselStartX, coords.event.eventCarouselY, coords.event.eventCarouselEndX, coords.event.eventCarouselY,
          colors.carouselActive, COLOR_TOLERANCE
        )
      ) {
        return !PixelSearch(
          &px, &py, px, coords.event.eventCarouselY, coords.event.eventCarouselStartX, coords.event.eventCarouselY,
          colors.carouselInactive, COLOR_TOLERANCE
        )
      }
      return false
    },
    isStoryEvent: () {
      return ( ; Ques(t)
        isColor(normalizeX(1455), normalizeY(159), colors.event.textSelectedTab, COLOR_TOLERANCE) ||
        isColor(normalizeX(1455), normalizeY(159), colors.blueDarker, COLOR_TOLERANCE)
      )
    },
    isQuestTab: () {
      return isColor(normalizeX(1455), normalizeY(159), colors.event.textSelectedTab, COLOR_TOLERANCE) ; Ques(t)
    },
    isMissionInfoPopup: () {
      return isColor(normalizeX(1059), normalizeY(204), colors.blueDarker, COLOR_TOLERANCE) ; Mission In(f)o
    },
    isNoAPPopup: () {
      return isColor(normalizeX(942), normalizeY(609), colors.textNoTickets, COLOR_TOLERANCE) ; (T)otal Cost
    },
    canAddSweeps: () {
      return isColor(normalizeX(1626), normalizeY(427), colors.enabled, COLOR_TOLERANCE) ; [Max] background
    },
    cannotAddSweeps: () {
      return isColor(normalizeX(1626), normalizeY(427), colors.disabled, COLOR_TOLERANCE) ; [Max] background
    },
    ; first obtained third star from below
    findSkippableStage: () {
      return PixelSearch(
        &px, &coords.event.lastStageY, coords.event.thirdStarX,
        coords.event.lastStageY ? coords.event.lastStageY - coords.event.lastStageYOffset : coords.event.searchStarStartY, coords.event.thirdStarX,
        coords.event.searchStarEndY, colors.star, COLOR_TOLERANCE
      )
    }
  },
  other: {
    isLoading: () {
      return isColor(normalizeX(10), normalizeY(10), colors.loading, COLOR_TOLERANCE)
    },
    hasItemsExpiringSoon: () {
      return isColor(normalizeX(960), normalizeY(780), colors.primary, COLOR_TOLERANCE) ; Confirm background
    },
    canGoBack: () {
      return isColor(normalizeX(64), normalizeY(55), colors.white, COLOR_TOLERANCE) ; Tip of the back arrow
    },
    canGoHome: () {
      return isColor(normalizeX(1852), normalizeY(28), colors.blueDark, COLOR_TOLERANCE) ; Home icon
    },
    isNoticeConfirm: () {
      return isColor(normalizeX(970), normalizeY(710), colors.primary, COLOR_TOLERANCE) ; Confirm background
    },
    isNoticeCancelConfirm: () {
      return isColor(normalizeX(1170), normalizeY(710), colors.primary, COLOR_TOLERANCE) ; Confirm background
    }
  }
}

steps := {
  pvp: {
    access: Step(
      () {
        return { ok: detect.pvp.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(1300), normalizeY(900))
      }, () {
        return { ok: checkDelayed(detect.pvp.isMainMenu, T_POLL) }
      }
    ),
    claimTimeReward: Step(
      () {
        return { ok: detect.pvp.canClaimTimeReward.Call() || !detect.pvp.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(510), normalizeY(600)) ; click claim and confirm popup
        Sleep(T_POLL)
        confirm()
      }, () {
        return { ok: checkDelayed(detect.pvp.cannotClaimTimeReward, T_POLL) }
      }
    ),
    claimDailyReward: Step(
      () {
        return { ok: detect.pvp.canClaimDailyReward.Call() || !detect.pvp.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(510), normalizeY(720)) ; click claim and confirm popup
        Sleep(T_POLL)
        confirm()
      }, () {
        return { ok: checkDelayed(detect.pvp.cannotClaimDailyReward, T_POLL) }
      }
    ),
    selectOpponent: Step(
      (opponent) {
        return { ok: detect.pvp.isMainMenu.Call() && detect.pvp.hasNoStandby.Call(), data: opponent.Get(1) }
      }, (opponent) {
        clickAround(coords.pvp.opponentX, coords.pvp.startingY + (coords.pvp.opponentSeparationY * opponent)) ; click claim and confirm popup
      }, () {
        return { ok: detect.pvp.isBattlePrepPopup.Call() }
      }
    ),
    confirmOpponent: Step(
      () {
        return { ok: detect.pvp.isBattlePrepPopup.Call() }
      }, () {
        clickAround(normalizeX(900), normalizeY(830)) ; Attack formation
      }, () {
        return { ok: checkDelayed(detect.pvp.isFormationScreen, T_POLL) || checkDelayed(detect.pvp.isNoTicketsPopup, T_POLL) }
      }
    ),
    attackOpponent: Step(
      () {
        return { ok: !detect.pvp.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1730), normalizeY(980)) ; Mobilize + Empty spot underneath
      }, () {
        return { ok: checkDelayed(detect.pvp.isMainMenu, T_POLL, true) }
      }
    )
  },
  lessons: {
    access: Step(
      () {
        return { ok: detect.lessons.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(300), normalizeY(950))
      }, () {
        return { ok: checkDelayed(detect.lessons.isMainMenu, T_POLL) }
      }
    ),
    accessSchaleOffice: Step(
      () {
        return { ok: detect.lessons.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1300), normalizeY(240))
      }, () {
        return { ok: checkDelayed(detect.lessons.isLocation, T_POLL) }
      }
    ),
    changeLocation: Step(
      (backwards) {
        return { ok: !coords.lessons.changedLocation, data: backwards.Get(1) }
      }, (backwards) {
        clickAround(backwards ? normalizeX(30) : normalizeX(1860), normalizeY(520))
        coords.lessons.changedLocation := true
      }, () {
        ok := checkDelayed(detect.lessons.isLocation, T_POLL, true)
        if (ok) {
          coords.lessons.changedLocation := false
        }
        return { ok: ok }
      }
    ),
    accessSublocations: Step(
      () {
        return { ok: detect.lessons.isLocation.Call() }
      }, () {
        clickAround(normalizeX(1720), normalizeY(960))
      }, () {
        return { ok: checkDelayed(detect.lessons.isSublocations, T_POLL) }
      }
    ),
    scrollSublocations: Step(
      () {
        return { ok: false }
      }, () {

      }, () {
        scrollAround(normalizeX(1660), normalizeY(300), "D")
        Sleep(1500)
        return { ok: true }
      }
    ),
    selectSublocation: Step(
      () {
        return { ok: detect.lessons.isSublocations.Call() }
      }, () {
        clickAround(coords.lessons.lastSublocationX, coords.lessons.lastSublocationY)
      }, () {
        return { ok: checkDelayed(detect.lessons.isSublocation, T_POLL) }
      }
    ),
    confirmSublocation: Step(
      () {
        return { ok: !detect.lessons.isSublocations.Call() && !detect.lessons.isNoTicketsPopup.Call() }
      }, () {
        if (detect.lessons.isSublocation.Call()) {
          clickAround(normalizeX(815), normalizeY(820)) ; Confirm button, not overlapping with the Confirm button in a possible popup prompting to spend pyroxenes
        } else {
          clickAround(normalizeX(200), normalizeY(200)) ; Empty spot in sublocation screen
        }
      }, () {
        return { ok: checkDelayed(detect.lessons.isSublocations, T_POLL) || checkDelayed(detect.lessons.isNoTicketsPopup, T_POLL) }
      }
    ),
    returnToLocation: Step(
      () {
        return { ok: !detect.lessons.isLocation.Call() }
      }, () {
        clickAround(normalizeX(1880), normalizeY(880)) ; Empty spot in all stacked screens
      }, () {
        return { ok: checkDelayed(detect.lessons.isLocation, T_POLL) }
      }
    )
  },
  cafe: {
    access: Step(
      () {
        return { ok: detect.cafe.hasPendingActionsOutside.Call() || detect.cafe.isVisits.Call() }
      }, () {
        clickAround(normalizeX(120), normalizeY(950))
      }, () {
        return { ok: checkDelayed(detect.cafe.isMainMenu, T_POLL, true) }
      }
    ),
    accessCafe2: Step(
      () {
        return { ok: detect.cafe.hasPendingActionsCafe2.Call() || detect.cafe.isVisits.Call() }
      }, () {
        clickAround(normalizeX(140), normalizeY(140))
      }, () {
        return { ok: checkDelayed(detect.cafe.isMainMenu, T_POLL, true) }
      }
    ),
    openEarnings: Step(
      () {
        return { ok: detect.cafe.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1720), normalizeY(950))
      }, () {
        return { ok: checkDelayed(detect.cafe.isEarnings, T_POLL) }
      }
    ),
    claimEarnings: Step(
      () {
        return { ok: !detect.cafe.isMainMenu.Call() }
      }, () {
        if (detect.cafe.canClaimEarnings.Call()) {
          confirm()
        } else {
          goBack()
        }
      }, () {
        return { ok: checkDelayed(detect.cafe.isMainMenu, T_POLL) }
      }
    ),
    openInvite: Step(
      () {
        return { ok: detect.cafe.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1300), normalizeY(950))
      }, () {
        return { ok: checkDelayed(detect.cafe.isInvite, T_POLL) || checkDelayed(detect.other.isNoticeConfirm, T_POLL) }
      }
    ),
    sendInvite: Step(
      (index) {
        return { ok: !detect.cafe.isMainMenu.Call(), data: index.Get(1) }
      }, (index) {
        if (!coords.cafe.isInvited && detect.cafe.isInvite.Call()) {
          clickAround(coords.cafe.inviteStartX, coords.cafe.inviteStartY + (index * coords.cafe.inviteSeparationY))
          coords.cafe.isInvited := true
        } else if (detect.other.isNoticeCancelConfirm.Call()) {
          confirm()
        } else {
          clickAround(normalizeX(1260), normalizeY(130)) ; skip fake loading by closing the popup
        }
      }, () {
        ok := checkDelayed(detect.cafe.isMainMenu, T_POLL, true)
        if (ok) {
          coords.cafe.isInvited := false
        }
        return { ok: ok }
      }
    ),
    exitPopup: Step(
      () {
        return { ok: !detect.cafe.isMainMenu.Call() }
      }, () {
        goBack()
      }, () {
        return { ok: checkDelayed(detect.cafe.isMainMenu, T_POLL) }
      }
    ),
    zoomOut: Step(
      () {
        return { ok: !coords.cafe.zoomedOut }
      }, () {
        scroll(500, 500, "D", 10)
        coords.cafe.zoomedOut := true
      }, () {
        ok := checkDelayed(detect.cafe.isMainMenu, T_POLL)
        if (ok) {
          coords.cafe.zoomedOut := false
          Sleep(T_POLL)
        }
        return { ok: ok }
      }
    ),
    pat: Step(
      () {
        return { ok: !coords.cafe.isPatted || !detect.cafe.isMainMenu.Call() }
      }, () {
        clickExact(coords.cafe.lastPattableX, coords.cafe.lastPattableY)
        coords.cafe.isPatted := true
      }, () {
        ok := checkDelayed(detect.cafe.isMainMenu, 3000, true)
        if (ok) {
          coords.cafe.isPatted := false
        }
        return { ok: ok }
      }
    )
  },
  social: {
    openPopup: Step(
      () {
        return { ok: detect.social.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(820), normalizeY(950))
      }, () {
        return { ok: checkDelayed(detect.social.isMainMenu, T_POLL) }
      }
    ),
    accessClub: Step(
      () {
        return { ok: detect.social.hasPendingClubAccess.Call() }
      }, () {
        clickAround(normalizeX(400), normalizeY(600))
      }, () {
        return { ok: !detect.social.isMainMenu.Call() }
      }
    )
  },
  dailyPack: {
    openPopup: Step(
      () {
        return { ok: detect.dailyPack.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(1460), normalizeY(45))
      }, () {
        return { ok: checkDelayed(detect.dailyPack.isMainMenu, T_POLL) }
      }
    ),
    switchTabPacks: Step(
      () {
        return { ok: !detect.dailyPack.isPacksTab.Call() }
      }, () {
        clickAround(normalizeX(1170), normalizeY(250))
      }, () {
        return { ok: checkDelayed(detect.dailyPack.isPacksTab, T_POLL) }
      }
    ),
    openFreeDailyPack: Step(
      () {
        return { ok: detect.dailyPack.hasPendingFreePack.Call() }
      }, () {
        clickAround(normalizeX(550), normalizeY(740))
      }, () {
        return { ok: checkDelayed(detect.dailyPack.isConfirmPopup, T_POLL) }
      }
    ),
    claimFreeDailyPack: Step(
      () {
        return { ok: detect.dailyPack.canBuy.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.dailyPack.isConfirmPopup.Call() }
      }
    )
  },
  bounties: {
    access: Step(
      () {
        return { ok: detect.bounties.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(1070), normalizeY(620))
      }, () {
        return { ok: checkDelayed(detect.bounties.isMainMenu, T_POLL) }
      }
    ),
    accessLocation: Step(
      (index) {
        return { ok: detect.bounties.isMainMenu.Call(), data: index.Get(1) }
      }, (index) {
        clickAround(coords.bounties.locationStartX, coords.bounties.locationStartY + (index * coords.bounties.locationSeparationY))
      }, () {
        return { ok: checkDelayed(detect.bounties.isLocationMenu, T_POLL) }
      }
    ),
    scrollStages: Step(
      () {
        return { ok: false }
      }, () {
        
      }, () {
        scrollAround(normalizeX(1400), normalizeY(300), "U", 5)
        coords.bounties.lastStageY := ''
        Sleep(1500)
        return { ok: true }
      }
    ),
    accessStage: Step(
      () {
        return { ok: detect.bounties.isLocationMenu.Call() }
      }, () {
        clickAround(coords.bounties.enterButtonX, coords.bounties.lastStageY, 10, 10)
      }, () {
        return { ok: checkDelayed(detect.bounties.isMissionInfoPopup, T_POLL) }
      }
    ),
    setMaxSweeps: Step(
      () {
        return { ok: detect.bounties.canAddSweeps.Call() }
      }, () {
        clickAround(normalizeX(1626), normalizeY(450))
      }, () {
        return { ok: detect.bounties.cannotAddSweeps.Call() }
      }
    ),
    openSweep: Step(
      () {
        return { ok: detect.bounties.isMissionInfoPopup.Call() }
      }, () {
        clickAround(normalizeX(1200), normalizeY(600))
      }, () {
        return { ok: checkDelayed(detect.other.isNoticeCancelConfirm, T_POLL) || checkDelayed(detect.bounties.isNoTicketsPopup, T_POLL) }
      }
    ),
    confirmSweep: Step(
      () {
        return { ok: detect.other.isNoticeCancelConfirm.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.other.isNoticeCancelConfirm.Call() }
      }
    )
  },
  tasks: {
    access: Step(
      () {
        return { ok: detect.tasks.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(70), normalizeY(320))
      }, () {
        return { ok: checkDelayed(detect.tasks.isMainMenu, T_POLL) }
      }
    ),
    claimDailyPyroxenes: Step(
      () {
        return { ok: detect.tasks.canClaimDailyPyroxenes.Call() || !detect.tasks.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1400), normalizeY(1000))
      }, () {
        return { ok: detect.tasks.cannotClaimDailyPyroxenes.Call() }
      }
    ),
    claimAll: Step(
      () {
        return { ok: detect.tasks.canClaimAll.Call() || !detect.tasks.isMainMenu.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: detect.tasks.cannotClaimAll.Call() }
      }
    )
  },
  mailbox: {
    access: Step(
      () {
        return { ok: detect.mailbox.hasPendingActionsOutside.Call() }
      }, () {
        clickAround(normalizeX(1700), normalizeY(45))
      }, () {
        return { ok: checkDelayed(detect.mailbox.isMainMenu, T_POLL) }
      }
    ),
    claimAll: Step( ; account for possibly maxed out AP, which will prevent claiming mailbox items
      () {
        return { ok: detect.mailbox.canClaimAll.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.mailbox.isMainMenu.Call() }
      }
    )
  },
  event: {
    access: Step(
      () {
        return { ok: detect.event.isHoveringFirstEventOutside.Call() }
      }, () {
        clickAround(normalizeX(1800), normalizeY(300))
      }, () {
        return { ok: checkDelayed(detect.event.isMainMenu, T_POLL) }
      }
    ),
    switchTabQuest: Step(
      () {
        return { ok: !detect.event.isQuestTab.Call() }
      }, () {
        clickAround(normalizeX(1300), normalizeY(150))
      }, () {
        return { ok: checkDelayed(detect.event.isQuestTab, T_POLL) }
      }
    ),
    scrollStages: Step(
      () {
        return { ok: false }
      }, () {
        
      }, () {
        scrollAround(normalizeX(1400), normalizeY(300), "U", 5)
        coords.event.lastStageY := ''
        Sleep(1500)
        return { ok: true }
      }
    ),
    accessStage: Step(
      () {
        return { ok: detect.event.isQuestTab.Call() }
      }, () {
        clickAround(coords.event.enterButtonX, coords.event.lastStageY, 10, 10)
      }, () {
        return { ok: checkDelayed(detect.event.isMissionInfoPopup, T_POLL) }
      }
    ),
    setMaxSweeps: Step(
      () {
        return { ok: detect.event.canAddSweeps.Call() }
      }, () {
        clickAround(normalizeX(1626), normalizeY(450))
      }, () {
        return { ok: detect.event.cannotAddSweeps.Call() }
      }
    ),
    openSweep: Step(
      () {
        return { ok: detect.event.isMissionInfoPopup.Call() }
      }, () {
        clickAround(normalizeX(1200), normalizeY(600))
      }, () {
        return { ok: checkDelayed(detect.other.isNoticeCancelConfirm, T_POLL) || checkDelayed(detect.event.isNoAPPopup, T_POLL) }
      }
    ),
    confirmSweep: Step(
      () {
        return { ok: detect.other.isNoticeCancelConfirm.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.other.isNoticeCancelConfirm.Call() }
      }
    )
  },
  other: {
    skipIntros: Step(
      () {
        return { ok: !detect.main.isMainMenu.Call() }
      }, () {
        if (detect.other.canGoHome.Call()) {
          clickAround(normalizeX(1840), normalizeY(30))
        } else if (detect.other.canGoBack.Call()) {
          goBack()
        } else {
          clickAround(normalizeX(1500), normalizeY(190)) ; X to close notices
          Sleep(T_POLL)
          clickAround(normalizeX(1673), normalizeY(160))
        }
      }, () {
        return { ok: checkDelayed(detect.main.isMainMenu, 3500, true) }
      }
    ),
    backToMain: Step(
      () {
        return { ok: !detect.main.isMainMenu.Call() }
      }, () {
        if (detect.other.canGoHome.Call()) {
          clickAround(normalizeX(1840), normalizeY(30))
        } else {
          goBack()
        }
      }, () {
        return { ok: checkDelayed(detect.main.isMainMenu, 2000, true) }
      }
    ),
    backToCampaign: Step(
      () {
        return { ok: !detect.main.isCampaign.Call() }
      }, () {
        goBack()
      }, () {
        return { ok: checkDelayed(detect.main.isCampaign, T_POLL) }
      }
    ),
    accessCampaignMenu: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        clickAround(normalizeX(1760), normalizeY(800))
      }, () {
        return { ok: checkDelayed(detect.main.isCampaign, T_POLL) }
      }
    ),
    openClosePopup: Step(
      () {
        return { ok: detect.main.isMainMenu.Call() }
      }, () {
        goBack()
      }, () {
        return { ok: detect.other.isNoticeCancelConfirm.Call() }
      }
    ),
    close: Step(
      () {
        return { ok: detect.other.isNoticeCancelConfirm.Call() }
      }, () {
        confirm()
      }, () {
        return { ok: !detect.other.isNoticeCancelConfirm.Call() }
      }
    )
  }
}
