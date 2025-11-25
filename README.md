
# Gacha macros

A scripting base for macros that automatically complete purely mechanical tasks in gacha-like video games by mimicking manual user input and inferring data from predictable elements in the graphic interface itself.

This structure benefits macros that manipulate menus with a mostly static disposition of its elements and colors, and provides ways to account for unresponsiveness and define backoff strategies.

## Features

- A predefined step-based structure to interact with menus with unpredictable responsivity.
- Generic methods to perform basic user actions, such as clicking an approximate spot on the screen or spamming a key.
- Logic to load and update meta configuration files, with a few basic options shared by all and a section that can be extended with settings specific to an app.
- A basic logging implementation.

There are working scripts for specific games in this repository which make use of these.

## Usage

Any uncompiled script using this structure requires [AutoHotkey v2.1-alpha.3](https://www.autohotkey.com/download/2.1/) (or greater).
