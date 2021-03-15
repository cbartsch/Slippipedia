# Slippipedia - Your flexible replay manager

This program can analyze a large number of Slippi replays and display detailed, filterable statistics and info.

![video](media/analytics.gif)

## Credits

* Slippi ([slippi.gg](https://slippi.gg))
* Slippc ([GitHub](https://github.com/pcrain/slippc)) - Slippi replay parser in C++
* Built with Felgo SDK ([felgo.com](https://felgo.com))
* Game sprites ripped on [spriters-resource.com](https://www.spriters-resource.com/gamecube/ssbm/) by [Mr C.](https://www.spriters-resource.com/submitter/Mr.+C/) and [Colton](https://www.spriters-resource.com/submitter/Colton/)

## Contact

Made by me (Chrisu). For feedback, bug reports, feature requests etc. use the issue tracker on this page or contact me via social media:

* Twitter - [ChrisuSSBMtG](https://twitter.com/ChrisuSSBMtG)

## How to Use

Download the latest release for your operating system. Start the included `.app` or the `.exe` file.

### Select replay folder

Select your Slippi replay directory. Per default, this should be in `(documents)/Slippi`. In this case, the folder should be pre-selected automatically.

![replay folder](images/replay-folder.png)

### Analyze replays

This step reads each replay and stores the relevant information in a database for fast lookup. 
Depending on your setup and the number of replays, this can take a few minutes.

Replays only need to be analyzed once. The database persists after app restarts.
When you have new replays or change the folder, you can choose to only analyze new replays.

![analyzing](images/analyzing.png)

### Set player filter

For more detailed output, like win rate and opponent stats, set your Slippi name and/or tag in the filter configuration.

![player filter](images/filter-player.png)

### Explore stats

Use the tabs to explore data about your replays. 

#### Statistics

Statistics shows global stats. 

First tab shows number of games, win rate, character usage (me/opponent), stage usage. 

Second tab shows detailed stats. 

Third tab shows player tags and codes. Click a code to show all games with or versus that specific player.

![stats](images/stats.png)

#### Analytics

Analytics groups stats by character, matchup, stage and time frame. 

Click the statistics icon to show statistics for a certain group. Click the list icon to show those games in the browser.

![analytics](images/analytics.png)

#### Browser

Browser lists the replays one by one. 

Click the play icon to can re-watch them (needs [Slippi Desktop app](https://github.com/project-slippi/slippi-desktop-app)). Click the folder icon to find a specific replay file on your file system.

Click the statistics icon for a session to show statistics pre-filtered for exactly those games.

![browser](images/browser.png)

### Filtering

Restrict your replays by detailed criteria. All other stats, analytics and browser consider the filter settings.

Navigate back to show filtered data.

#### Player and opponent filter

First tab lets configures the player filter. Set your Slippi name and/or tag to enable win rate, opponent data etc. You can also filter by one or more specific characters.

![player filter](images/filter-player-all.png)

Second tab lets you filter for specific opponents and characters.

#### Game result filter

Third tab lets you filter by game results. Set a min/max game duration, game outcom and remaining stocks. You can use this e.g. to filter short games that probably did not finish.

![result filter](images/filter-result.png)

#### Game filter

Fourth tab lets you filter by game data. Set a time frame and one or more specific stages.

![stage filter](images/filter-stage.png)
