# Slippipedia - Your flexible replay manager

This program can analyze a large number of Slippi replays and display detailed, filterable statistics and info.

## Credits

* Slippi ([slippi.gg](https://slippi.gg))
* Slippc ([GitHub](https://github.com/pcrain/slippc)) - Slippi replay parser in C++
* Built with Felgo SDK ([felgo.com](https://felgo.com))

## How to Use

Download the latest release for your operating system. Start the included `.app` or the `.exe` file.

### Select replay folder

Select your Slippi replay directory. Per default, this should be in `(documents)/Slippi`. In this case, the folder should be pre-selected automatically.

![replay folder](images/replay-folder.png)

### Analyze replays

This step reads each replay and stores the relevant information in a database for fast lookup. Depending on your setup and the number of replays, this can take a few minutes.
When you have new replays, or change the folder, you can choose to only analyze new replays.

![analyzing](images/analyzing.png)

### Set player filter

For more detailed output, like win rate and opponent stats, set your Slippi name and/or tag in the filter configuration.

![filter-player](images/filter-player.png)

### Explore stats

Use the tabs to explore data about your replays. 

#### Statistics

Statistics shows global stats. First tab shows number of games, win rate, character usage (me/opponent), stage usage. Second tab shows detailed stats. Third tab shows player tags and codes.

![stats](images/stats.png)

#### Analytics

Analytics groups stats by character, matchup, stage and time frame. 

![analytics](images/analytics.png)

#### Browser

Browser lists the replays one by one. Click the play icon to can re-watch them (needs [Slippi Desktop app](https://github.com/project-slippi/slippi-desktop-app)). Click the folder icon to find a specific replay file on your file system.

![browser](images/browser.png)

### Filtering

Restrict your replays by detailed criteria. All other stats, analytics and browser consider the filter settings.

#### Player and opponent filter

First tab lets configures the player filter. Set your Slippi name and/or tag to enable win rate, opponent data etc. You can also filter by one or more specific characters.

![player filter](images/filter-player.png)

Second tab lets you filter for specific opponents and characters.

#### Game result filter

Third tab lets you filter by game results. Set a min/max game duration, game outcom and remaining stocks. You can use this e.g. to filter short games that probably did not finish.

![result filter](images/filter-result.png)

#### Game filter

Fourth tab lets you filter by game data. Set a time frame and one or more specific stages.

![stage filter](images/filter-stage.png)
