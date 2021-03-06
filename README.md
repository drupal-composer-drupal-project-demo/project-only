# project-only
drupal-composer/drupal-project demo

* https://www.drupal.org/docs/develop/using-composer/using-composer-to-manage-drupal-site-dependencies
* [*Composer in relation to Drush Make*](https://www.drupal.org/node/2471553)
* https://phppackages.org/p/drupal-composer/drupal-project
* [*How to download, install and serve Drupal 8*](https://hechoendrupal.gitbooks.io/drupal-console/content/en/using/how-to-download-install-and-serve-drupal8.html)
* https://google.com/search?q=how+to+install+drupal+with+drupal+console
* (fr) https://kgaut.net/blog/2016/drupal-8-prise-en-main-de-drupal-console-installation-et-configuration.html
* (fr) [*Installer Drupal 8 avec composer*](https://kgaut.net/blog/2015/installer-drupal-8-avec-composer.html)
* https://drupalconsole.com/articles/how-to-download-and-install-drupal-8-using-drupal-console
* https://drupalconsole.com/articles/how-to-install-drupal-console

## Tested contributed projects
### Modules
* drupal/admin_toolbar
* drupal/token
* drupal/pathauto
* drupal/metatag #?
* drupal/entity_reference_revisions #?
* drupal/paragraphs #?
* drupal/field_group #?
* drupal/devel #?
* drupal/webform
* drupal/video_embed_field
* drupal/video_embed_facebook
* drupal/video_embed_dailymotion
* drupal/video_embed_instagram
* drupal/video_embed_ted
* drupal/video_embed_html5
* drupal/redirect
* drupal/entity_browser # Is it really needed?

### Themes
* drupal/pixture_reloaded

## Tested with the following versions of Drupal
* 8.4.5
* 8.5.0-rc1
* 8.5.0

## TODO
* Testing
  * https://www.drupal.org/docs/8/testing/types-of-tests-in-drupal-8
  * https://www.drupal.org/docs/8/phpunit/running-phpunit-tests
  * https://github.com/drupal-composer/drupal-project/issues/193
  * https://github.com/drupal/core/tree/8.6.x/tests

## drupal site:install parameters
```sh
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
```
