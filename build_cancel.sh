#!/bin/bash

set -x

HEROKU_LOGIN_USER_DECODE=$(echo -n ${HEROKU_LOGIN_USER} | base64 -d)
HEROKU_API_KEY_DECODE=$(echo -n ${HEROKU_API_KEY_ENCODE} | base64 -d)

cat << __HEREDOC__ >> /app/.netrc
machine api.heroku.com
  login ${HEROKU_LOGIN_USER_DECODE}
  password ${HEROKU_API_KEY_DECODE}
machine git.heroku.com
  login ${HEROKU_LOGIN_USER_DECODE}
  password ${HEROKU_API_KEY_DECODE}
__HEREDOC__

cd heroku/bin
./heroku builds:cancel -a ${HEROKU_APP_NAME}
