#!/bin/bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

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
    echo eg. env DB_TYPE=sqlite ...
    exit;
    ;;
  *)
    echo Unknown or unset DB_TYPE;
    ;;
esac

composer create-project --no-install --stability dev --no-interaction drupal-composer/drupal-project $DRUPAL_PROJECT_DIR $SKELETON_VERSION

cd $DRUPAL_PROJECT_DIR

# if [[ -v DRUPAL_VERSION ]]; then
#   composer -vv require --no-update drupal/core:$DRUPAL_VERSION;
# fi

composer install
command -v drupal
command -v drush
drupal check

site_install () {
  drupal site:install $PROFILE --yes --no-interaction --verbose
  --langcode=$LANGCODE
  --db-type=$DB_TYPE
  --db-host=$DB_HOST
  --db-port=$DB_PORT
  --db-name=$USER
  --db-user=$USER
  --db-pass=""
  --site-name="Project Only"
  --site-mail="admin@example.com"
  --account-name="admin"
  --account-mail="admin@example.com"
  --account-pass="admin"
  ;
}

for profile in minimal standard; do
  for langcode in en fr; do
    env PROFILE=$profile LANGCODE=$langcode site_install;
  done;
done


drush core:status
drush core:requirements
