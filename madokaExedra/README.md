
# Madoka Exedra Automator

A macro that will automatically **perform most dailies in [Puella Magi Madoka Magica: Magia Exedra](https://store.steampowered.com/app/2987800/)** (Global Steam version) by mimicking user clicks and key inputs based on specific elements of the interface.

Last tested using version `2.12.1` with a resolution of **1920x1080** (it should also support other resolutions, although none other have been tested).

## Usage

The uncompiled script requires [AutoHotkey v2.1-alpha.3](https://www.autohotkey.com/download/2.1/) (or greater).

Upon executing the script, a GUI will be displayed, and it will **automatically find the game's window based on the preconfigured name**.

![Madoka Exedra Automator GUI](/madokaExedra/madokaExedraGUI.png "Madoka Exedra Automator GUI")

Even if the GUI was opened before the game, or the game's window has a different name from the one that is preconfigured, the window can still be detected manually by entering its name and clicking `Detect`.

After the window is detected, the flow can be `Start`ed by clicking the corresponding button. It will carry out the following actions (most of which either can be toggled or are customizable):

> [!NOTE]
> **Ctrl + C can be pressed at any time to interrupt the script**

1. (Only if not currently at the main menu) **Skip intros**, notices and notifications, or attempt to back out to the main menu.
2. Claim rewards from the **magia box**.
3. Skip daily **PvP battles** (only if any are available). *It will pick a random opponent between the two at the bottom*.
4. Skip the second-to-last **Tower level** (only if any are available).
5. Skip the second-to-last **Heartphial battle** (only if any are available).
6. Splurge QP on a random or preset **material** (Growth Enhancement or Gems).
7. Skip the last **event battle** (only if already completed) for the **three most recent ongoing events** and the archive event ***Memories of You II***.
8. Perform the minimum required **raids** for the daily reward roll. *Make sure to have a low raid level, high party level, and no backup already set up*.
9. Claim all available rewards for completed **missions** (including monthlies).
10. Claim all available **gifts**.
11. (Optionally) **Close** the game.

In the same folder as the script, a configuration file is generated/updated each time the `Start` button is clicked, and a log file can also be optionally generated.

> [!TIP]
> Timeouts and other more technical settings have no attached GUI controls, but can be modified from the configuration file itself.
