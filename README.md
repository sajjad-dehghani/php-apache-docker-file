# PHP:7.3.25-Apache Dockerfile
This Dockerfile helps you to create an image from [DockerHub](https://hub.docker.com/layers/php/library/php/7.3.25-apache/images/sha256-e16142c92a9fdbf74a76e64276e1851d468fc44914440ce9968159656988f658?context=explore),
and then enable important PHP extensions and Apache modules to setup a web server with Apache and PHP 7.3.36

After clone file just save Dockerfile on current run console and follow this command:

``docker image build . -t [Image Name]``

# Note
To learning what php extension and apache modules are enabled by default, please follow link on: [DockerHub](https://hub.docker.com/_/php).

# Additional enabled PHP extensions:
- gd
- soap
- mcrypt
- redis
- pdo_mysql

# Additional enabled Apache modules:
- rewrite-mode
- ssl-mode


You can follow medium link to more information: [Medium](https://medium.com/@sajjad_dehghani/php-7-3-25-apache-dockerfile-22b26ebb78d9)
