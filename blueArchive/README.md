
# Blue Archive Automator

A macro that will automatically **perform most dailies in [Blue Archive](https://store.steampowered.com/app/3557620/)** (Global Steam version) by mimicking user clicks and key inputs based on specific elements of the interface.

Last tested using version `379434` with a resolution of **1920x1080** (it should also support other resolutions, although none other have been tested).

## Usage

The uncompiled script requires [AutoHotkey v2.1-alpha.3](https://www.autohotkey.com/download/2.1/) (or greater).

Upon executing the script, a GUI will be displayed, and it will **automatically find the game's window based on the preconfigured name**.

![Blue Archive Automator GUI](/blueArchive/blueArchiveGUI.png "Blue Archive Automator GUI")

Even if the GUI was opened before the game, or the game's window has a different name from the one that is preconfigured, the window can still be detected manually by entering its name and clicking `Detect`.

After the window is detected, the flow can be `Start`ed by clicking the corresponding button. It will carry out the following actions (most of which either can be toggled or are customizable):

> [!NOTE]
> **Ctrl + C can be pressed at any time to interrupt the script**

1. (Only if not currently at the main menu) **Skip intros**, notices and notifications, or attempt to back out to the main menu.
2. Skip *one* **PvP match**, and claim available rewards (if any). *This will be repeated sporadically up to five times throughout the flow in an attempt to bypass standby times*.
3. Spend **Lesson tickets**, starting from the Schale Office. *The preferred amount of students to target and total available locations, as well as the lookup direction, can all be customized. After looping through all of them once, the minimum amount required will be reduced*.
4. Claim **Cafe earnings**. Students can also be **invited** and **patted**. *If patting is toggled on, bear in mind furniture with yellow features might confuse color detection*.
5. Claim the **Club attendance reward**.
6. Spend all **Bounty tickets** on the last *skippable* stage of a random or preset location.
7. Claim all **Task rewards**. *If any are available at the very end, this will be done again*.
8. Claim the **Free daily pack** from the Pyroxene store.
9. Claim all **Mailbox items** *once*.
10. (Optionally) Splurge AP on the *n*<sup>th</sup> last skippable stage of the current **Story event** (if any)
11. (Optionally) **Close** the game.

In the same folder as the script, a configuration file is generated/updated each time the `Start` button is clicked, and a log file can also be optionally generated.

> [!TIP]
> Timeouts and other more technical settings have no attached GUI controls, but can be modified from the configuration file itself.
