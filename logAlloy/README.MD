# Documentation du Projet de Collecte de Logs - SAE51

## Introduction

La gestion et l'analyse des logs sont des enjeux critiques pour le suivi des performances, l'identification d'erreurs, et la sécurisation des systèmes. Ce projet a pour but de mettre en place une infrastructure modulaire et performante pour la collecte, la centralisation, le filtrage, et la visualisation des logs. Cette infrastructure repose sur **Nginx**, **Alloy**, **Loki**, et **Grafana**, orchestrés via **Docker Compose**. 

### Objectifs du Projet

L’objectif principal est de récolter, filtrer et analyser les **logs d'accès et d'erreurs** des applications et des services. Le projet vise à :
1. **Collecter les logs** générés par des services comme Nginx.
2. **Centraliser et filtrer** les logs afin d’éliminer les informations superflues.
3. **Visualiser les logs** dans une interface web intuitive pour analyser les tendances et détecter des anomalies ou des erreurs.

### Cas d'Usage

Ce projet est particulièrement adapté pour :
- Le suivi des erreurs d'authentification, de connexion, ou d'accès à un service.
- La surveillance de la performance du serveur en temps réel.
- La gestion des événements critiques dans une infrastructure distribuée.

## Architecture du Système

### Schéma de l'Architecture

```
   ┌─────────┐       ┌────────┐      ┌───────┐      ┌─────────┐
   │  Nginx  │  ───► │  Alloy │ ──►  │ Loki  │ ──►  │ Grafana │
   └─────────┘       └────────┘      └───────┘      └─────────┘
     Génère des       Collecte et    Centralise et   Visualise les
    logs d'accès      filtre les        stocke         logs via
    et d'erreurs        logs           les logs      une interface
                                                   graphique web.
```

### Fonctionnement Global

1. **Nginx** génère des logs d'accès et d'erreurs à chaque requête HTTP ou anomalie.
2. **Alloy** surveille les fichiers de logs créés par Nginx, les collecte, et applique des filtres pour éliminer les informations inutiles.
3. **Loki** centralise les logs envoyés par Alloy, les indexe, et les rend disponibles pour consultation.
4. **Grafana** se connecte à Loki pour offrir une interface de visualisation des logs collectés, permettant d’exécuter des requêtes et de créer des tableaux de bord personnalisés.

### Pourquoi ces Outils ?

- **Nginx** : Serveur web open-source performant et très répandu, utilisé pour héberger des sites web et générer des logs HTTP pertinents.
- **Alloy** : Outil de collecte de logs léger et efficace, conçu pour s’intégrer parfaitement à Grafana et Loki, capable de filtrer les logs à la source pour éliminer le bruit.
- **Loki** : Système de gestion de logs scalables conçu par Grafana Labs, qui centralise les logs et permet de les stocker efficacement, tout en étant optimisé pour fonctionner avec Grafana.
- **Grafana** : Interface de visualisation populaire et extensible, permettant de visualiser les logs et les métriques, créer des alertes, et configurer des tableaux de bord en temps réel.

## Détails des Composants et Configurations

### 1. **Nginx** (Génération des logs)

**Nginx** est utilisé comme serveur web générant des **logs d'accès** et des **logs d'erreurs** à chaque requête ou incident. Il est configuré pour stocker ces logs dans des fichiers locaux accessibles à Alloy.

- **Logs d'accès (`access.log`)** : Contient des informations sur les requêtes HTTP, y compris les adresses IP des clients, les réponses du serveur (codes d'état HTTP), le volume des données transférées, etc.
- **Logs d'erreurs (`error.log`)** : Contient les erreurs relatives au serveur web, par exemple des échecs de connexion ou des problèmes de configuration.

Les logs sont formatés de manière personnalisée dans le fichier `nginx.conf` pour inclure des détails supplémentaires comme les temps de réponse (`$request_time`), le temps de connexion à l'upstream (`$upstream_connect_time`), et d’autres informations utiles pour diagnostiquer les problèmes de performance.

#### Avantages de Nginx
- **Performance** : Nginx est reconnu pour sa faible consommation de ressources et sa capacité à gérer un grand nombre de connexions simultanées.
- **Logs riches** : La flexibilité de la configuration des logs permet de capturer une variété d'informations détaillées.

### 2. **Alloy** (Collecte et Filtrage des logs)

**Alloy** est utilisé pour **collecter les logs** générés par Nginx. Il est configuré pour surveiller le répertoire où Nginx écrit ses logs et pour les transmettre à Loki après avoir appliqué des filtres.

- **File Matching** : Alloy est configuré pour surveiller tous les fichiers se terminant par `.log` dans le répertoire `/var/log/nginx/`.
- **Filtrage des Logs** : Alloy utilise un filtre pour ignorer les logs qui ne sont pas pertinents, comme les erreurs "Connection closed by authenticating user root", afin de limiter le bruit dans les logs et se concentrer sur les événements importants.

#### Avantages d'Alloy
- **Filtrage à la source** : Permet de réduire le volume des logs envoyés à Loki en filtrant les événements inutiles.
- **Intégration naturelle avec Loki et Grafana** : Conçu pour fonctionner sans effort avec ces outils, facilitant la mise en place d'une pipeline de logs complète.

### 3. **Loki** (Centralisation et Stockage des logs)

**Loki** est un **système de gestion des logs** qui indexe les logs collectés par Alloy et les stocke dans un système de fichiers. Il permet une **recherche efficace** des logs, similaire à des solutions comme **Elasticsearch**, mais sans les exigences en matière de gestion des index complexes.

#### Configuration de Loki
- **Rétention des Logs** : La rétention des logs est configurée dans `loki.config.yaml` pour permettre un stockage optimisé des logs, avec un partitionnement (`chunking`) pour faciliter l’archivage et l'accès rapide aux logs.
- **Indexation Légère** : Contrairement à d’autres systèmes de gestion de logs comme Elastic, Loki n’indexe que les métadonnées des logs, ce qui réduit l'espace disque et les ressources nécessaires.

#### Avantages de Loki
- **Scalabilité** : Loki est conçu pour gérer de gros volumes de logs tout en restant performant.
- **Coût d’indexation réduit** : En n’indexant que les métadonnées, Loki est plus économe en termes de stockage et de performance par rapport à d'autres solutions comme ELK (Elasticsearch, Logstash, Kibana).

### 4. **Grafana** (Visualisation des logs)

**Grafana** est l’outil de visualisation utilisé pour **interroger** et **analyser** les logs stockés dans Loki. Grâce à ses puissantes fonctionnalités de tableau de bord, il permet de **créer des visualisations** claires des logs en fonction de divers critères (période de temps, sources, types d’erreurs).

#### Configuration de Grafana
- **Provisionnement des Datasources** : Grafana est automatiquement configuré pour se connecter à Loki grâce à un fichier de provisionnement généré dans `docker-compose.yml`. Cela permet à Grafana d'accéder immédiatement aux logs collectés.
- **Dashboards** : Il est possible de configurer des tableaux de bord qui suivent les erreurs HTTP, les temps de réponse des requêtes, et les incidents critiques.

#### Avantages de Grafana
- **Interface intuitive** : Fournit une interface web puissante pour la visualisation en temps réel.
- **Alertes** : Permet de configurer des alertes basées sur des conditions spécifiques trouvées dans les logs (erreurs critiques, pics de latence, etc.).

### 5. **Docker Compose** (Orchestration)

L'infrastructure est orchestrée à l'aide de **Docker Compose**, ce qui permet de gérer facilement les services, leurs dépendances, et leur configuration respective. Le fichier `docker-compose.yml` définit :
- **Les services** : Nginx, Alloy, Loki, et Grafana.
- **Les volumes partagés** : Utilisés pour permettre à Alloy d'accéder aux logs générés par Nginx.
- **Les ports exposés** : Chaque service expose des ports spécifiques pour l’interaction externe (Nginx sur 8080, Loki sur 3100, Grafana sur 3000).

## Justifications Techniques

### Pourquoi ne pas utiliser une pile ELK (Elasticsearch, Logstash, Kibana) ?
Bien que la pile ELK soit une solution populaire pour

 la gestion de logs, Loki offre des avantages considérables en termes de simplicité et de performance :
- **Loki n'indexe pas les logs** eux-mêmes mais uniquement leurs métadonnées, ce qui réduit considérablement les besoins en ressources.
- **L'intégration avec Grafana** est native, facilitant la mise en place rapide d’une solution de visualisation performante.
- **Simplicité de configuration** : La configuration de Loki et Alloy est bien plus légère que celle de Logstash et Elasticsearch.

## Conclusion

Cette infrastructure fournit une solution complète, scalable, et performante pour la gestion et la visualisation des logs. En combinant Nginx pour la génération des logs, Alloy pour leur collecte et filtrage, Loki pour leur stockage et indexation, et Grafana pour leur visualisation, ce système permet d'obtenir une vision claire et actionnable des événements qui surviennent au sein de l'infrastructure.

Cette architecture est idéale pour surveiller des systèmes critiques, gérer des alertes et diagnostiquer des problèmes de performance ou de sécurité en temps réel.

