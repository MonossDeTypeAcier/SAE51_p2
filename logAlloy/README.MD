# Projet de Collecte de Logs - SAE51

## Introduction

Ce projet vise à mettre en place une infrastructure de collecte de logs via Docker. Les composants principaux incluent **Loki** pour la centralisation des logs, **Alloy** pour la collecte, **Grafana** pour la visualisation, et **Nginx** comme serveur web générant des logs d'accès et d'erreurs. L'objectif est de collecter, filtrer et visualiser les logs d'erreurs et de connexion provenant de divers services.

## Architecture

L'architecture repose sur 4 services principaux exécutés dans des conteneurs Docker, gérés via un fichier `docker-compose.yml` :

1. **Nginx** : Sert de serveur web simple, générant des logs d'accès et d'erreurs.
2. **Alloy** : Outil de collecte de logs configuré pour surveiller et capturer les logs des fichiers locaux.
3. **Loki** : Centralise les logs collectés par Alloy.
4. **Grafana** : Interface de visualisation des logs collectés et stockés dans Loki.

### Docker Compose

Le fichier `docker-compose.yml` décrit l'orchestration des conteneurs, les volumes partagés et la configuration de chaque service.

## Détails des services

### 1. **Nginx**

- **Objectif** : Fournir un serveur web générant des logs d'accès et d'erreurs.
- **Logs** : 
  - `access.log` : Journal des accès HTTP.
  - `error.log` : Journal des erreurs du serveur.

Le fichier `nginx.conf` configure les journaux de manière à capturer des informations pertinentes, comme les temps de réponse et les erreurs, dans `/var/log/nginx/`.

### 2. **Alloy**

- **Objectif** : Collecter les logs générés par Nginx.
- **Configuration** : 
  - `config.alloy` : Définit les cibles à surveiller (fichiers de logs dans `/var/log/nginx/`) et les étapes de traitement.
  - **File Matching** : Capture les fichiers `*.log` dans le dossier `/var/log/`.
  - **Filtrage** : Nous avons configuré un filtre pour ignorer les logs liés à "Connection closed by authenticating user root", afin de supprimer les logs inutiles.

Alloy lit les logs et les transmet à Loki après filtrage.

### 3. **Loki**

- **Objectif** : Centraliser et stocker les logs envoyés par Alloy.
- **Configuration** : 
  - `loki.config.yaml` : Configure Loki pour stocker les logs dans un stockage local, avec une période de rétention et des configurations pour le partitionnement des logs (`chunks`).
  - **Porte d'écoute** : Loki est exposé sur le port `3100`.
  
Loki reçoit les logs d'Alloy, les indexe et les stocke pour une visualisation future via Grafana.

### 4. **Grafana**

- **Objectif** : Visualiser les logs stockés dans Loki.
- **Configuration** :
  - Grafana est configuré pour se connecter à Loki en tant que source de données par défaut via le fichier `docker-compose.yml`.
  - **Provisionnement des Datasources** : Un fichier de configuration est automatiquement généré pour provisionner Loki et Prometheus en tant que sources de données.

### Volumes

Les logs de Nginx sont partagés entre les conteneurs Nginx et Alloy via un volume Docker (`shared-volume`). Cela permet à Alloy de collecter les logs sans nécessiter de configuration complexe de partage de fichiers.

## Fichiers de configuration

### 1. **config.alloy**

Le fichier `config.alloy` configure Alloy pour lire les fichiers de logs de Nginx et filtrer les lignes inutiles avant de les envoyer à Loki.


### 2. **docker-compose.yml**

Le fichier `docker-compose.yml` gère l'orchestration des services via Docker. Chaque service est configuré pour se lancer avec les bonnes dépendances et options.


### 3. **loki.config.yaml**

Ce fichier configure Loki pour la gestion des logs, y compris le stockage sur le système de fichiers local.


### 4. **nginx.conf**

Ce fichier configure les journaux d'erreurs et d'accès pour Nginx.


## Conclusion

Ce projet met en œuvre une solution complète de collecte et d'analyse des logs, en utilisant des outils modernes comme **Alloy**, **Loki**, et **Grafana**, orchestrés via Docker. Nginx génère les logs, Alloy les collecte et filtre, Loki les centralise, et Grafana permet une visualisation facile des événements. Cette architecture permet de surveiller efficacement les erreurs et les connexions de manière automatisée.
