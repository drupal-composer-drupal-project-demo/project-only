#!/bin/bash
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

. lib.bash

manage_db_parameters

for site_install in ${site_install_commands[*]}; do
# drush_site_install does not work with drush 9 on mysql and pgsql, sqlite woks fine.
  for profile in minimal standard; do
    for langcode in en fr; do
      export PROFILE=$profile
      export LANGCODE=$langcode
      echo $PROFILE $LANGCODE $DB_TYPE \($site_install\) $DB_URL

      time $site_install
      drush core:status
      drush core:requirements
      pwd
      ls --color
      pushd vendor ; pwd ; popd
      ls --color vendor
      pushd vendor/drupal ; pwd ; popd
      ls --color vendor/drupal
      pushd .. ; pwd ; popd
      ls --color ..
      find . -name core
      phpdbg -qrr vendor/bin/phpunit --configuration vendor/drupal/core --testsuite unit
      drupal server --yes --no-interaction --learning & printf 'HEAD / HTTP/1.1\r\n\r\n' | socat - TCP4:localhost:8088,forever # Waiting for server to connect.
      elinks http://localhost:8088/ -dump-color-mode 4 -dump
      # - elinks http://localhost:8088/core/install.php?langcode=en -dump-color-mode 4 -dump

      drupal database:drop --no-interaction || true
      if ls web/sites/default/files/.ht.sqlite; then
        readlink --canonicalize web/sites/default/files/.ht.sqlite
        df --print-type web/sites/default/files/.ht.sqlite
        pushd web/sites/default/files; du -sch .ht.sqlite; popd
        # rm web/sites/default/files/.ht.sqlite; # Does not work because used by server
        cat <<- EOM | sqlite3 web/sites/default/files/.ht.sqlite
          PRAGMA writable_schema = 1;
          delete from sqlite_master where type in ('table', 'index', 'trigger');
          PRAGMA writable_schema = 0;
          VACUUM;
          PRAGMA INTEGRITY_CHECK;
EOM
        # https://stackoverflow.com/questions/525512/drop-all-tables-command
      fi
      if ls web/sites/default/settings.php; then
        chmod u+w web/sites/default
        rm -f web/sites/default/settings.php
      fi
    done
  done
done
