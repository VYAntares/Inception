#!/bin/bash
# Script d'initialisation de MariaDB pour Docker
# Lance au démarrage du conteneur pour configurer la base de données

# Vérifie si MariaDB a déjà été initialisé
# Le dossier /var/lib/mysql/mysql est créé lors de la première installation
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "First installation..."
	
	# Initialise la structure de base de MariaDB
	# Crée les tables système et les fichiers nécessaires
	# --user=mysql : Les fichiers appartiendront à l'utilisateur mysql
	# --datadir : Spécifie où créer les données (même chemin que dans 50-server.cnf)
	mysql_install_db --user=mysql --datadir=/var/lib/mysql
	
	# Lance MariaDB en mode bootstrap (temporaire) pour la configuration
	# --bootstrap : Mode spécial qui lit les commandes SQL depuis stdin et s'arrête après
	
	# Crée la base de données WordPress (variable ${DB_NAME} du .env)
	# Crée l'utilisateur WordPress (${DB_USER}@'%' avec ${DB_PASSWORD})
	# Donne tous les droits à cet utilisateur sur la base
	# Sécurise root avec un mot de passe (${DB_ROOT_PASSWORD})
	# Applique les changements avec FLUSH PRIVILEGES
	mysqld --user=mysql --bootstrap << EOF
	CREATE DATABASE IF NOT EXISTS ${DB_NAME};
	CREATE USER '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
	GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';
	ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
	FLUSH PRIVILEGES;
EOF
fi

# Lance MariaDB en mode foreground (premier plan)
# exec : Remplace le processus du script par mysqld (devient PID 1)
# --user=mysql : Lance le serveur avec l'utilisateur mysql (pas root)
# Cette commande bloque et garde le conteneur actif
exec mysqld --user=mysql
