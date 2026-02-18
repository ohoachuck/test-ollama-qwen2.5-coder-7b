#!/bin/bash

# Script d'installation des hooks Git
# Ce script configure Git pour utiliser les hooks personnalisés

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}📦 Installation des hooks Git...${NC}\n"

# Vérifier si nous sommes dans un dépôt Git
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Erreur: Ce n'est pas un dépôt Git${NC}"
    exit 1
fi

# Obtenir le répertoire racine du dépôt Git
GIT_ROOT=$(git rev-parse --show-toplevel)
HOOKS_DIR="$GIT_ROOT/.githooks"

# Vérifier si le dossier .githooks existe
if [ ! -d "$HOOKS_DIR" ]; then
    echo -e "${RED}❌ Erreur: Le dossier .githooks n'existe pas${NC}"
    exit 1
fi

# Configurer Git pour utiliser le dossier .githooks
echo -e "${YELLOW}Configuration de Git pour utiliser .githooks...${NC}"
git config core.hooksPath .githooks

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Configuration réussie${NC}"
else
    echo -e "${RED}❌ Erreur lors de la configuration${NC}"
    exit 1
fi

# Rendre les hooks exécutables
echo -e "\n${YELLOW}Rendre les hooks exécutables...${NC}"
chmod +x "$HOOKS_DIR"/pre-commit
chmod +x "$HOOKS_DIR"/pre-push

echo -e "${GREEN}✓ Hooks rendus exécutables${NC}"

# Afficher les hooks installés
echo -e "\n${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✓ Installation terminée avec succès!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\n${YELLOW}Hooks installés:${NC}"
echo -e "  • ${GREEN}pre-commit${NC}  - Vérifie les informations sensibles avant chaque commit"
echo -e "  • ${GREEN}pre-push${NC}    - Vérifie l'historique avant chaque push"

echo -e "\n${YELLOW}Pour désactiver temporairement les hooks:${NC}"
echo -e "  git commit --no-verify"
echo -e "  git push --no-verify"

echo -e "\n${YELLOW}Pour désinstaller les hooks:${NC}"
echo -e "  git config --unset core.hooksPath"
echo ""
