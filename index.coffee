#!/usr/bin/env coffee

#
# Read data from config and make requests to redmine server
#
# 10.03.2015
# Kirill Temnov
#


usage = """
Usage: ry COMMAND [--debug] [--pid PROJECT_ID]

COMMANDS:
  projects      - list projects(--limit, --offset)
  log           - list of issues
  time          - work time
  issue         - create an issue
  issues        - batch create several issues
  ms            - list of milestones
  conf          - configuration
  project-stat  - statistics on project tasks
  stat          - statistics on project users
  statuses      - list of statuses
  user          - user stat in project
  help          - help on command
  team, teams   - manage teams
  watch         - filter tasks

"""
argv = require("optimist").usage(usage).argv

DEBUG_MODE = argv.debug

if 0 is argv._.length
  if argv.v
    pkg = require "./package.json"
    console.log pkg.name
    console.log "version: #{pkg.version}"
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
    config.save (err) ->
      if err
        console.error "error saving config"
      else
        console.log "#{argv._[1]}\t:\t#{argv._[2]}\nsaved."
  return


return unless setup()

#console.log "ARGV = #{JSON.stringify argv, null, 2}"

{copyArgv, DUMP_JSON_BODY, DUMP_JSON, DUMP_USER_SORTED_ISSUES, RedmineAPI} = require "./redmine-api"

api = new RedmineAPI config

ARGV = copyArgv argv

if "projects" in argv._
  if DEBUG_MODE
    api.getProjects ARGV, DUMP_JSON_BODY
  else
    api.getProjects ARGV
if "log" in argv._
  ARGV.status_id = "*"          # TODO watch this!
  if DEBUG_MODE
    api.getIssues ARGV, DUMP_JSON
  else
    api.getIssues ARGV

# watch my tasks
if "watch" in argv._
  argv._.shift()
  who = argv._           # list of users/groups
  ARGV.status_id       = "open"
  ARGV.limit         ||= 100

  who = ["me"] if 0 is who.length
  teams = config.get("teams") or {}

  for name in who
    userArgs = copyArgv ARGV

    # search team
    if teams[name]?
      for person_id in teams[name]
        teamUserArgs = copyArgv ARGV
        teamUserArgs.assigned_to_id = person_id
        api.getIssues teamUserArgs, DUMP_USER_SORTED_ISSUES
    else
      if name is "me"
        userArgs.assigned_to_id = "me"
      else if /^\d+$/.test name
        userArgs.assigned_to_id = name
      else
        continue
      api.getIssues userArgs, DUMP_USER_SORTED_ISSUES


if ("ms" in argv._) or ("versions" in argv._)
  if DEBUG_MODE
    api.getVersions pid: argv.pid, DUMP_JSON_BODY
  else
    api.getVersions pid: argv.pid

if ("time" in argv._)
  if DEBUG_MODE
    api.getTimeEntries ARGV, DUMP_JSON
  else
    api.getTimeEntries ARGV

if "users" in argv._
  #console.log "call users"
  api.getUsers ARGV
  #api.getProjectUsers ARGV


if "project-stat" in argv._
  api.getProjectStat ARGV

if "stat" in argv._
  unless ARGV.sort in ["name", "created", "work", "closed", "done"]
    ARGV.sort = "created"
  api.getUsersStat ARGV

if "user" in argv._
  api.getUserStat ARGV

if ("issue" in argv._) or ("i" in argv._)
  api.createIssue ARGV, argv._[1..].join " "

if "statuses" in argv._
  if DEBUG_MODE
    api.getIssueStatuses {}, DUMP_JSON_BODY
  else
    api.getIssueStatuses()

if "trackers" in argv._
  api.getTrackers ARGV



if "team" is argv._[0]
  [name, action, ids] = argv._[1..]

  teams = config.get("teams") or {}
  action ||= "list"
  switch action
    when "list"
      console.log teams[name]
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

if "teams" is argv._[0]
  for k,v of config.get("teams") or {}
    console.log k
