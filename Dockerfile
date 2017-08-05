# Jenkins PHP slave image for SCA project.
# TODO: check https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run

FROM btowerlabz/docker-sca-ci-slave
MAINTAINER BTower Labz <labz@btower.net>

ARG LABELS=/home/jenkins/swarm-labels.cfg

ENV PATH="/home/jenkins/.composer/vendor/bin:${PATH}"

#Install additional software
USER root
RUN apt-get update && apt-get install -y apt-utils

#Install basic tools
RUN apt-get update && apt-get install -y curl git unzip lsof nano

#Install basic php environment
RUN apt-get update && apt-get install -y php-common php-cli php-xsl php-mbstring php-xdebug

# Install composer
# COPY composer-setup.php /tmp/composer-setup.php
RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '669656bab3166a7aff8a7506b8cb2d1c292f042046c5a994c43155c0be6190fa0355160742ab2e1c88d40d5be660b410') { echo 'HASH OK'; } else { echo 'HASH FAIL'; unlink('/tmp/composer-setup.php'); } echo PHP_EOL;"
RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
RUN rm /tmp/composer-setup.php
RUN touch /home/jenkins/.composer
RUN chown jenkins:jenkins /home/jenkins/.composer

USER jenkins

RUN mkdir -p /home/jenkins/.ssh
RUN touch /home/jenkins/.ssh/known_hosts

# Set php label
RUN printf " php" >>${LABELS}

# Install PHPUnit
# https://phpunit.de/
RUN composer global require phpunit/phpunit
RUN composer global require phpunit/php-invoker
RUN composer global require phpunit/dbunit
RUN printf " phpunit" >>${LABELS}

# Install Code Sniffer
# https://github.com/squizlabs/PHP_CodeSniffer
RUN composer global require squizlabs/php_codesniffer=*
RUN printf " phpcs" >>${LABELS}

# Install PHPLoc
# phploc is a tool for quickly measuring the size and analyzing the structure of a PHP project.
# https://github.com/sebastianbergmann/phploc
RUN composer global require phploc/phploc
RUN printf " phploc" >>${LABELS}

# Install PHPDepend
# PHP_Depend is an adaption of the established Java development tool JDepend. This tool shows you the quality of your design in the terms of extensibility, reusability and maintainability.
# http://pdepend.org/
RUN composer global require pdepend/pdepend:@stable
RUN printf " pdepend" >>${LABELS}

# Install PHPMD
# PHP Mess Detector
# http://phpmd.org/
RUN composer global require phpmd/phpmd:@stable
RUN printf " phpmd" >>${LABELS}

# Install phpcpd
# Copy/Paste Detector (CPD) for PHP code. 
# https://github.com/sebastianbergmann/phpcpd
RUN composer global require --dev sebastian/phpcpd
RUN printf " phpcpd" >>${LABELS}

# Install phpdox
# PHP Documentation Generator
# http://phpdox.de/
RUN composer global require theseer/phpdox
RUN printf " phpdox" >>${LABELS}

RUN uname -a
RUN cat /etc/issue
RUN php --version
RUN cat ${LABELS}
