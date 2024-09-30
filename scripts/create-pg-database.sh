#!/bin/bash

# The Set Builtin: https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
set -e          # exit if error occurs (-e == enables, +e == disables)
set -u          # echo "$var" ; echo $? ==> exit code == 1
set -o pipefail # false | true ; echo $? ==> exit code == 1

################################################## command line arguments
function usage() {
  echo "Usage:"
  echo "  --db_hostname                 Set hostname to run postgres in docker"
  echo "  --db_port                     Set port to run postgres in docker"
  echo "  --db_user                     Set user to run postgres in docker"
  echo "  --db_password                 Set password to run postgres in docker"
  echo "  --db_dbname                   Set dbname to run postgres in docker"
  echo "  -v, --verbose                 Print shell input lines as they are read"
  echo "  -x, --trace                   Print a trace of simple commands"
  echo "  -h, --help                    Print this usage"
  echo ""
  exit 1
}
function print_start_script() {
    echo -e '\033[0;45m     Start script working: '$(basename "$0")'     \033[0m'
    echo "DateTime: `date '+%Y-%m-%d_%H:%M:%S.%3N'`"
}
function print_finish_script() {
    echo "DateTime: `date '+%Y-%m-%d_%H:%M:%S.%3N'`"
    echo -e '\033[0;45m     Finish script working: '$(basename "$0")'     \033[0m'
}
function print_error() {
    echo -e "\033[0;41m ERROR: $1 Script: '$(basename "$0")' \033[0;39m"
}
function print_variable() {
    echo -e "\033[47;2;23;180;33m     $2=\033[0m$1"
}
function verify_and_print() {
    if [ -z "$1" ]; then 
        local flag=$(echo "$2" | sed 's/ARG_/--/1'  | tr '[:upper:]' '[:lower:]')
        print_error "$flag is not set."
        exit 1
    fi
    print_variable "$1" "$2"
}
function get_verbose_trace() {
    local res=""
    if [ "$ARG_VERBOSE" == "true" ]; then res+=" --verbose"; fi; 
    if [ "$ARG_TRACE" == "true" ]; then res+=" --trace"; fi; 
    echo $res
}

# variables
ARG_DB_HOSTNAME=''
ARG_DB_PORT=''
ARG_DB_USER=''
ARG_DB_PASSWORD=''
ARG_DB_DBNAME=''
ARG_VERBOSE=false
ARG_TRACE=false

# parse params
while [[ $# -gt 0 ]]; do case $1 in
  --db_hostname) ARG_DB_HOSTNAME=$2; shift; shift;;
  --db_port) ARG_DB_PORT=$2; shift; shift;;
  --db_user) ARG_DB_USER=$2; shift; shift;;
  --db_password) ARG_DB_PASSWORD=$2; shift; shift;;
  --db_dbname) ARG_DB_DBNAME=$2; shift; shift;;
  -v|--verbose) ARG_VERBOSE=true; shift;;
  -x|--trace) ARG_TRACE=true; shift;;
  -h|--help) usage; shift;;
  *) print_error "Unknown parameter passed: $1."; exit 1; shift; shift;;
esac; done

# print
print_start_script

# verify_and_print
verify_and_print "$ARG_DB_HOSTNAME" "ARG_DB_HOSTNAME"
verify_and_print "$ARG_DB_PORT" "ARG_DB_PORT"
verify_and_print "$ARG_DB_USER" "ARG_DB_USER"
verify_and_print "$ARG_DB_PASSWORD" "ARG_DB_PASSWORD"
verify_and_print "$ARG_DB_DBNAME" "ARG_DB_DBNAME"
verify_and_print "$ARG_VERBOSE" "ARG_VERBOSE"
verify_and_print "$ARG_TRACE" "ARG_TRACE"

if [ "$ARG_VERBOSE" == "true" ]; then set -v; fi;
if [ "$ARG_TRACE" == "true" ]; then set -x; fi;

################################################## spaces
echo
echo
echo
echo

################################################## pakages
sudo apt-get install python-pip
# sudo apt remove -y --purge postgresql-*
sudo apt -y install postgresql

################################################## db
# create user and database
cd /tmp/
PAGER='' sudo -u postgres psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --command "\du;"
PAGER='' sudo -u postgres psql --set ON_ERROR_STOP=1 --single-transaction --echo-all <<EOF
DO \$\$
BEGIN 
    IF NOT EXISTS (SELECT 1 FROM pg_user WHERE usename = '$ARG_DB_USER') THEN
        CREATE USER $ARG_DB_USER WITH ENCRYPTED PASSWORD '$ARG_DB_PASSWORD'; 
    END IF; 
END \$\$;
EOF
PAGER='' sudo -u postgres psql --set ON_ERROR_STOP=1 --echo-all --command "SELECT pg_terminate_backend(pg_stat_activity.pid) FROM pg_stat_activity WHERE pg_stat_activity.datname = '$ARG_DB_DBNAME' AND pid <> pg_backend_pid();"
PAGER='' sudo -u postgres psql --set ON_ERROR_STOP=1 --echo-all --command "DROP DATABASE IF EXISTS $ARG_DB_DBNAME;"
PAGER='' sudo -u postgres psql --set ON_ERROR_STOP=1 --echo-all --command "CREATE DATABASE $ARG_DB_DBNAME WITH OWNER $ARG_DB_USER ENCODING 'UTF8';"
PAGER='' PGPASSWORD=$ARG_DB_PASSWORD psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_DB_HOSTNAME --port $ARG_DB_PORT --username $ARG_DB_USER --dbname $ARG_DB_DBNAME --command 'CREATE EXTENSION IF NOT EXISTS "uuid-ossp";'
PAGER='' PGPASSWORD=$ARG_DB_PASSWORD psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_DB_HOSTNAME --port $ARG_DB_PORT --username $ARG_DB_USER --dbname $ARG_DB_DBNAME --command "SELECT 1;"


################################################## finish
print_finish_script






