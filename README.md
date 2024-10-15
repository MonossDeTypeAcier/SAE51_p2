# SAE51_p2

# Solutions libres de collecte, centralisation et présentation des logs

Dans ce document, nous allons présenter plusieurs solutions open-source permettant de collecter, centraliser et visualiser les logs. Nous nous intéresserons à leurs fonctionnalités principales, leurs avantages et inconvénients, et leur facilité de mise en place.

## 1. **ELK Stack (Elasticsearch, Logstash, Kibana)**

### Description
L'ELK Stack est une suite d'outils composée de :
- **Elasticsearch** : moteur de recherche et d'indexation.
- **Logstash** : collecte et traitement des logs.
- **Kibana** : visualisation des logs.

### Avantages
- Très complet avec de nombreuses fonctionnalités.
- Dashboards interactifs et personnalisables avec Kibana.
- Grande communauté et beaucoup de documentation.

### Inconvénients
- Complexe à installer et configurer (plusieurs composants).
- Consomme beaucoup de ressources (surtout Elasticsearch).
- Certaines fonctionnalités sont payantes (via Elastic).

### Cas d'usage
L'ELK Stack est bien adaptée aux entreprises qui ont besoin de gérer de grands volumes de logs avec des visualisations avancées.

---

## 2. **Loki + Promtail ou Alloy + Grafana**

### Description
Loki est un système léger de gestion des logs, souvent utilisé avec Promtail (pour la collecte) et Grafana (pour la visualisation).

### Avantages
- Plus simple et moins gourmand en ressources que ELK.
- Très bien intégré avec Grafana pour les dashboards.
- Idéal pour les environnements conteneurisés (comme Docker et Kubernetes).

### Inconvénients
- Moins puissant pour la recherche de logs complexes.
- Indexation limitée par rapport à Elasticsearch.

### Cas d'usage
Solution adaptée pour ceux qui recherchent une solution simple à mettre en place et légère, surtout dans des environnements Kubernetes.

---

## 3. **Graylog**

### Description
Graylog est une solution open-source de gestion des logs basée sur Elasticsearch et MongoDB pour le stockage des données.

### Avantages
- Interface utilisateur facile à utiliser.
- Bonne gestion des notifications et alertes basées sur les logs.
- Capable de gérer de gros volumes de logs grâce à Elasticsearch.

### Inconvénients
- Moins de flexibilité pour les dashboards que Kibana ou Grafana.
- Dépendance forte à Elasticsearch, qui peut rendre la gestion complexe.

### Cas d'usage
Graylog convient bien aux petites et moyennes entreprises qui ont besoin d’une solution simple pour gérer et visualiser leurs logs sans trop de complexité.

---

## Conclusion

- **ELK Stack** : solution complète mais gourmande en ressources.
- **Loki + Grafana** : léger et simple, parfait pour des environnements Kubernetes.
- **Graylog** : bonne alternative à ELK, plus simple d’utilisation.

Chaque solution a ses forces et faiblesses, et le choix dépend des besoins spécifiques de l’entreprise ou du projet.


---

# Tutoriel du fonctionnement de projet

## Initialisation 

Pour commencer, il suffit de cloner le dépôt, puis de changer le chemin du bind mount de Nginx, dans le fichiers docker-compose.yml, qui est le seul avec un chemin absolu. Ensuite, il suffit de lancer un simple "docker-compose up" (il est possible qu'il soit nécessaire de modifier la version de Docker Compose au début du fichier) dans le dossier logAlloy.


## Lancement 


Ce fichier Docker Compose permet de démarrer 4 conteneurs : un conteneur Nginx, un conteneur Alloy, un conteneur Loki et un conteneur Grafana.

Avec la commande "docker ps", on peut vérifier que les 4 conteneurs fonctionnent correctement.

- Sur 127.0.0.1:8080, on accède à la page Nginx (ici la page par défaut).
- Sur 127.0.0.1:12345, on accède à l'interface d'Alloy, qui affiche la connectivité avec Loki.
- Sur 127.0.0.1:3100, Loki n'ayant pas d'interface graphique, il n'y a rien d'affiché sur ce port.
- Sur 127.0.0.1:3000, on accède à l'interface de Grafana, qui permet d'afficher les données sur un tableau de bord (créé ou importé), ou tout simplement d'afficher le résultat d'une requête via la page Explore.

## Test du fonctionnement

Pour tester notre solution, on peut aller sur la page **Explore** de Grafana, sélectionner la **source de données** Loki et effectuer la requête suivante :

- {filename="/var/log/access.log"}

Il suffit ensuite de cliquer sur le bouton Live pour afficher les requêtes en temps réel, puis de se connecter à la page Nginx (127.0.0.1:8080). Si l'installation fonctionne correctement, des logs devraient apparaître sur l'interface.

---

# Conclusion sur cette partie de la SAE

Ce projet nous a mis en difficulté en raison du manque de documentation sur la solution que nous avions choisie. Nous pensions qu'en suivant des tutoriels, tout fonctionnerait directement, mais comme notre architecture différait de celle du tutoriel (qui utilisait Alloy sur la machine hôte et non sur un conteneur), nous avons dû nous adapter. Après avoir résolu divers petits problèmes ici et là, nous avons finalement abouti à un projet fonctionnel, sur lequel il est possible de générer les logs souhaités et d'ajouter des machines assez facilement.
