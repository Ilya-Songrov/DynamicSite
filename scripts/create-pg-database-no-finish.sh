#!/bin/bash

# The Set Builtin: https://www.gnu.org/software/bash/manual/bash.html#The-Set-Builtin
set -e          # exit if error occurs (-e == enables, +e == disables)
set -u          # echo "$var" ; echo $? ==> exit code == 1
set -o pipefail # false | true ; echo $? ==> exit code == 1

################################################## command line arguments
function usage() {
  echo "Usage:"
  echo "  --temp_dir                    Dir to save internal files."
  echo "  --prefix_pt                   Use prefix prod/test"
  echo "  --cdb_hostname                Set hostname to run postgres in docker"
  echo "  --cdb_port                    Set port to run postgres in docker"
  echo "  --cdb_user                    Set user to run postgres in docker"
  echo "  --cdb_password                Set password to run postgres in docker"
  echo "  --cdb_dbname                  Set dbname to run postgres in docker"
  echo "  --cdb_password_postgres       Set password for postgres user"
  echo "  --pgdata_dir                  Set pgdata dir. Optional parameter."
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
ARG_TEMP_DIR=''
ARG_PREFIX_PT=''
ARG_CDB_HOSTNAME=''
ARG_CDB_PORT=''
ARG_CDB_USER=''
ARG_CDB_PASSWORD=''
ARG_CDB_DBNAME=''
ARG_CDB_PASSWORD_POSTGRES=''
ARG_PGDATA_DIR=" "
ARG_VERBOSE=false
ARG_TRACE=false

# parse params
while [[ $# -gt 0 ]]; do case $1 in
  --temp_dir) ARG_TEMP_DIR=$2; shift; shift;;
  --prefix_pt) ARG_PREFIX_PT=$2; shift; shift;;
  --cdb_hostname) ARG_CDB_HOSTNAME=$2; shift; shift;;
  --cdb_port) ARG_CDB_PORT=$2; shift; shift;;
  --cdb_user) ARG_CDB_USER=$2; shift; shift;;
  --cdb_password) ARG_CDB_PASSWORD=$2; shift; shift;;
  --cdb_dbname) ARG_CDB_DBNAME=$2; shift; shift;;
  --cdb_password_postgres) ARG_CDB_PASSWORD_POSTGRES=$2; shift; shift;;
  --pgdata_dir) ARG_PGDATA_DIR=$2; shift; shift;;
  -v|--verbose) ARG_VERBOSE=true; shift;;
  -x|--trace) ARG_TRACE=true; shift;;
  -h|--help) usage; shift;;
  *) print_error "Unknown parameter passed: $1."; exit 1; shift; shift;;
esac; done

# print
print_start_script

# verify_and_print
verify_and_print "$ARG_TEMP_DIR" "ARG_TEMP_DIR"
verify_and_print "$ARG_PREFIX_PT" "ARG_PREFIX_PT"
verify_and_print "$ARG_CDB_HOSTNAME" "ARG_CDB_HOSTNAME"
verify_and_print "$ARG_CDB_PORT" "ARG_CDB_PORT"
verify_and_print "$ARG_CDB_USER" "ARG_CDB_USER"
verify_and_print "$ARG_CDB_PASSWORD" "ARG_CDB_PASSWORD"
verify_and_print "$ARG_CDB_DBNAME" "ARG_CDB_DBNAME"
verify_and_print "$ARG_CDB_PASSWORD_POSTGRES" "ARG_CDB_PASSWORD_POSTGRES"
verify_and_print "$ARG_PGDATA_DIR" "ARG_PGDATA_DIR"
verify_and_print "$ARG_VERBOSE" "ARG_VERBOSE"
verify_and_print "$ARG_TRACE" "ARG_TRACE"

if [ "$ARG_VERBOSE" == "true" ]; then set -v; fi;
if [ "$ARG_TRACE" == "true" ]; then set -x; fi;

################################################## spaces
echo
echo
echo
echo

################################################## check
if [ "$ARG_PREFIX_PT" == "prod" ]; then
    print_error "You cannot use this script in 'prod' mode."
    exit 1
fi

################################################## check
# do not run CDB if exist
set +e
sudo docker ps | grep "$ARG_PREFIX_PT-eg-postgres-server"
EXIT_STATUS=$?
echo "EXIT_STATUS: $EXIT_STATUS"
if [ $EXIT_STATUS -eq 0 ]; then
    echo "CDB is running."
    exit 0
fi
set -e

################################################## stoping all dockers
set +e
echo -e "\033[1;36m     Stoping all dockers:    \033[0m"
echo "Current DateTime: `date '+%Y-%m-%d_%H:%M:%S.%3N'`"
echo -e '\033[1;36m     Print docker ps before:    \033[0m'
sudo docker ps --all
echo -e '\033[1;36m     Stoping dockers:    \033[0m'
sudo docker stop $ARG_PREFIX_PT-eg-postgres-server
sudo docker rm -f $ARG_PREFIX_PT-eg-postgres-server
echo -e '\033[1;36m     Print docker ps after:    \033[0m'
sudo docker ps --all
set -e

################################################## postgresql
echo -e "\033[1;36m     Run $ARG_PREFIX_PT-eg-postgres-server:    \033[0m"
echo "Current DateTime: `date '+%Y-%m-%d_%H:%M:%S.%3N'`"
VOLUME_PARAM=$([ "$ARG_PGDATA_DIR" == " " ] && echo " " || echo "--volume $ARG_PGDATA_DIR:/folder-inside-docker/pgdata")
sudo docker run --detach --rm \
    --name $ARG_PREFIX_PT-eg-postgres-server \
    --network $ARG_PREFIX_PT-eg-docker-network \
    --publish $ARG_CDB_PORT:$ARG_CDB_PORT \
    --log-driver='json-file' \
    --log-opt='max-size=500m' \
    --log-opt='max-file=5' \
    -e POSTGRES_PASSWORD=$ARG_CDB_PASSWORD_POSTGRES \
    -e PGDATA=/folder-inside-docker/pgdata \
    -e PGPORT=$ARG_CDB_PORT \
    $VOLUME_PARAM \
        postgres:13.10

# wait
set +e
while true; do
    echo "Current DateTime in loop: `date '+%Y-%m-%d_%H:%M:%S.%3N'`"
    sleep 0.5
    PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --dbname postgres --command "\du"
    EXIT_STATUS=$?
    echo "EXIT_STATUS: $EXIT_STATUS"
    if [ $EXIT_STATUS -eq 0 ]; then
        echo "EXIT_STATUS: $EXIT_STATUS"
        break
    fi
done
set -e

################################################## create schema of CDB
# get list users
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --command "\du"
# get list all databases
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --command "\list"

# DROP DATABASE
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --dbname postgres --command "DROP DATABASE IF EXISTS $ARG_CDB_DBNAME;"

# CREATE ROLE
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --dbname postgres --command "DROP ROLE IF EXISTS $ARG_CDB_USER; CREATE USER $ARG_CDB_USER WITH ENCRYPTED PASSWORD '$ARG_CDB_PASSWORD'; ALTER USER $ARG_CDB_USER WITH SUPERUSER;"

# CREATE DATABASE
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --dbname postgres --command "CREATE DATABASE $ARG_CDB_DBNAME WITH OWNER $ARG_CDB_USER ENCODING 'UTF8';"

# change log_statement for database 
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --dbname postgres --command "ALTER DATABASE $ARG_CDB_DBNAME SET log_statement = 'all';"

# check
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username $ARG_CDB_USER --dbname $ARG_CDB_DBNAME --command "SELECT 1;"

# import dump
timedatectl
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username $ARG_CDB_USER --dbname $ARG_CDB_DBNAME < $ARG_TEMP_DIR/DB/$DB_NAME.sql
timedatectl

# check
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username $ARG_CDB_USER --dbname $ARG_CDB_DBNAME --command "SELECT 1;"

# get list users
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --command "\du"
# get list all databases
PAGER='' PGPASSWORD=$ARG_CDB_PASSWORD_POSTGRES psql --set ON_ERROR_STOP=1 --single-transaction --echo-all --host $ARG_CDB_HOSTNAME --port $ARG_CDB_PORT --username postgres --command "\list"

################################################## finish
print_finish_script






