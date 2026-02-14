FROM debian:bullseye

# Installation NGINX et OpenSSL
RUN apt-get update && \
	apt-get install -y \
		nginx \
		openssl && \
	
	# Nettoyage cache APT
	rm -rf /var/lib/apt/lists/*

# Création du dossier pour les certificats SSL
# NGINX cherchera les certificats ici (défini dans nginx.conf)
RUN mkdir -p /etc/nginx/ssl

# Copie de la configuration NGINX
# Remplace la config par défaut par notre config custom
COPY conf/nginx.conf /etc/nginx/sites-available/default

# Copie du script de démarrage
# Ce script va générer les certificats SSL et lancer NGINX
COPY tools/init-nginx.sh /usr/local/bin/init-nginx.sh

RUN chmod +x /usr/local/bin/init-nginx.sh

# Expose le port 443 (HTTPS)
# Indique que ce conteneur écoute sur le port 443
# Déclaratif uniquement, le vrai mapping est dans docker-compose.yml
EXPOSE 443

# Lance le script au démarrage du conteneur
ENTRYPOINT ["usr/local/bin/init-nginx.sh"]
