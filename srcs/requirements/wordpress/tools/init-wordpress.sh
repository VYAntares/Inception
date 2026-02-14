#!/bin/bash

while ! mysqladmin ping -h"mariadb" --silent ; do
	echo "Waiting for MariaDB.."
	sleep 2
done
echo "MariaDB is ready!"

source /run/secrets/credentials

if [ -f "/var/www/html/wp-config.php" ]; then
	echo "Wordpress already installed, skipping.."
else
	echo "First installation.."
	
	# Télécharge WordPress dans /var/www/html
	wp core download --allow-root

	# Crée wp-config.php avec les informations de connexion à MariaDB
	# Ce fichier indique à WordPress comment se connecter à la base de données
	wp config create \
		--dbname=${DB_NAME} \
		--dbuser=${DB_USER} \
		--dbpass=$(cat /run/secrets/db_password) \
		--dbhost=${MYSQL_HOST} \
		--allow-root

	# Installe WordPress et crée l'utilisateur admin
	wp core install \
		--url=https://${DOMAIN_NAME} \
		--title="Inception." \
		--admin_user=eahmeti \
		--admin_password=${wp_admin_password} \
		--admin_email=eahmeti@example.com \
		--allow-root

	# Crée un deuxième utilisateur (non-admin)
	wp user create \
		user \
		user@example.com \
		--user_pass=${wp_user_password} \
		--role=author \
		--allow-root

	chown -R www-data:www-data /var/www/html
	#  │   │     │         │          │
	#  │   │     │         │          └─ Dossier concerné
	#  │   │     │         └─ Groupe propriétaire
	#  │   │     └─ Utilisateur propriétaire  
	#  │   └─ Récursif (tous les fichiers/dossiers à l'intérieur)
	#  └─ Commande "change owner" (changer propriétaire)
	#
	#  ❌ Sans chown :
	#  ├─ /var/www/html (propriétaire: root)
	#  ├─ wp-config.php (propriétaire: root)
	#  └─ wp-content/ (propriétaire: root)
	#
	# PHP-FPM (www-data) essaie d'écrire → ❌ PERMISSION DENIED
	#
	# ✅ Avec chown :
	# ├─ /var/www/html (propriétaire: www-data)
	# ├─ wp-config.php (propriétaire: www-data)
	# └─ wp-content/ (propriétaire: www-data)
	#
	# PHP-FPM (www-data) essaie d'écrire → ✅ OK !


fi

exec php-fpm7.4 -F

