#
# Locale settings
#
#
#
# coffeelint: disable=max_line_length, enable=colon_assignment_spacing

messages = {}

messages.ru =
  user                    : "пользователь"
  created                 : "создано"
  working_on              : "в работе"
  closed_from             : "закрыто/из"
  ready_from              : "готово/из"
  calling                 : "вызов"
  time                    : "время"
  issue                   : "задача"
  date                    : "дата"
  comment                 : "комментарий"
  project                 : "проект"

  config_saved            : "Конфигурация сохранена"

  total_hours             : "всего часов"

  # prompts
  prompt_redmine_url     : "URL Redmine, начиная с http(s): "
  prompt_redmine_port    : "Порт Redmine  [80]: "
  prompt_api_key         : "Ваш ключ API: "

  # errors
  required_params_missing : "отсутствуют обязательные параметры"
  error_fetching_issues   : "ошибка при получении задач"
  error_fetching_user     : "ошибка при получении пользователей"
  error_fetching_trackers : "ошибка при получении трекеров"
  error                   : "ошибка"
  error_redmine_call_check_api : "Ошибка при вызове Redmine API. Проверьте параметр api_key."
  error_saving_configuration   : "Ошибка при сохранении конфигурации"
  error_testing_api            : "Ошибка при тестировании Redmine API. Проверьте url, port, api_key и попробуйте снова."

  # statuses
  statuses_name       : "название"
  statuses_is_default : "по умолчанию"
  statuses_is_closed  : "закрывает"
  hours               : "часы"


messages.en =
  user                    : "user"
  created                 : "created"
  working_on              : "work on"
  closed_from             : "closed/from"
  ready_from              : "ready/from"
  calling                 : "calling"
  time                    : "time"
  issue                   : "issue"
  date                    : "date"
  comment                 : "comment"
  project                 : "project"

  config_saved            : "Configuration saved"

  total_hours             : "total hours"

  # prompts
  prompt_redmine_url     : "Redmine url, starting from http(s): "
  prompt_redmine_port    : "Redmine post [80]: "
  prompt_api_key         : "Your API key: "

  # errors
  required_params_missing : "required params missing"
  error_fetching_issues   : "error fetched issues"
  error_fetching_user     : "error fetching user"
  error_fetching_trackers : "error fetching trackers"
  error                   : "error"
  error_redmine_call_check_api : "Error calling Redmine API. Check api_key parameter."
  error_saving_configuration   : "Error saving configuration"
  error_testing_api            : "Error testing API. Check url, port, api_key and retry."

  # statuses
  statuses_name       : "name"
  statuses_is_default : "default"
  statuses_is_closed  : "closed"
  hours               : "hours"

exports.m = messages