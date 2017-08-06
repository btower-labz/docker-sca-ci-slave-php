#!/usr/bin/env bash

set -o nounset
set -o noclobber
set -o errexit
set -o pipefail

CHASH="669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410"
CFILE="/tmp/composer-setup.php"
php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
php -r "if (hash_file('SHA384', '${CFILE}') === '${CHASH}') { echo 'HASH OK'; } else { echo 'HASH FAIL'; unlink('${CFILE}'); } echo PHP_EOL;"
php "${CFILE}" --install-dir=/usr/local/bin --filename=composer
rm "$CFILE"
touch /home/jenkins/.composer
chown jenkins:jenkins /home/jenkins/.composer
runuser -l jenkins -g jenkins -c "composer --version"
