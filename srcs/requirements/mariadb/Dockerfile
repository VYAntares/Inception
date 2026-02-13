# Image de base Debian 11
FROM debian:bullseye

# Installation de MariaDB (serveur + client)
RUN apt-get update && \
	apt-get install -y mariadb-server mariadb-client && \
	rm -rf /var/lib/apt/lists/*

# ⚠️ IMPORTANT : Supprime les données créées par l'installation
RUN rm -rf /var/lib/mysql/*

# Création du dossier socket (nécessaire pour MariaDB)
RUN mkdir -p /run/mysqld && \
	chown mysql:mysql /run/mysqld

# Copie de la configuration MariaDB
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# Copie du script d'initialisation
COPY tools/init-db.sh /usr/local/bin/init-db.sh

# Rend le script exécutable
RUN chmod +x /usr/local/bin/init-db.sh

# Lance le script au démarrage du conteneur
ENTRYPOINT ["/usr/local/bin/init-db.sh"]
