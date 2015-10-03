#!/usr/bin/env coffee

#
# Read data from config and make requests to redmine server
#
# 10.03.2015
# Kirill Temnov
#

# coffeelint: disable=max_line_length, enable=colon_assignment_spacing

usage = """
Usage: ry COMMAND [--debug] [--pid PROJECT_ID]

COMMANDS:
  projects      - list projects(--limit, --offset)
  log           - list of issues
  time          - work time
  issue         - create an issue
  issues        - batch create several issues
  i             - info on issue
  ms            - list of milestones
  conf          - configuration
  project-stat  - statistics on project tasks
  stat          - statistics on project users
  statuses      - list of statuses
  user          - user stat in project
  help          - help on command
  team, teams   - manage teams
  watch         - filter tasks
  users         - list of redmine users (fetch all users only by admin)
  groups        - list of redmine groups
  star, unstar  - star or unstar issue
"""
argv = require("optimist").usage(usage).argv

DEBUG_MODE = argv.debug

if 0 is argv._.length
  if argv.v
    pkg = require "./package.json"
    console.log pkg.name
    console.log "version: #{pkg.version}"
    console.log "created with ☕ script"
    return
  else
    return console.log usage


{setup, config} = require "./config"

if "conf" in argv._
  if 1 is argv._.length
    for k, v of config.get()
      console.log "#{k}\t:\t#{v}"
  if 2 is argv._.length
    console.log config.get(argv._[1]) or "{not found}"
  if 3 is argv._.length
    if "del" is argv._[1]       # remove element
      config.clear argv._[2]
    else
      config.set argv._[1], argv._[2]
    config.save (err) ->        # todo move config saving in separate function
      if err
        console.error "error saving config"
      else
        console.log "#{argv._[1]}\t:\t#{argv._[2]}\nsaved."
  return


return unless setup()

#console.log "ARGV = #{JSON.stringify argv, null, 2}"

{copyArgv, padRight, dup, DUMP_JSON_BODY, DUMP_JSON, DUMP_USERS, DUMP_USER_SORTED_ISSUES, DUMP_USER_SORTED_ISSUES_NC, DUMP_ISSUE, RedmineAPI} = require "./redmine-api"

#--------------------------------------------------------------------------------

api = new RedmineAPI config

ARGV = copyArgv argv


if argv._[0] in ["star", "unstar"]
  cmd = argv._.shift()
  if "star" is cmd
    stars = config.get("stars") or {}
    subcmd = argv._[0]
    if "show" is subcmd
      console.log "todo show"
    else
      now = (new Date).getTime()
      for issue in argv._
        if /^\d+$/.test issue
          stars[issue] = now
      config.set "stars", stars
      config.save (err) ->
        if err
          console.error "error saving config"


  else
    console.log "implement unstar"
  return

if "projects" is argv._[0]
  ARGV.limit ||= 100
  if DEBUG_MODE
    api.getProjects ARGV, DUMP_JSON_BODY
  else
    api.getProjects ARGV
  return

# stelth mode
if "projects-info" is argv._[0]
  proceed_projects = 0
  ARGV.limit = 100
  console.log "fetch projects"
  api.getProjects ARGV, (err, resp, body) ->
    unless err
      body = JSON.parse body
      body.projects.map (p) ->
        opts = project_id: p.id, status_id: "open", all: yes
        newApi = new RedmineAPI config
        newApi.getIssues opts, (err, issues) ->
          unless err
            console.log "| #{padRight issues.length, 6} |  #{padRight p.name, 50}  | #{padRight p.identifier, 25} | "
      # todo add total count


if "log" is argv._[0]
  ARGV.status_id = "*"          # TODO watch this!
  if DEBUG_MODE
    api.getIssues ARGV, DUMP_JSON
  else
    api.getIssues ARGV
  return

# watch my tasks
if "watch" is argv._[0]
  fn = DUMP_USER_SORTED_ISSUES
  if argv["nocolor"]?
    fn = DUMP_USER_SORTED_ISSUES_NC
  if argv["closed"]?
    ARGV.status_id = "closed"
  if argv["all"]?
    ARGV.all       = yes

  argv._.shift()
  who               = argv._           # list of users/groups
  ARGV.status_id  ||= "open"
  ARGV.limit      ||= 100


  who               = ["me"] if 0 is who.length
  teams             = config.get("teams") or {}

  for name in who
    userArgs = copyArgv ARGV
    # search team
    if teams[name]?
      for person_id in teams[name]
        teamUserArgs                 = copyArgv ARGV
        teamUserArgs.assigned_to_id  = person_id
        # add extra creation instance for prevent broke counters
        api = new RedmineAPI config
        api.getIssues teamUserArgs, fn
    else
      if name is "me"
        userArgs.assigned_to_id      = "me"
      else if /^\d+$/.test name
        userArgs.assigned_to_id      = name
      else
        continue
      # add extra creation instance for prevent broke counters
      api = new RedmineAPI config
      api.getIssues userArgs, fn

  return

if argv._[0] in ["ms", "versions"]
  if DEBUG_MODE
    api.getVersions pid: argv.pid, DUMP_JSON_BODY
  else
    api.getVersions pid: argv.pid
  return

if "time" is argv._[0]
  if DEBUG_MODE
    api.getTimeEntries ARGV, DUMP_JSON
  else
    api.getTimeEntries ARGV
  return

if "users" is argv._[0]
  ARGV.limit ||= 100              # Lifehack
  if "yes" is config.get "admin"
    api.getUsers ARGV
  else
    unless ARGV["pid"] or ARGV["project_id"]
      console.error "You are not admin. Set `admin` option in config, or set `--pid` option".red # TODO add localization
    else
      api.getProjectUsers ARGV  # TODO change dump function
  return

if "groups" is argv._[0]
  api.getGroups ARGV
  return

if "project-stat" is argv._[0]
  api.getProjectStat ARGV
  return

if "stat" is argv._[0]
  unless ARGV.sort in ["name", "created", "work", "closed", "done"]
    ARGV.sort = "created"
  api.getUsersStat ARGV
  return

if "user" is argv._[0]
  api.getUserStat ARGV
  return

if "issue" is argv._[0]
  api.createIssue ARGV, argv._[1..].join " "
  return

if "i" is argv._[0]
  if 1 is argv._.length
    console.error "empty ussues list" # todo localization
    return


  for i in argv._[1..]
    if DEBUG_MODE
      api.getIssueInfo i, {}, DUMP_JSON_BODY
    else
      api.getIssueInfo i, {}, DUMP_ISSUE
  #api.getIssueInfo

if "statuses" is argv._[0]
  if DEBUG_MODE
    api.getIssueStatuses {}, DUMP_JSON_BODY
  else
    api.getIssueStatuses()
  return

if "trackers" is argv._[0]
  api.getTrackers ARGV
  return


if "team" is argv._[0]
  [name, action, ids] = argv._[1..]

  teams = config.get("teams") or {}
  action ||= "list"
  getNameAndId   = (id, name) -> "| #{padRight id, 4} | #{padRight name, 30} |"
  printNameAndID = (id, name) -> console.log getNameAndId id, name

  switch action
    when "list"
      console.log ""                 # TODO move this ugly peace of code somewhere
      if "yes" is config.get "admin" # show admin users
        ARGV.limit = 100
        api.getUsers ARGV, (err, resp, body) ->

          if err is null
            body = JSON.parse body
            console.log dup "=", 41
            for u in body.users
              if u.id.toString() in teams[name]
                printNameAndID "#{u.id}", "#{u.firstname} #{u.lastname}"


            if "me" in teams[name]
              api.getCurrentUser (err, resp, body) ->
                if err
                  console.log getNameAndId("me", "Can't fetch my name").red
                else
                  me = JSON.parse body
                  console.log getNameAndId("#{me.user.id}", "#{me.user.firstname} #{me.user.lastname}").bold
                  console.log dup "=", 41
                  console.log ""
            else
              console.log dup "=", 41
              console.log ""
          else
            console.error "#{resp.request.method}\t#{resp.request.uri.href}"
            console.error err

      else
        console.log dup "=", 41
        teams[name].map (id) -> printNameAndID id, "user ...."
        console.log dup "=", 41
        console.log ""
      return
    when "add"
      unless teams[name]?
        teams[name] = []

      ids.toString().split(",").map (id) ->
        return if not id or 0 is id.length
        unless id in teams[name]
          teams[name].push id
    when "remove", "rm"
      if teams[name]?
        rmMembers = ids.toString().split ","
        newTeam = []
        for i in teams[name]
          newTeam.push i unless i in rmMembers
        teams[name] = newTeam
        delete teams[name] if 0 is newTeam.length
    else
      return                    # don't save anything
  config.set "teams", teams
  config.save (err) ->
    if err
      console.error "error saving team"
    else
      console.log "team updated"
  return

if "teams" is argv._[0]
  for k,v of config.get("teams") or {}
    console.log k
  return
