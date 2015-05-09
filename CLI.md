# Command line tool

```
ry command opts
```

Commands shown below

## List projects

```
ry projects
```

By default redmine returns 25 projects (not documented). For access other projects use `--limit`/`--offset` options.

```
ry projects --limit 42
```




## log

Show log for issues

```
ry log
```

If no options provided, last issues will shown.

### Options

`pid` - project id


## List time


Show user and time

```
ry time [options]
```

### Options

| Option          | Description                                 |
|:---------------:|:--------------------------------------------|
| `limit`         | limit of records                            |
| `offset`        | offset, **may be buggy with period**        |
| `period`        | set to `week` for week report               |
| `spent_on`      | results on date (date format: "YYYY-MM-DD"  |
| `user_id`       | fetch results only by user                  |



## stat

Show stat on project by users

### Options

#### `sort`

Sort resulst by

| value | description | note |
|:----------|:---------|:------------|
| `created` | sort by quantity of created tasks | default |
| `name`    | sort by user name         | |
| `work`    | sort by tasks, taken in work | |
| `closed`  | sort by closed tasks           | |
| `done`    | sort by done tasks        | |


## i (issue)

create new task

ry issue --pid 111 -t ошибка -p 2 --to Петров --vID 123 Вставить кнопку в футер



### fields
