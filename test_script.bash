#!/bin/bash
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

site_install () { drupal site:install $PROFILE --yes --no-interaction --verbose --langcode=$LANGCODE --db-type=$DB_TYPE --db-host=$DB_HOST --db-port=$DB_PORT --db-user=$USER; }

case $DB_TYPE in
  "mysql")
    echo MySQL;
    if [[ ! -v DB_HOST ]]; then export DB_HOST="localhost"; fi;
    echo DB_HOST=$DB_HOST
    ;;
  "sqlite")
    echo SQLite;
    ;;
  "pgsql")
    echo PgSQL;
    if [[ ! -v DB_HOST ]]; then export DB_HOST="/var/run/postgresql"; fi;
    echo DB_HOST=$DB_HOST
    if [[ ! -v DB_PORT ]]; then export DB_PORT=5432; fi;
    echo DB_PORT=$DB_PORT
    if command -v psql ; then psql --host=$DB_HOST --port=$DB_PORT --command="\l"; fi
    ;;
  "")
    echo Please choose a DB_TYPE in mysql sqlite pgsql;
    echo eg.: 
    echo env DB_TYPE=sqlite ...
    exit;
    ;;
  *)
    echo Unknown DB_TYPE;
    echo $DB_TYPE
    exit;
    ;;
esac

for profile in minimal standard; do
  for langcode in en fr; do
    export PROFILE=$profile
    export LANGCODE=$langcode
    echo $PROFILE $LANGCODE $DB_TYPE

    time site_install
    drush core:status
    drush core:requirements
    drupal server --yes --no-interaction --learning & printf 'HEAD / HTTP/1.1\r\n\r\n' | socat - TCP4:localhost:8088,forever # Waiting for server to connect.
    elinks http://localhost:8088/ -dump-color-mode 4 -dump
    # - elinks http://localhost:8088/core/install.php?langcode=en -dump-color-mode 4 -dump

    drupal database:drop --no-interaction || true
    if ls web/sites/default/files/.ht.sqlite; then
      df --print-type web/sites/default/files/.ht.sqlite
      pushd web/sites/default/files; du -sch $(ls -A); popd # .ht.sqlite size
      # rm web/sites/default/files/.ht.sqlite; # Does not work because used by server
      cat <<- EOM | sqlite3 web/sites/default/files/.ht.sqlite
        PRAGMA writable_schema = 1;
        delete from sqlite_master where type in ('table', 'index', 'trigger');
        PRAGMA writable_schema = 0;
        VACUUM;
        PRAGMA INTEGRITY_CHECK;
EOM
    fi
    if ls web/sites/default/settings.php; then
      chmod u+w web/sites/default
      rm -f web/sites/default/settings.php
    fi
  done;
done
