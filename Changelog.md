# v1.0.0 (pending)

 - move formatting functions to separate modules
 - add mock data for testing
 - add tests
 - fast issues update (close, comment, feedback, change priority)
 - add `info` command (issue full info)
 - update `time` command (for work like `watch`)
 - add `alias` command
 - update readme, add more samples
 - fix localization issues
 - add star command for watching issues (text search inside starred issues, obsolescence, etc.)

# v0.8.0

 - improve log command - make issues like tables
 - store done, closed, and process issue status ids in config (`processStatuses`, `closeStatuses`, `doneStatuses`)
 - add `teams` and `team` commands (group peoples)
 - add `watch` command
 - add `today` value for option `spent_on` in `time` command
 - fix user typos `spend_on` -> `spent_on`
 - add `--week` option (shortcut for `--period week`)
 - add `--today` option (shortcut for `--spent_on today`)
 - update `team` command `list` option - print **user names** and ids.
 - add options to `watch` command:
   - `--nocolor` - dump without color (useful for piping)
   - `--closed`  - show only closed issues (Buggy. for closed over 100 gives duplicates at end)
   - `--all`     - show all issues (will pull over and over until hangover)
 - add `admin` option in config


# v0.7.6

 - imporve `time` command - entries sorted by user id and printed by block
 - extend period command - add integer for days

# v0.7.5

 - add `time` command to CLI (get work time)
 - pick up language from environment

# v0.7.2

 - add options for fetching more than 25 projects
