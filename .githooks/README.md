# Hooks Git - Protection contre les données sensibles

Ce dossier contient des hooks Git personnalisés pour protéger votre dépôt contre la publication accidentelle d'informations sensibles.

## 🔒 Hooks disponibles

### 1. `pre-commit`
Vérifie les fichiers avant chaque commit pour détecter :
- Clés API (AWS, Google, Stripe, etc.)
- Tokens d'authentification (GitHub, GitLab, Slack, etc.)
- Mots de passe
- Clés privées SSH/RSA
- URLs avec credentials
- Secrets et tokens génériques

### 2. `pre-push`
Effectue une vérification finale de l'historique des commits avant le push pour s'assurer qu'aucune information sensible n'est présente dans les commits qui vont être poussés.

## 📦 Installation

### Installation automatique
Exécutez le script d'installation :
```bash
./.githooks/install.sh
```

### Installation manuelle
Configurez Git pour utiliser ce dossier de hooks :
```bash
git config core.hooksPath .githooks
chmod +x .githooks/pre-commit
chmod +x .githooks/pre-push
```

## 🚀 Utilisation

Une fois installés, les hooks s'exécutent automatiquement :
- **pre-commit** : À chaque `git commit`
- **pre-push** : À chaque `git push`

Si des informations sensibles sont détectées, le commit ou le push sera bloqué avec un message d'erreur détaillé.

## ⚠️ Contourner les hooks (non recommandé)

En cas de faux positif ou pour des raisons exceptionnelles :
```bash
# Contourner le pre-commit
git commit --no-verify

# Contourner le pre-push
git push --no-verify
```

**⚠️ Attention** : Utilisez ces commandes avec précaution !

## 🔍 Patterns détectés

Les hooks recherchent les patterns suivants :

### Clés API et Secrets
- `api_key`, `api_secret`, `access_token`, `auth_token`
- Clés AWS : `AKIA[0-9A-Z]{16}`
- Tokens GitHub : `ghp_`, `gho_`, `ghu_`, `ghs_`, `ghr_`
- Tokens GitLab : `glpat-`
- Tokens Slack : `xox[baprs]-`
- Clés Google API : `AIza[0-9A-Za-z\-_]{35}`
- Clés Stripe : `sk_live_`, `pk_live_`

### Credentials
- Mots de passe : `password`, `passwd`, `pwd`
- Clés privées : `-----BEGIN PRIVATE KEY-----`
- URLs avec credentials : `https://user:pass@example.com`

### Fichiers ignorés
Les types de fichiers suivants sont automatiquement ignorés :
- Images : `.png`, `.jpg`, `.jpeg`, `.gif`, `.svg`, `.ico`
- Fichiers de lock : `.lock`, `package-lock.json`, `yarn.lock`
- Fichiers minifiés : `.min.js`, `.min.css`
- Fichiers Xcode : `.xcassets/`, `.pbxproj`

## 🛠️ Personnalisation

Vous pouvez modifier les patterns de détection en éditant les fichiers :
- [`.githooks/pre-commit`](.githooks/pre-commit) - Ligne 13 : tableau `PATTERNS`
- [`.githooks/pre-push`](.githooks/pre-push) - Ligne 13 : tableau `SENSITIVE_PATTERNS`

Pour ignorer des fichiers supplémentaires, modifiez le tableau `IGNORE_PATTERNS` dans [`pre-commit`](.githooks/pre-commit:38).

## 🔧 Désinstallation

Pour désactiver les hooks :
```bash
git config --unset core.hooksPath
```

## 📝 Bonnes pratiques

1. **Utilisez des variables d'environnement** pour les secrets
2. **Créez un fichier `.env`** et ajoutez-le à `.gitignore`
3. **Utilisez des gestionnaires de secrets** (AWS Secrets Manager, HashiCorp Vault, etc.)
4. **Ne committez jamais de credentials** en dur dans le code
5. **Vérifiez régulièrement** votre historique Git

## 🆘 En cas de commit accidentel

Si vous avez déjà commité des informations sensibles :

1. **Ne poussez pas** le commit
2. **Modifiez l'historique** :
   ```bash
   # Pour le dernier commit
   git reset --soft HEAD~1
   
   # Pour modifier un commit plus ancien
   git rebase -i HEAD~n
   ```
3. **Nettoyez l'historique** si déjà poussé :
   ```bash
   # Utilisez git-filter-repo ou BFG Repo-Cleaner
   # ATTENTION : Cela réécrit l'historique !
   ```

## 📚 Ressources

- [Git Hooks Documentation](https://git-scm.com/docs/githooks)
- [OWASP - Secrets Management](https://owasp.org/www-community/vulnerabilities/Use_of_hard-coded_password)
- [GitHub - Removing sensitive data](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/removing-sensitive-data-from-a-repository)
