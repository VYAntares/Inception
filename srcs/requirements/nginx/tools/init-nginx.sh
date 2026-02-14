#!/bin/bash

if [ ! -f /etc/nginx/ssl/nginx.crt ]; then
	echo "Generating SSL certificates.."

	# Génère un certificat SSL auto-signé avec OpenSSL
	# -x509 : Génère un certificat auto-signé (pas besoin d'autorité de certification)
	# -nodes : "No DES" = Ne chiffre pas la clé privée (pas de mot de passe)
	# -days 365 : Certificat valide 365 jours
	# -newkey rsa:2048 : Génère une nouvelle clé RSA de 2048 bits
	# -keyout : Où sauvegarder la clé privée
	# -out : Où sauvegarder le certificat public
	# -subj : Informations du certificat (évite les questions interactives)
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout /etc/nginx/ssl/nginx.key \
		-out /etc/nginx/ssl/nginx.crt \
		-subj "/C=CH/ST=Vaud/L=Renens/O=42/OU=Student/CN=${DOMAIN_NAME}"

	# Sécurise les permissions des certificats
	# Clé privée : Lecture seule pour root (600)
	# Certificat public : Lecture pour tout le monde (644)
	chmod 600 /etc/nginx/ssl/nginx.key
	chmod 644 /etc/nginx/ssl/nginx.crt

	echo "SSL certificates generated!"
else
	echo "SSL certificates already exist, skipping generation."
fi

# 🚀 Lance NGINX en mode foreground
# -g "daemon off;" : Force NGINX à rester au premier plan
# Sans ça, NGINX se lance en arrière-plan et le conteneur s'arrête immédiatement
# exec : Remplace le processus bash par nginx (devient PID 1)
# Important : PID 1 reçoit les signaux Docker (SIGTERM pour arrêt propre)
echo "Starting NGINX..."
exec nginx -g 'daemon off;'
