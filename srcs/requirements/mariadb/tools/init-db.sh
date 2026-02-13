#!/bin/bash
# Script d'initialisation de MariaDB pour Docker
# Lance au démarrage du conteneur pour configurer la base de données

# Vérifie si MariaDB a déjà été initialisé
# Le dossier /var/lib/mysql/mysql est créé lors de la première installation
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "First installation..."
	
	# Charge les secrets depuis les fichiers Docker
	DB_PASSWORD=$(cat /run/secrets/db_password)
	DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
	
	# Initialise la structure de base de MariaDB
	# Crée les tables système et les fichiers nécessaires
	# --user=mysql : Les fichiers appartiendront à l'utilisateur mysql
	# --datadir : Spécifie où créer les données (même chemin que dans 50-server.cnf)
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	
	# Crée un fichier SQL temporaire pour l'initialisation
	# On utilise un fichier pour éviter les problèmes avec --bootstrap
	cat > /tmp/init.sql << EOF
USE mysql;
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DB_ROOT_PASSWORD}' WITH GRANT OPTION;
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='mysql';
DELETE FROM mysql.db WHERE User='';
FLUSH PRIVILEGES;
EOF
	
	# Lance MariaDB en mode bootstrap avec le fichier SQL
	# Cette méthode est plus fiable que stdin
	mysqld --user=mysql --bootstrap < /tmp/init.sql
	
	# Supprime le fichier temporaire (sécurité)
	rm -f /tmp/init.sql
fi

# Lance MariaDB en mode foreground (premier plan)
# exec : Remplace le processus du script par mysqld (devient PID 1)
# --user=mysql : Lance le serveur avec l'utilisateur mysql (pas root)
# Cette commande bloque et garde le conteneur actif
exec mysqld --user=mysql
