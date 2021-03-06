# Command line tool

```
ry command opts
```

Commands shown below

## List projects (`projects`)

```
ry projects
```

By default redmine returns 25 projects (not documented). For access other projects use `--limit`/`--offset` options.

```
ry projects --limit 42
```

## Teams (`team`, `teams`)

Work with teams documented in [separate file](teams.md)


## Show statuses (`statuses`)

Show list of statuses with id

## Show issues (`log`)

Show log for issues

```
ry log
```

If no options provided, last issues will shown.

### Options

`pid` - project id


## Show spend time (`time`)


Show user and issue(s), project(s) and spended time

```
ry time [team/uid] [options]
```

### Team/uid

If team name is selected - show **first team member** time.

If uid and team missed, select time for `"me"`

### Options

| Option          | Description                                 |
|:---------------:|:--------------------------------------------|
| `limit`         | limit of records                            |
| `offset`        | offset, **may be buggy with period**        |
| `period`        | set to `week` for week report, or int (for number of days) |
| `spent_on`      | results on date (date format: "YYYY-MM-DD"  |


## Add watcher to issue (`aw`)

```
ry aw [uid/team] [tasks id list]
```

## stat

Show stat on project by users

### NOTE:

Before you start set config for issue states:

```bash
ry conf doneStatuses 4
ry conf closeStatuses 2,4,6
ry conf processStatuses 7,11
```

Get values for statuses from `ry statuses`


### Options

#### Sorting results (`sort`)

Sort resulst by

| value | description | note |
|:----------|:---------|:------------|
| `created` | sort by quantity of created tasks | default |
| `name`    | sort by user name         | |
| `work`    | sort by tasks, taken in work | |
| `closed`  | sort by closed tasks           | |
| `done`    | sort by done tasks        | |


## Create issue (`i`, `issue`)

create new task

ry issue --pid 111 -t ошибка -p 2 --to Петров --vID 123 Вставить кнопку в футер



### fields


## [teams](teams.md)


# Useful commands

## Show open issues of users in group

```bash
ry watch GROUP | grep id:
```

## Show total open issues in group

```bash
ry watch GROUP --nocolor | grep id: |  awk '{s+=$4} END {print s}'
```
