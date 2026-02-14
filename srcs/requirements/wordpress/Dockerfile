# Image de base Debian 11
FROM debian:bullseye

# Installation de PHP-FPM et des dépendances WordPress
RUN apt-get update && \
    apt-get install -y \
        # Moteur PHP qui exécute WordPress
        php-fpm \

        # Extension pour parler à MariaDB
        php-mysql \

        # Pour télécharger des ressources (thèmes, plugins)
        php-curl \

        # Pour manipuler les images (miniatures, etc.)
        php-gd \

        # Pour gérer les caractères spéciaux
        php-mbstring \

        # Pour lire/écrire du XML
        php-xml \

        # Pour décompresser des archives
        php-zip \

        # Pour télécharger WordPress
        wget \

        # Pour télécharger WP-CLI
        curl \

        # Pour tester la connexion à MariaDB
        mariadb-client && \

    rm -rf /var/lib/apt/lists/*

# Création du dossier pour PHP-FPM
RUN mkdir -p /run/php

# Téléchargement de WP-CLI (outil en ligne de commande WordPress)
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

# Création du dossier WordPress
RUN mkdir -p /var/www/html

# Copie de la configuration PHP-FPM
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Copie du script d'initialisation
COPY tools/init-wordpress.sh /usr/local/bin/init-wordpress.sh

# Rend le script exécutable
RUN chmod +x /usr/local/bin/init-wordpress.sh

# Définit le répertoire de travail
WORKDIR /var/www/html

# Lance le script au démarrage
ENTRYPOINT ["/usr/local/bin/init-wordpress.sh"]
