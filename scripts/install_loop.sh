#!/bin/bash
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

composer_install () {
  case $DB_TYPE in
    "mysql")
      echo MySQL;
      if [[ ! -v DB_HOST ]]; then export DB_HOST="localhost"; fi;
      ;;
    "sqlite")
      echo SQLite;
      ;;
    "pgsql")
      echo PgSQL;
      if [[ ! -v DB_HOST ]]; then export DB_HOST="/var/run/postgresql"; fi;
      if [[ ! -v DB_PORT ]]; then export DB_PORT=5432; fi;
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

  composer create-project --no-install --stability dev --no-interaction drupal-composer/drupal-project $DRUPAL_PROJECT_DIR $SKELETON_VERSION

  if [[ -v $DRUPAL_PROJECT_DIR ]]; then cd $DRUPAL_PROJECT_DIR; else cd drupal-project; fi;
  ls /run/user
  install --directory /run/user/1000/drupal-project # TODO tmpdir drwx
  install --directory web/sites/default
  pushd web/sites/default; ln -s /run/user/1000/drupal-project files; popd

  export PATH=$(pwd)/vendor/bin:$PATH

  if [[ -v DRUPAL_VERSION ]]; then
    composer -vv require --no-update drupal/core:$DRUPAL_VERSION;
  fi

  composer install
  command -v drupal
  command -v drush
  drupal check
}

site_install () {
  drupal site:install $PROFILE --yes --no-interaction --verbose \
  --langcode=$LANGCODE \
  --db-type=$DB_TYPE \
  --db-host=$DB_HOST \
  --db-port=$DB_PORT \
  --db-name=$USER \
  --db-user=$USER \
  --db-pass="" \
  --site-name="Project Only" \
  --site-mail="admin@example.com" \
  --account-name="admin" \
  --account-mail="admin@example.com" \
  --account-pass="admin" \
  $@

}

site_install0 () { drupal site:install $PROFILE --yes --no-interaction --verbose --langcode=$LANGCODE --db-type=$DB_TYPE; }

test_script () {
  for profile in minimal standard; do
    for langcode in en fr; do
      export PROFILE=$profile
      export LANGCODE=$langcode
      echo $PROFILE $LANGCODE $DB_TYPE
      drupal database:drop --no-interaction || true
      if ls web/sites/default/files/.ht.sqlite; then rm web/sites/default/files/.ht.sqlite; fi
      if ls web/sites/default/settings.php; then
        chmod u+w web/sites/default
        rm -f web/sites/default/settings.php
      fi

      site_install0;
      drush core:status
      drush core:requirements
    done;
  done
}
