# Command line tool

```
ry command opts
```

Commands shown below

## projecs

Show list of projects. No options.

## log

Show log for issues

If no options provided, last issues will shown.

### Options

`pid` - project id


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

