#!/bin/sh
set -ev # https://docs.travis-ci.com/user/customizing-the-build/

command -v drush
which -a drush

composer require drupal/admin_toolbar
drush pm:enable --yes admin_toolbar # The following module(s) will be enabled: admin_toolbar, toolbar, breakpoint

composer require drupal/token
drush pm:enable token

composer require drupal/pathauto
drush pm:enable --yes pathauto # The following module(s) will be enabled: pathauto, ctools, path

# composer require drupal/metatag #?
# drush pm:enable metatag
# speedup

# composer require drupal/entity_reference_revisions #?
# drush pm:enable entity_reference_revisions
# speedup

# composer require drupal/paragraphs #?
# drush pm:enable paragraphs
# speedup

# composer require drupal/field_group #?
# drush pm:enable field_group
# speedup

# composer require drupal/devel #?
# drush pm:enable devel
# speedup

composer require drupal/webform
drush pm:enable --yes webform # The following module(s) will be enabled: webform, contribute

# composer require drupal/video_embed_field
# drush pm:enable -y video_embed_wysiwyg
# video_embed_field: The following module(s) will be enabled: video_embed_field, image
# speedup

# composer require drupal/video_embed_facebook
# drush pm:enable -y video_embed_facebook
# speedup

# composer require drupal/video_embed_dailymotion
# drush pm:enable -y video_embed_dailymotion
# speedup

# composer require drupal/video_embed_instagram
# drush pm:enable -y video_embed_instagram
# speedup

# composer require drupal/video_embed_ted
# drush pm:enable -y video_embed_ted
# speedup

# composer require drupal/video_embed_html5
# drush pm:enable -y video_embed_html5
# speedup

composer require drupal/redirect
drush pm:enable --yes redirect # The following module(s) will be enabled: redirect, link, views

# composer require drupal/entity_browser # Is it really needed?
# drush pm:enable entity_browser
# speedup

composer require drupal/pixture_reloaded
drush theme:enable -y pixture_reloaded
# - drush help config:get
drush config:get system.theme
drush config:set --yes system.theme default pixture_reloaded
drush config:get system.theme

# composer require drupal/media_entity_browser # Is it really needed?
# drush pm-enable --yes media_entity_browser
# The following module(s) will be enabled: media_entity_browser, media_entity, entity
# Error: Call to a member function getConfigDependencyKey() on null in /home/travis/build/drupal-composer-drupal-project-demo/project-only/my-project/web/modules/contrib/entity_browser/src/Plugin/EntityBrowser/Widget/View.php on line 277
#  Installing drupal/entity (1.0.0-beta1): Downloading (100%)
#  Installing drupal/media_entity (1.7.0): Downloading (100%)
#  Installing drupal/media_entity_browser (1.0.0-beta3): Downloading (100%)

# composer global show --latest
# composer show --latest
# composer show --tree
# drush pm:list

# drush theme:uninstall -y pixture_reloaded || true
# drush config:set --yes system.theme default stark
# drush config:get system.theme
# drush theme:uninstall -y pixture_reloaded # Unable to uninstall themes.

# drush pm:uninstall -y entity_browser
drush pm:uninstall -y redirect
# drush pm:uninstall -y video_embed_html5
# drush pm:uninstall -y video_embed_ted
# drush pm:uninstall -y video_embed_instagram
# drush pm:uninstall -y video_embed_dailymotion
# drush pm:uninstall -y video_embed_facebook
# drush pm:uninstall -y video_embed_wysiwyg
drush pm:uninstall -y webform
# drush pm:uninstall -y devel
# drush pm:uninstall -y field_group
# drush pm:uninstall -y paragraphs
# drush pm:uninstall -y entity_reference_revisions
# drush pm:uninstall -y metatag
drush pm:uninstall -y pathauto
drush pm:uninstall -y token
drush pm:uninstall -y admin_toolbar
