# The MIT License
#
#  Copyright (c) 2015, CloudBees, Inc.
#
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.

FROM jenkinsci/slave
MAINTAINER BTower Labz <labz@btower.net>

COPY jenkins-slave /usr/local/bin/jenkins-slave

#Install additional software
USER root
RUN apt-get update
RUN uname -a
RUN cat /etc/issue

#Install basic tools
RUN apt-get install -y curl git unzip lsof

#Install basic php
RUN apt-get install -y php5-common php5-cli

#Install composer
COPY composer-setup.php /tmp/composer-setup.php
RUN php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'HASH OK'; } else { echo 'HASH FAIL'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm /tmp/composer-setup.php
RUN touch /home/jenkins/.composer
RUN chown jenkins:jenkins /home/jenkins/.composer

#Install php development tools
RUN apt-get install -y \
php-apigen \
phpcpd \
phpdox \
phploc \
phpmd \
phpunit

USER jenkins
RUN pwd
RUN ls -la
RUN composer global require "phpunit/phpunit"
RUN composer global require "phpunit/php-invoker"
RUN composer global require "phpunit/dbunit"
RUN composer global require "squizlabs/php_codesniffer=*"

ENTRYPOINT ["jenkins-slave"]
