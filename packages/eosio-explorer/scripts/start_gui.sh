#!/usr/bin/env bash
set -o errexit

# cd into current directory
cd $( dirname "$0" )

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'

SCRIPTPATH="$( pwd -P )/../.."
GUI="$SCRIPTPATH/eosio-explorer"
ISDEV=false
CLEARBROWSERSTORAGE=false

# sourcing variable from config file
source ../config.file

# override config if there are any local config changes
if [ -f "../config.file.local" ]; then
  source ../config.file.local
fi

# check for arguments
for arg in $@
do
    case $arg in
      -dev|--develop)
        ISDEV=true
        ;;
      --clear-browser-storage)
        CLEARBROWSERSTORAGE=true
        ;;
  esac
done

echo " "
echo "=============================="
echo "STARTING APP"
echo "=============================="
if $ISDEV; then
  if $CLEARBROWSERSTORAGE; then
    # Set environment variable "REACT_APP_LAST_INIT_TIMESTAMP" at dev build to create a new timestamp in CRA development
    (cd $GUI && REACT_APP_LAST_INIT_TIMESTAMP=$(date +%s) PORT=$APP_DEV_PORT yarn start)
  else
    (cd $GUI && PORT=$APP_DEV_PORT yarn start)
  fi
else
  if [ "$(netstat -nat | grep $APP_SERVE_PORT | grep LISTEN)" ]; then
    echo "port $APP_SERVE_PORT is already open, you should try browsing http://localhost:$APP_SERVE_PORT if it doesnt work you may have to change the port in config file or release the port $APP_SERVE_PORT"
  else
    (cd $GUI && yarn serve)
  fi
fi
