#
# Public: Redmine API wrapper
#
#

# coffeelint: disable=max_line_length, enable=colon_assignment_spacing

fs       = require "fs"
colors   = require "colors"
request  = require "request"
locale   = require("./locale").m
if /ru_RU/.test process.env.LANG
  loc    = locale.ru
else
  loc    = locale.en


#
# Internal: duplicate symbol
#
# :sym - symbol to duplicate
# :times - times to duplicate
# :return duplicated string
#
dup = (sym="#", times=10) ->
  if times > 0
    ([1..times].map -> sym).join ""
  else
    ""

#
# Public: Extends (oh my god!) Date object
#
#
Date::pretty_string = ->
  zero_pad = (x) -> if x < 10 then '0'+x else ''+x
  d = zero_pad(@getDate())
  m = zero_pad(@getMonth() + 1)
  y = @getFullYear()
  "#{y}-#{m}-#{d}"


#
# Internal: normalize value and max value to chars
#
#
normalize = (val, maxVal, maxChars) ->
  persent = val/maxVal
  Math.round persent * maxChars

#
# Internal: Insert symbols from right of specified string
#
#
padRight = (str, length, symbol=" ") ->
  str = str.toString()
  restLen = length - str.length
  if restLen < 0
    str[0...length-2] + ".."
  else
    str + dup symbol, restLen

#
# Internal: Insert symbols from left and right of specified string
#
#
padCenter = (str, length, symbol=" ") ->
  str = str.toString()
  restLen = length - str.length
  if restLen < 0
    str[0...length-2] + ".."
  else
    if 0 is restLen % 2
      l1 = l2 = restLen / 2
    else
      l1 = l2 = parseInt restLen / 2
      l2++
    "#{dup symbol, l1}#{str}#{dup symbol, l2}"



#
# Public: Copy arguments from command line
#
# :argv - optimist arguments
# :exclude - array of excluded keys
# :transforms - key transforms (e.g. {pid: "project_id"})
#
# :returns object with rest of keys
#
module.exports.copyArgv = (argv, exclude=["_", "$0"], transforms={pid:"project_id"}) ->
  args = {}
  for k,v of argv
    continue if k in exclude
    if transforms[k]?
      args[transforms[k]] = v
    else
      args[k] = v
  args


#
# Colorize text by ratio
#
# :text   - text to colorize
# :ratio  - ratio for colorize text (from 0.00 to 1.00)
#
colorize_ratio = (text, ratio) ->
  return switch
    when 0 >= ratio then text.grey
    when 0 < ratio < 0.2    then text.red
    when 0.2 <= ratio < 0.5 then text.yellow
    when 0.5 <= ratio < 0.8 then text.cyan
    when 0.8 <= ratio       then text.green.bold
    else text

#
# Public: Print project statuses statistics to console
#
# :err                  - error, don't console.log anything
# :fetched_objects      - dictionary with data
#   :statuses.trackers  - issues statuses
#   :users              - users tasks statistics
#
module.exports.PRINT_PROJECT_STATS = PRINT_PROJECT_STATS = (err, fetched_objects, chars_max=80) ->
  if err
    return console.error loc.error_fetching_issues.red

  for k1,tracker of fetched_objects.statuses.trackers
    console.log "\n\n#{k1.toUpperCase()}\n#{dup('=', 105)}"
    maxVal = -1
    for k,v of tracker
      maxVal = v if maxVal < v

    for k,v of tracker
      console.log "| #{padRight k, 14} | #{padRight v.toString(), 3} | #{dup('#', normalize(v, maxVal, chars_max))}"
  console.log "\n\n"


#
# Public: Print users stats by project to console
#
#
module.exports.PRINT_USERS_STAT = PRINT_USERS_STAT = (err, fetched_objects, opts={}) ->
  if err
    return console.error loc.error_fetching_issues.red

  # first of all sort users:
  users = []
  for k,v of fetched_objects.users
    users.push v

  users = switch opts.sort
    when "name"
      users.sort (a,b) -> a.name > b.name and 1 or -1
    when "created"
      users.sort (a,b) -> a.created_tasks.length < b.created_tasks.length and 1 or -1
    when "work"
      users.sort (a,b) -> a.in_process_tasks.length < b.in_process_tasks.length and 1 or -1
    when "closed"
      users.sort (a,b) ->
        if a.closed_to_must_be is b.closed_to_must_be
          a.closed_tasks.length < b.closed_tasks.length and 1 or -1
        else
          a.closed_to_must_be < b.closed_to_must_be and 1 or -1
    when "done"
      users.sort (a,b) ->
        if a.done_assigned is b.done_assigned
          a.done_tasks.length < b.done_tasks.length and 1 or -1
        else
          a.done_assigned < b.done_assigned and 1 or -1


  chars_max = opts.chars_max || 80
  console.log "\n\n"
  console.log "| #{padRight loc.user, 30} | #{padRight loc.created, 8} | #{padRight loc.working_on, 8} | #{padRight loc.closed_from, 20} | #{padRight loc.ready_from, 20} |"
  console.log dup "=", 102
  for v in users

    # user name
    user_name   = "#{padRight v.name, 30}"

    # created tasks
    created    = "#{padRight v.created_tasks.length.toString(), 8}"
    if 0 is v.created_tasks.length
      created = created.grey
    else if 9 < v.created_tasks.length
      created = created.bold

    # in proccess tasks
    in_process  = "#{padRight v.in_process_tasks.length.toString(), 8}"
    switch v.in_process_tasks.length
      when 0
        in_process = in_process.grey
      when 1
        in_process = in_process.green
      when 2
        in_process = in_process.yellow
      else
        in_process = in_process.red


    closed_must_be = padRight "#{v.closed_tasks.length}/#{v.must_be_closed.length}", 10
    ratio = v.closed_to_must_be
    closed_must_be += "#{(100 * ratio).toFixed 2}%"
    closed_must_be = "#{padRight closed_must_be, 20}"

    closed_must_be = colorize_ratio closed_must_be, ratio


    done_assigned = padRight "#{v.done_tasks.length}/#{v.assigned_tasks.length}", 10
    ratio = v.done_assigned
    done_assigned += "#{(100 * ratio).toFixed 2}%"
    done_assigned = "#{padRight done_assigned, 20}"

    done_assigned = colorize_ratio done_assigned, ratio


    result = [
        "| #{user_name}"
        created
        in_process
        closed_must_be
        "#{done_assigned} |"
        ]

    console.log result.join " | "

  console.log dup "=", 102
  console.log "\n"


#
# Public: POST request wrapper
#
#
module.exports.POST = POST = (url, config, data, fn) ->
  if "function" is typeof data
    [fn, data] = [data, {}]

  url = "#{config.get('host')}:#{config.get('port')}/#{url}"

  # if 0 < r.length
  #   if -1 is url.indexOf "?"
  #     url += "?"
  #   else if "&" isnt url[-1..]
  #     url += "&"

  #   url += r.join "&"

  console.log "posting: " + JSON.stringify {url: url, json: data, headers: "X-Redmine-API-Key": config.get "api_key"}, null, 2
  #return

  request.post {url: url, json: data, headers: "X-Redmine-API-Key": config.get "api_key"}, (err, resp, body) ->
    if err
      return fn err, resp, body
    if resp.statusCode is 200
      return fn null, resp, body

    fn err or status: resp.statusCode, resp, body



#
# Public: Get request wrapper
#
#
module.exports.GET = GET = (url, config, opts, fn) ->

  if "function" is typeof opts
    [fn, opts] = [opts, {}]

  url = "#{config.get('host')}:#{config.get('port')}/#{url}"
  r = []
  for k,v of opts
    unless k in ["pid"]
      r.push "#{k}=#{v}"

  if 0 < r.length
    if -1 is url.indexOf "?"
      url += "?"
    else if "&" isnt url[-1..]
      url += "&"

    url += r.join "&"

  request {url: url, headers: "X-Redmine-API-Key": config.get "api_key"}, (err, resp, body) ->
    if err
      return err
    if resp.statusCode is 200
      return fn null, resp, body

    fn err or status: resp.statusCode, resp, body

#
# Public: Dump statuses
#
#
module.exports.DUMP_STATUSES = DUMP_STATUSES = (err, resp, body) ->
  if null is err
    body = JSON.parse body
    console.log "|  ID  | #{padRight loc.statuses_name, 30} | #{padRight loc.statuses_is_default, 12}  |  #{padRight loc.statuses_is_closed, 10} |"
    console.log dup "=", 71
    for s in body.issue_statuses
      str = ["| #{padCenter s.id, 4} | #{padRight s.name, 30} | "]
      str.push " #{padCenter (if s.is_default then 'V' else ' '), 12} | "
      str.push " #{padCenter (if s.is_closed then 'V' else ' '), 10} |"
      console.log str.join ""
    console.log dup "=", 71
  else
    console.error err

#
# Public: Dump body of request
#
#
module.exports.DUMP_JSON_BODY = DUMP_JSON_BODY = (err, resp, body) ->
  console.log "#{loc.calling}: #{resp.request.method}\t#{resp.request.uri.href}"
  if err is null
    body = JSON.parse body
    console.log JSON.stringify body, null, 2
  else
    console.error "#{resp.request.method}\t#{resp.request.uri.href}"
    console.error err


#
# Public: Dump users
#
#
module.exports.DUMP_USERS = DUMP_USERS = (err, resp, body) ->
  console.log ""

  if err is null
    body = JSON.parse body
    console.log dup "=", 41
    for u in body.users
      console.log "| #{padRight u.id.toString(), 4} | #{padRight u.firstname + ' ' + u.lastname, 30} |"
    console.log dup "=", 41
  else
    console.error "#{resp.request.method}\t#{resp.request.uri.href}"
    console.error err
  console.log ""



#
# Public: Dump projects from request
#
#
module.exports.DUMP_PROJECTS = DUMP_PROJECTS = (err, resp, body) ->
  if err
    console.error "#{resp.request.method}\t#{resp.request.uri.href}"
    console.error err
  else
    prj =  JSON.parse body
    for p in prj.projects       # TODO make nicer
      console.log "#{p.id}\t\t#{p.name}"


#
# Public: Dump json data co console
#
module.exports.DUMP_JSON = DUMP_JSON = (err, jsonData) ->
  return if err
  console.log "#{JSON.stringify jsonData, null, 2}"


#
# Public: Dump issues from request
#
module.exports.DUMP_ISSUES = DUMP_ISSUES = (err, issues) ->
  return if err

  #
  # Make short representation of author string
  #
  #
  formatAuthor = (author) ->
    str = author.split " "
    if 2 <= str.length
      str[0][0..3] + " " + str[1][0] + "."
    else
      padRight str[0][0..5], 7

  console.log dup "=", 140
  for i in issues
    s = ["| #{padCenter i.id, 6}/#{i.status.id} |"]
    s.push " #{i.tracker.name[0]}"
    s.push " #{i.status.name[0]} |"
    who = "#{formatAuthor i.author.name} ⇒ #{i.assigned_to? and formatAuthor(i.assigned_to.name) or 'nil'}"
    s.push " #{padRight who, 18} |"
    s.push " #{padRight i.subject, 100} |"
    console.log s.join ""
  console.log dup "=", 140
  console.log ""


#
# Public: Dump user issues, sorted by priority
#
#
module.exports.DUMP_USER_SORTED_ISSUES = DUMP_USER_SORTED_ISSUES = (err, issues) ->
  if err
    console.error "Error: #{JSON.stringify err, null, 2}"
    return

  if 0 < issues.length
    console.log "#{issues[0].assigned_to.name}".bold + " [ #{issues[0].assigned_to.id} ]".grey
    console.log dup "_", 120
  else
    return console.log "no records" # TODO add localization

  applyColor = (p, str) ->
    switch p
      when 1
        str.blue
      when 2
        str.green
      when 3
        str.yellow
      when 4
        str.red
      when 5
        str.white.bgRed.bold

  issues = issues.sort (a,b) -> b.priority.id - a.priority.id
  for i in issues
    s = [i.id]
    s.push padRight i.status.name, 10
    s.push padRight i.subject, 100
    console.log applyColor i.priority.id, s.join " | "
  console.log ""

#
# Public: Dump time entries
#
#
module.exports.DUMP_TIME_ENTRIES = DUMP_TIME_ENTRIES = (err, time_entries) ->
  if err
    console.error "#{resp.request.method}\t#{resp.request.uri.href}"
    console.error err
  else
    global_total = 0
    total = 0
    console.log dup "-", 112
    last_usr = ""
    console.log "| #{padCenter loc.time, 8} | #{padRight loc.user, 30} | #{padRight loc.date, 10} | #{padRight loc.issue, 8} | #{padRight loc.project, 40} |"
    console.log dup "-", 112
    for t in time_entries
      usr = "#{t.user.name} [#{t.user.id}]"
      unless usr is last_usr
        last_usr = usr
        if 0 < total
          console.log dup "-", 112
          console.log "| #{padRight total.toFixed(2), 8} | #{padRight loc.total_hours, 97} |"
          console.log dup "-", 112
        global_total += total
        total = 0

      console.log "| #{padRight t.hours.toFixed(2), 8} | #{padRight usr, 30} | #{t.spent_on} | #{padRight t.issue.id.toString(), 8} | #{padRight t.project.name, 40} |"
      total += t.hours

    global_total += total
    console.log dup "-", 112
    console.log "| #{padRight total.toFixed(2), 8} | #{padRight loc.total_hours, 97} |"
    console.log dup "-", 112
    console.log ""
    console.log "#{loc.total_hours.bold} : #{global_total.toFixed 2}"
    console.log ""


#
# Public: Basic redmine api calls
#
class RedmineAPI

  #
  # Public: Constructor
  #
  constructor: (@config) ->
    if "no" is @config.get "check_cert"
      process.env.NODE_TLS_REJECT_UNAUTHORIZED = "0";

    @fetched_objects = {}       # fetched objects dict [for multiple call]
    @end_of_call = false        # end of transaction call
    @iter = 0                   # iteration number - for debug

  #
  # Public: Get projects, accesible to users
  #
  getProjects: (opts={}, fn=DUMP_PROJECTS) ->
    GET "projects.json", @config, opts, fn



  #
  # Public: get issues for project
  #
  #
  getIssues: (opts={}, fn=DUMP_ISSUES) ->
    processIssues = (err, current_issues) =>
      if err
        return fn err

      @iter++
      @fetched_objects.issues ||= {}

      for i in current_issues
        @fetched_objects.issues[i.id] = i

      # reach bottom
      if (err?.status? and 404 is err.status) or ((opts.limit or 100) > current_issues.length)
        @end_of_call = yes


      if @end_of_call
        issues = []
        for k, v of @fetched_objects.issues
          issues.push v
        @fetched_objects.issues = issues

        return fn null, @fetched_objects.issues
      else
        opts.limit  ||= 100
        opts.offset ||= 0
        opts.offset += opts.limit
        @getIssues opts, processIssues


    #pid = opts.pid || config.pid
    if opts.all
      fake_opts = {}
      for k,v of opts
        unless k in ["all", "pid"]
          fake_opts[k] = v
        if fake_opts.offset
          fake_opts.offset += 100
        else
          fake_opts.offset = 0
        fake_opts.limit ||= 100

      @end_of_call = false #if 0 is o.offset
      @getIssues fake_opts, processIssues

    else
      GET "issues.json", @config, opts, (err, resp, body) ->
        if err
          console.error "#{resp.request.method}\t#{resp.request.uri.href}"
          console.error err
          fn err
        else
          fn null, JSON.parse(body).issues

  #
  # Public: Create new issue
  #
  # requred opts:
  # :project_id    - project id
  # :to            - who to assign
  # :t             - tracker
  # optional:
  # :p             - priority
  # :parent_issue_id
  #
  createIssue: (opts={}, subject, fn=->) ->
    if ! (opts.project_id and opts.to and opts.t)
      return console.error loc.required_params_missing.red
    queryOpts =
      project_id  : opts.project_id
      status_id   : 1 # hardcode status id
      priority_id : opts.p or 1

    @getProjectUsers project_id: opts.project_id, (err) =>

      if err
        return console.error "#{loc.error_fetching_user}: #{JSON.stringify user, null, 2}".red
      for k,v of @fetched_objects.users
        if 0 <= v.toLowerCase().indexOf opts.to.toLowerCase()
          queryOpts.assigned_to_id = parseInt k
          break
      unless queryOpts.assigned_to_id
        return console.error "Error. User #{opts.to.red} not found"
      @getTrackers {}, (err, result) =>
        if err
          return console.error loc.error_fetching_trackers.red

        tr = JSON.parse result.body
        for track in tr.trackers
          if 0 <= track.name.toLowerCase().indexOf opts.t.toLowerCase()
            queryOpts.tracker_id = track.id
            break
        unless queryOpts.tracker_id
          return console.error "Error. Track #{opts.t.red} not found"

        if opts.vID?
          queryOpts.fixed_version_id = parseInt opts.vID

        queryOpts.subject = subject # todo: make this code nicer!
        POST "issues.json", @config, issue: queryOpts, (err, resp, body) ->
          if err
            console.error "#{loc.error}: #{JSON.stringify err, null, 2}"
            return
          console.log JSON.stringify resp, null, 2


  #
  # Public: Get project users by collecting all issues and fetch users
  #
  getProjectUsers: (opts={}, fn=DUMP_JSON) ->
    opts.all = yes
    opts.status_id = "*"        # I mean ALL
    @getIssues opts, (err, issues) =>
      if err
        console.error loc.error_fetching_issues.red
      else
        @fetched_objects.users = {}
        for i in issues
          if i.author?
            @fetched_objects.users[i.author.id] = i.author.name
          if i.assigned_to?
            @fetched_objects.users[i.assigned_to.id] = i.assigned_to.name

        fn null, @fetched_objects


  #
  #
  # Public: Get users (performed by admin!)
  #
  getUsers: (opts={}, fn=DUMP_USERS) ->
    GET "users.json", @config, opts, fn

  #
  # Public: Get current user data
  #
  #
  getCurrentUser: (fn=DUMP_JSON_BODY)->
    GET "users/current.json", @config, fn


  #
  # Public: Get project versions
  #
  #
  getVersions: (opts={}, fn=DUMP_JSON_BODY) ->
    #pid = opts.pid || config.pid
    GET "projects/#{opts.pid}/versions.json", @config, fn


  #
  # Public: Get time entries
  #
  #
  getTimeEntries: (opts={}, fn=DUMP_TIME_ENTRIES) ->
    dumpTimeEntries = (err, time_entries) ->
      if err
        fn err
      else
        time_entries = JSON.parse(time_entries).time_entries if "string" is typeof time_entries
        # sort by user id
        time_entries = time_entries.sort (a,b) -> a.user.id - b.user.id
        fn null, time_entries


    if opts.period?
      period = if "week" is opts.period then 7 else parseInt opts.period
      delete opts.period
      # set limit to 100 records and
      opts.limit = 100
      day = if opts.spent_on then new Date(opts.spent_on) else new Date

      delete opts.spent_on      # TODO this make works buggy on later dates
      days = []
      [0...period].map ->
        days.push day.pretty_string()
        day.setDate day.getDate() - 1

      GET "time_entries.json", @config, opts, (err, resp, body) ->
        if err
          console.error "#{resp.request.method}\t#{resp.request.uri.href}"
          console.error err
          dumpTimeEntries err
        else
          time_entries = JSON.parse(body).time_entries
          time_entries = time_entries.filter (te) -> te.spent_on in days
          dumpTimeEntries null, time_entries
    else
      GET "time_entries.json", @config, opts, (err, resp, body) ->
        dumpTimeEntries err, body

  #
  # Public: Get issues statuses
  #
  #
  getIssueStatuses: (opts={}, fn=DUMP_STATUSES) ->
    #pid = opts.pid || config.pid
    GET "/issue_statuses.json", @config, opts, fn

  #
  # Public: get trackers
  #
  #
  getTrackers: (opts={}, fn=DUMP_JSON_BODY) ->
    # pid = opts.pid || config.pid
    GET "/trackers.json", @config, opts, fn


  #
  # Public: Return true if issue is closed
  #
  #
  issueClosed: (issue) ->
    closeStatuses = (@config.get("closeStatuses") or "").toString().split(",").map (x) -> parseInt x
    issue.status.id in closeStatuses


  #
  # Public: Return true if issue is done
  #
  # TODO read id status from config.
  #
  issueDone: (issue) ->
    doneStatuses = (@config.get("doneStatuses") or  "").toString().split(",").map (x) -> parseInt x
    (100 is issue.done_ratio) or issue.status.id in doneStatuses

  #
  # Public: Issue in process
  #
  # TODO read id status from config.
  #
  issueInProcess: (issue) ->
    processStatuses = (@config.get("processStatuses") or "").toString().split(",").map (x) -> parseInt x
    issue.status.id in processStatuses

  #
  # Public: Get issues statistics by projects
  #
  getProjectStat: (opts={}, fn=PRINT_PROJECT_STATS) ->
    @_getProjectStat opts, fn


  #
  # Public: Get single user stat with time entries
  #
  getUserStat: (opts={}, fn=PRINT_USERS_STAT) ->
    @_getProjectStat opts, (err, data) =>
      return fn err if err
      user = null
      if opts.uid
        for k,v of @fetched_objects.users
          if k is opts.uid
            user = v
            break
      else if opts.name
        name = opts.name.toLowerCase()
        for k,v of @fetched_objects.users
          if v.name.indexOf name
            user = v
            break
      return fn err: "Add `uid` or `name` options." unless user

      console.log JSON.stringify user, null, 2



  #
  # Public: Get users statistics by projects
  #
  getUsersStat: (opts={}, fn=PRINT_USERS_STAT) ->
    @_getProjectStat opts, fn

  #
  # Internal: Get issues and users stat by projects
  #
  _getProjectStat: (opts={}, fn) ->
    opts.all = yes
    opts.status_id = "*"        # I mean ALL isuses

    # first, get all issues
    @getIssues opts, (err, issues) =>
      if err
        fn err, null
      else
        @fetched_objects.statuses = trackers: {}
        @fetched_objects.users = {}
        for i in issues
          # trackers
          @fetched_objects.statuses.trackers[i.tracker.name] ||= {}
          @fetched_objects.statuses.trackers[i.tracker.name][i.status.name] ||= 0
          @fetched_objects.statuses.trackers[i.tracker.name][i.status.name]++

          # users
          if i.author?
            @fetched_objects.users[i.author.id] ||= {}
            @fetched_objects.users[i.author.id].name = i.author.name
            @fetched_objects.users[i.author.id].created_tasks ||= []
            unless i.id in @fetched_objects.users[i.author.id].created_tasks
              @fetched_objects.users[i.author.id].created_tasks.push i.id

            @fetched_objects.users[i.author.id].closed_tasks ||= []
            @fetched_objects.users[i.author.id].must_be_closed ||= []

            if @issueClosed(i) and not (i.id in @fetched_objects.users[i.author.id].closed_tasks)
              @fetched_objects.users[i.author.id].closed_tasks.push i.id
            if @issueDone(i) and not (i.id in @fetched_objects.users[i.author.id].must_be_closed)
              @fetched_objects.users[i.author.id].must_be_closed.push i.id
          if i.assigned_to?
            @fetched_objects.users[i.assigned_to.id] ||= {}
            @fetched_objects.users[i.assigned_to.id].name = i.assigned_to.name
            @fetched_objects.users[i.assigned_to.id].assigned_tasks ||= []
            @fetched_objects.users[i.assigned_to.id].in_process_tasks ||= []

            if @issueInProcess i
              unless i.id in @fetched_objects.users[i.assigned_to.id].in_process_tasks
                @fetched_objects.users[i.assigned_to.id].in_process_tasks.push i.id


            unless i.id in @fetched_objects.users[i.assigned_to.id].assigned_tasks
              @fetched_objects.users[i.assigned_to.id].assigned_tasks.push i.id

            @fetched_objects.users[i.assigned_to.id].done_tasks ||= []
            if @issueDone(i) and not (i.id in @fetched_objects.users[i.assigned_to.id].done_tasks)
              @fetched_objects.users[i.assigned_to.id].done_tasks.push i.id

        for k,v of @fetched_objects.users # TODO refactor this
          v.created_tasks  ||= []
          v.assigned_tasks ||= []
          v.closed_tasks   ||= []
          v.must_be_closed ||= []
          v.done_tasks     ||= []
          v.in_process_tasks ||= []

          v.closed_to_must_be = v.closed_tasks.length / v.must_be_closed.length
          v.closed_to_must_be = 0 if isNaN v.closed_to_must_be

          v.done_assigned = v.done_tasks.length / v.assigned_tasks.length
          v.done_assigned = 0 if isNaN v.done_assigned

        fn null, @fetched_objects, opts, loc


module.exports.RedmineAPI = RedmineAPI
