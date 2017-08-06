# Jenkins PHP slave image for SCA project.
# TODO: check https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/#run

# Tools provided are:

# PHPUnit
# https://phpunit.de/

# Provides Code Sniffer
# https://github.com/squizlabs/PHP_CodeSniffer

# PHPLoc
# phploc is a tool for quickly measuring the size and analyzing the structure of a PHP project.
# https://github.com/sebastianbergmann/phploc

# PHPDepend
# PHP_Depend is an adaption of the established Java development tool JDepend. This tool shows you the quality of your design in the terms of extensibility, $
# http://pdepend.org/

# PHPMD
# PHP Mess Detector
# http://phpmd.org/

# PHPCPD
# Copy/Paste Detector (CPD) for PHP code.
# https://github.com/sebastianbergmann/phpcpd

# PHPDOX
# PHP Documentation Generator
# http://phpdox.de/

# PHPSTAN+Extensions
# PHP Static Analysis Tool - discover bugs in your code without running it!
# https://github.com/phpstan/phpstan
# https://medium.com/@ondrejmirtes/phpstan-2939cd0ad0e3
# https://github.com/phpstan/phpstan-doctrine
# TODO: dependancy hell https://github.com/phpstan/phpstan-guzzle
# https://github.com/phpstan/phpstan-nette
# https://github.com/phpstan/phpstan-dibi

FROM btowerlabz/docker-sca-ci-slave
MAINTAINER BTower Labz <labz@btower.net>

ARG LABELS=/home/jenkins/swarm-labels.cfg

ENV PATH="/home/jenkins/.composer/vendor/bin:${PATH}"

#Install additional software
USER root
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN apt-get update && apt-get install -y apt-utils

#Install basic tools
RUN apt-get update && apt-get install -y curl git unzip lsof nano

#Install basic php environment
RUN apt-get update && apt-get install -y php-common php-cli php-xsl php-mbstring php-xdebug xmlstarlet

# Install composer
ADD getcomposer.sh /tmp/getcomposer.sh
RUN ["/bin/bash", "-c", "chmod u+x /tmp/getcomposer.sh; /tmp/getcomposer.sh"]

USER jenkins

ADD composer.json /home/jenkins/.composer/composer.json
RUN ["/bin/bash", "-c", "composer global update"]
RUN mkdir -p /home/jenkins/.ssh; touch /home/jenkins/.ssh/known_hosts

# Set agent labels
RUN printf " php phpunit phpcs phploc pdepend phpmd phpcpd phpdox phpstan xmlstarlet" >>${LABELS}

# Send some info to build log
RUN uname -a; cat /etc/issue; php --version; php --ini; php -m; cat ${LABELS}

USER root
RUN echo 'debconf debconf/frontend select Dialog' | debconf-set-selections

USER jenkins


