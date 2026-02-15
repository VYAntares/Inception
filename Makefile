# Makefile pour Inception
# Gestion de l'infrastructure Docker

# Nom du projet (utilisé par Docker Compose)
NAME = inception

# Fichier docker-compose
COMPOSE_FILE = srcs/docker-compose.yml

# Dossiers de données sur l'hôte
DATA_DIR = $(HOME)/data
MARIADB_DATA = $(DATA_DIR)/mariadb
WORDPRESS_DATA = $(DATA_DIR)/wordpress

# Couleurs pour l'affichage
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

#──────────────────────────────────────────────────────────────
# Règle par défaut : build + up
#──────────────────────────────────────────────────────────────

all:
	@$(MAKE) setup
	@$(MAKE) up

#──────────────────────────────────────────────────────────────
# Configuration initiale
#──────────────────────────────────────────────────────────────

setup:
	@echo "$(YELLOW)Setting up data directories...$(NC)"
	@mkdir -p $(MARIADB_DATA)
	@mkdir -p $(WORDPRESS_DATA)
	@echo "$(GREEN)✓ Data directories created$(NC)"

#──────────────────────────────────────────────────────────────
# Build des images Docker
#──────────────────────────────────────────────────────────────

build:
	@echo "$(YELLOW)Building Docker images...$(NC)"
	@docker compose -f $(COMPOSE_FILE) build
	@echo "$(GREEN)✓ Images built successfully$(NC)"

#──────────────────────────────────────────────────────────────
# Lancement des conteneurs
#──────────────────────────────────────────────────────────────

up:
	@echo "$(YELLOW)Starting containers...$(NC)"
	@docker compose -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)✓ Containers are running$(NC)"
	@echo "$(GREEN)Access your site at: https://eahmeti.42.fr$(hNC)"

#──────────────────────────────────────────────────────────────
# Arrêt des conteneurs
#──────────────────────────────────────────────────────────────

down:
	@echo "$(YELLOW)Stopping containers...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Containers stopped$(NC)"

#──────────────────────────────────────────────────────────────
# Arrêt + suppression des volumes
#──────────────────────────────────────────────────────────────

down-v:
	@echo "$(RED)Stopping containers and removing volumes...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down -v
	@echo "$(GREEN)✓ Containers stopped and volumes removed$(NC)"

#──────────────────────────────────────────────────────────────
# Restart complet
#──────────────────────────────────────────────────────────────

re: fclean all

#──────────────────────────────────────────────────────────────
# Nettoyage complet
#──────────────────────────────────────────────────────────────

clean:
	@echo "$(YELLOW)Cleaning containers...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down
	@echo "$(GREEN)✓ Containers removed$(NC)"

fclean: clean
	@echo "$(RED)Full cleanup: removing images, volumes, and data...$(NC)"
	@docker compose -f $(COMPOSE_FILE) down -v --rmi all
	@sudo rm -rf $(MARIADB_DATA)
	@sudo rm -rf $(WORDPRESS_DATA)
	@echo "$(GREEN)✓ Everything cleaned$(NC)"

#──────────────────────────────────────────────────────────────
# Logs
#──────────────────────────────────────────────────────────────

logs:
	@docker compose -f $(COMPOSE_FILE) logs -f

#──────────────────────────────────────────────────────────────
# Status
#──────────────────────────────────────────────────────────────

ps:
	@docker compose -f $(COMPOSE_FILE) ps

#──────────────────────────────────────────────────────────────
# .PHONY pour éviter les conflits avec des fichiers du même nom
#──────────────────────────────────────────────────────────────

.PHONY: all setup build up down down-v re clean fclean logs ps
