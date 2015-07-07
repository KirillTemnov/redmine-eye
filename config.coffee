# redmine-eye configuration
#
# Configuration options
#
# :host - redmine host
# :port - redmine host port
# :api_key - key for sending requests
# :pid - default project id
# :
#

# coffeelint: disable=max_line_length, enable=colon_assignment_spacing

nconf         = require "nconf"
readline      = require "readline-sync"

{RedmineAPI}  = require "./redmine-api"

home          = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE

nconf.use "file", file: "#{home}/.redmine-eye"
nconf.load()

# TODO check host and port !

#
# Public: Setup minimal requrements
#
#
module.exports.setup = setup = ->


  host = nconf.get "host"
  port = nconf.get "port"
  api_key = nconf.get "api_key"
  # TODO add locale here

  need_test = not (host and port and api_key)

  while not host
    host = readline.question("Redmine host : ")
    nconf.set "host", host
  while not port
    port = readline.question("Redmine host port [80] : ") or "80"
    nconf.set "port", port
  while not api_key
    api_key = readline.question("Your api key : ")
    nconf.set "api_key", api_key
  if need_test
    try
      api = new RedmineAPI nconf
      api.getCurrentUser (err, resp) ->
        if err
          console.error "Error calling Redmine api. Check api_key."
        else
          nconf.save (err) ->
            if err
              console.error "error on saving configuration: #{JSON.stringify err, null, 2}"
            else
              console.log "configuration saved"

    catch
      console.log "error testing api. check host, port, api_key and retry"
    return no

  yes

module.exports.config = nconf
