console_site_install () { drupal site:install $PROFILE --yes --no-interaction --verbose --langcode=$LANGCODE --db-type=$DB_TYPE --db-host=$DB_HOST --db-port=$DB_PORT --db-user=$USER; }
drush_site_install () { drush site:install $PROFILE -y --verbose --locale=$LANGCODE --db-url=$DB_URL; }
# https://drushcommands.com/drush-9x/site/site:install/
# mysql://root:pass@localhost:port/dbname
# sqlite://sites/example.com/files/.ht.sqlite

manage_db_parameters () {
site_install_commands=(console_site_install)
if [[ ! -v DB_TYPE ]]; then export DB_TYPE=$1; fi
case $DB_TYPE in
  "mysql")
    echo MySQL;
    if [[ ! -v DB_HOST ]]; then export DB_HOST="localhost"; fi
    echo DB_HOST=$DB_HOST
    if [[ ! -v DB_URL ]]; then export DB_URL=$DB_TYPE://$USER:""@$DB_HOST:$DB_PORT/$USER; fi
    echo DB_URL=$DB_URL
    if [[ ! -v SIMPLETEST_DB ]]; then export SIMPLETEST_DB=$DB_TYPE://$USER:""@$DB_HOST:$DB_PORT/$USER; fi
    echo SIMPLETEST_DB=$SIMPLETEST_DB
    site_install_commands=(console_site_install drush_site_install)
    ;;
  "sqlite")
    echo SQLite;
    if [[ ! -v DB_URL ]]; then export DB_URL=$DB_TYPE://web/sites/default/files/.ht.sqlite; fi
    echo DB_URL=$DB_URL
    if [[ ! -v SIMPLETEST_DB ]]; then export SIMPLETEST_DB=$DB_TYPE://web/sites/default/files/.ht.sqlite; fi
    echo SIMPLETEST_DB=$SIMPLETEST_DB
    site_install_commands=(console_site_install drush_site_install)
    ;;
  "pgsql")
    echo PgSQL;
    if [[ ! -v DB_HOST ]]; then export DB_HOST="/var/run/postgresql"; fi
    echo DB_HOST=$DB_HOST
    if [[ ! -v DB_PORT ]]; then export DB_PORT=5432; fi;
    echo DB_PORT=$DB_PORT
    if command -v psql ; then psql --host=$DB_HOST --port=$DB_PORT --command="\l"; fi
    if [[ ! -v DB_URL ]]; then export DB_URL=$DB_TYPE://$USER:""@$DB_HOST:$DB_PORT/$USER; fi
    echo DB_URL=$DB_URL
    if [[ ! -v SIMPLETEST_DB ]]; then export SIMPLETEST_DB=$DB_TYPE://$USER:""@$DB_HOST:$DB_PORT/$USER; fi
    echo SIMPLETEST_DB=$SIMPLETEST_DB
    ;;
  "")
    echo Please choose a DB_TYPE in mysql sqlite pgsql;
    echo eg.:
    echo <command> sqlite
    echo or
    echo env DB_TYPE=sqlite ...
    exit;
    ;;
  *)
    echo Unknown DB_TYPE;
    echo $DB_TYPE
    exit;
    ;;
esac
}
