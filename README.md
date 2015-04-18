# What is it

`redmine-eye` is a library and tool for interacting with Redmine.

# Setup

```bash
npm install -g redmine-eye
```

# Configurate

On first start from command line `redmine-eye` will ask requred configuration params.
They may be changed later with `ry conf NAME VALUE` command.

| param | description | required |
|:---------:|:---------|:--------------|
| `host`    | Redmine server  | yes      |
| `port`    | Redmine server port | yes |
| `api_key` | user API key | yes |
| `check_sert` | check https sertificate | no |


To show all config params execute

```bash
ry conf
```

If you use self-signed sertificate on Redmine server set `check_cert`  to `"no"`, :

```bash
ry conf check_cert no
```

# [Command Line Interface](CLI.md)

Use command line interface for access all library tools from console.

# Library usage examples 

Before start use library you should initialize it with code:

```coffee
Rapi = require "./redmine-api"
nconf.use "memory"
nconf.set "host", "https://redmine.example.com"
nconf.set "port", "80"
nconf.set "api_key", "my-redmine-api-key-here"

api = new Rapi nconf

```

###  `getCurrentUser`

Get current user data

```coffee
api.getCurrentUser (err, resp) ->

```

### `getProjects`

Get user projects data

### `getIssues`

Get issues data

### `createIssue`

Create new issue (beta)

### `getProjectUsers`

Get users involved in project

### `getUsers`

Get all users from server

This method not works for me

### `getVersions`

Get project versions

### `getTimeEntries`

Get time entries for issue

### `getIssueStatuses`

Get list of issue statuses

### `getTrackers`

Get list of trackers

### `getProjectStat`

Calculate project statistics

### `getUserStat`

Calculate statistics for users inside project



# Licence

The MIT License (MIT)

Copyright (c) 2015 Kirill Temnov

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.






