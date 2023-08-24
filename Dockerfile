# FROM ubuntu:18.04
# LABEL maintainer="akshay.kumar758@webkul.com"

# ENV GOSU_VERSION 1.11

# RUN adduser uvdesk -q --disabled-password --gecos ""

# # Install base supplimentary packages
# RUN apt-get update && apt-get -y upgrade \
#     && apt-get update && apt-get install -y software-properties-common && add-apt-repository -y ppa:ondrej/php \
#     && apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -y install \
#         curl \
#         wget \
#         git \
#         unzip \
#         apache2 \
#         mysql-server \
#         php7.4 \
#         libapache2-mod-php7.4 \
#         php7.4-common \
#         php7.4-xml \
#         php7.4-imap \
#         php7.4-mysql \
#         php7.4-mailparse \
#         ca-certificates; \
#     if ! command -v gpg; then \
# 		apt-get install -y --no-install-recommends gnupg2 dirmngr; \
# 	elif gpg --version | grep -q '^gpg (GnuPG) 1\.'; then \
# 		apt-get install -y --no-install-recommends gnupg-curl; \
# 	fi;

# COPY ./.docker/config/apache2/env /etc/apache2/envvars
# COPY ./.docker/config/apache2/httpd.conf /etc/apache2/apache2.conf
# COPY ./.docker/config/apache2/vhost.conf /etc/apache2/sites-available/000-default.conf
# COPY ./.docker/bash/uvdesk-entrypoint.sh /usr/local/bin/
# COPY . /var/www/uvdesk/

# RUN \
#     # Update apache configurations
#     a2enmod php7.4 rewrite; \
#     chmod +x /usr/local/bin/uvdesk-entrypoint.sh; \
#     # Install gosu for stepping-down from root to a non-privileged user during container startup
#     dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
#     wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
#     && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc"; \
#     # Verify gosu installation
#     export GNUPGHOME="$(mktemp -d)" \
#     && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
# 	&& gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
#     && gpgconf --kill all \
#     && chmod +x /usr/local/bin/gosu \
#     && gosu nobody true; \
#     \
#     # Download and verify composer installer signature
#     wget -O /usr/local/bin/composer.php "https://getcomposer.org/installer"; \
#     actualSig="$(wget -q -O - https://composer.github.io/installer.sig)"; \
#     currentSig="$(shasum -a 384 /usr/local/bin/composer.php | awk '{print $1}')"; \
#     if [ "$currentSig" != "$actualSig" ]; then \
#         echo "Warning: Failed to verify composer signature."; \
#         exit 1; \
# 	fi; \
#     # Install composer
#     php /usr/local/bin/composer.php --quiet --filename=/usr/local/bin/composer \
#     && chmod +x /usr/local/bin/composer; \
#     # Assign user uvdesk the ownership of source directory
#     chown -R uvdesk:uvdesk /var/www; \
#     # Clean up files
#     rm -rf \
#         "$GNUPGHOME" \
#         /var/lib/apt/lists/* \
#         /usr/local/bin/gosu.asc \
#         /usr/local/bin/composer.php \
#         /var/www/bin \
#         /var/www/html \
#         /var/www/uvdesk/.docker;

# # Change working directory to uvdesk source
# WORKDIR /var/www

# ENTRYPOINT ["uvdesk-entrypoint.sh"]
# CMD ["/bin/bash"]

FROM ubuntu:latest
LABEL maintainer="bravoheavy@gmail.com"


COPY ./.docker/bash/uvdesk-entrypoint.sh /usr/local/bin/
RUN apt-get update && \
    ARG DEBIAN_FRONTEND=noninteractive apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ondrej/php && \
    apt-get update && \
    adduser uvdesk -q --disabled-password --gecos "" && \
    apt-get -y install php7.3 php7.3-curl php7.3-intl php7.3-gd php7.3-dom php7.3-iconv php7.3-xsl php7.3-mbstring php7.3-ctype php7.3-zip php7.3-pdo php7.3-xml php7.3-bz2 php7.3-calendar php7.3-exif php7.3-fileinfo php7.3-json php7.3-mysqli php7.3-mysql php7.3-posix php7.3-tokenizer php7.3-xmlwriter php7.3-xmlreader php7.3-phar php7.3-soap php7.3-mysql php7.3-fpm libapache2-mod-php7.3 php7.3-gmp php7.3-bcmath php7.3-apcu php7.3-redis php7.3-imagick php7.3-imap php7.3-xdebug && \
    apt-get -y install php7.3-mailparse && \
    apt-get -y install php7.3-imap && \
    apt-get -y install apache2 wget mysql-client && \
    phpenmod -v 7.3 -s apache2 mailparse && \
    a2enmod php7.3 && \
    a2enmod rewrite && \
    service apache2 restart && \
    cd /var/www && \
    wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet && \
    ./composer.phar clear-cache && \
    ./composer.phar create-project uvdesk/community-skeleton uvdesk && \
    chmod 777 -R /var/www/uvdesk/.env && \
    chmod 777 -R /var/www/uvdesk/config && \
    chmod 777 -R /var/www/uvdesk/var && \
    cd /var/www/uvdesk && \
    wget https://raw.githubusercontent.com/NuttCorp/uvdesk/master/entrypoint.sh && \
    cp ./.docker/config/apache2/env /etc/apache2/envvars && \
    cp ./.docker/config/apache2/httpd.conf /etc/apache2/apache2.conf && \
    cp ./.docker/config/apache2/vhost.conf /etc/apache2/sites-available/000-default.conf && \
    cp ./entrypoint.sh /usr/local/bin/ && \
    chmod +x /usr/local/bin/entrypoint.sh && \
    chown -R uvdesk:uvdesk /var/www && \
    service apache2 restart && \
    php bin/console c:c; \
    set -eux; \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"; \
    wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.11/gosu-$dpkgArch"; \
    chmod +x /usr/local/bin/gosu;\
    # Clean up files
    rm -rf \
    /var/lib/apt/lists/* \
    /usr/local/bin/gosu.asc \
    /usr/local/bin/composer.php \
    /var/www/bin \
    /var/www/html \
    /var/www/uvdesk/.docker;

# Change working directory to uvdesk source
WORKDIR /var/www

ENTRYPOINT ["uvdesk-entrypoint.sh"]
CMD ["/bin/bash"]