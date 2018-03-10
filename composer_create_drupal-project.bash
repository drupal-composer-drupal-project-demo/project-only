#!/bin/bash
# [[ ]] requires bash
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

time composer create-project --no-install --stability dev drupal-composer/drupal-project $DRUPAL_PROJECT_DIR $SKELETON_VERSION
# Why --stability dev

if [[ -v $DRUPAL_PROJECT_DIR ]]; then cd $DRUPAL_PROJECT_DIR; else cd drupal-project; fi;
if ls /dev/shm; then
  install --directory /dev/shm/drupal-project # TODO tmpdir drwx
  install --directory web/sites/default
  pushd web/sites/default; ln -s /dev/shm/drupal-project files; popd
  df --print-type /dev/shm web/sites/default/files
fi

export PATH=$(pwd)/vendor/bin:$PATH

if [[ -v DRUPAL_VERSION ]]; then
  time composer -vv require --no-update drupal/core:$DRUPAL_VERSION;
fi

time composer install
command -v drupal
command -v drush
drupal check
