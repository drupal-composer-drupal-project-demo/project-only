#!/bin/bash
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

source lib.bash

export PROFILE=standard
# export LANGCODE=... could be extracted from $LANG
export COMPOSER_NO_INTERACTION=1

# Initialize all the option variables.
# This ensures we are not contaminated by variables from the environment.
# http://mywiki.wooledge.org/BashFAQ/035
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
server_bypass=0
verbose=0

while :; do
    case $1 in
        -h|-\?|--help)
            show_help    # Display a usage synopsis.
            exit
            ;;
        -b|--server-bypass)
            server_bypass=1
            ;;
        -v|--verbose)
            verbose=$((verbose + 1))  # Each -v adds 1 to verbosity.
            ;;
        --)              # End of all options.
            shift
            break
            ;;
        -?*)
            printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
            ;;
        *)               # Default case: No more options, so break out of the loop.
            break
    esac

    shift
done

bash composer_create_drupal-project.bash
if [[ -v $DRUPAL_PROJECT_DIR ]]; then cd $DRUPAL_PROJECT_DIR; else cd drupal-project; fi;

exitfn () {
  trap SIGINT # Restore signal handling for SIGINT
  sleep .5 # To allow to interrupt cleanup
  drupal database:drop --no-interaction || true
  if ls web/sites/default/settings.php; then
    chmod u+w web/sites/default
    rm -f web/sites/default/settings.php
  fi
  if ls web/sites/default/files/.ht.sqlite; then
    readlink --canonicalize web/sites/default/files/.ht.sqlite
    df --print-type web/sites/default/files/.ht.sqlite
    pushd web/sites/default/files; du -sch .ht.sqlite; popd
    # rm web/sites/default/files/.ht.sqlite; # Does not work because used by server
    cat <<- EOM | sqlite3 -echo web/sites/default/files/.ht.sqlite
      PRAGMA writable_schema = 1;
      delete from sqlite_master where type in ('table', 'index', 'trigger');
      PRAGMA writable_schema = 0;
      VACUUM;
      PRAGMA INTEGRITY_CHECK;
EOM
    # https://stackoverflow.com/questions/525512/drop-all-tables-command
    if false; then db_target=$(readlink --canonicalize web/sites/default/files/.ht.sqlite); fi
    rm -rf $(dirname $(readlink --canonicalize web/sites/default/files/.ht.sqlite))
  fi
  exit
}

manage_db_parameters

export PROFILE=$profile
export LANGCODE=$langcode
echo $PROFILE $LANGCODE $DB_TYPE

time console_site_install
drush core:status
drush core:requirements

if [[ 0 -ne $server_bypass ]]; then
  echo Exit bypassing demo webserver
  exitfn
fi

trap "exitfn" INT
drupal server --learning # --yes --no-interaction
trap SIGINT

