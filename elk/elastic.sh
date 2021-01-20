#!/bin/#!/usr/bin/env bash

echo "deb https://artifacts.elastic.co/packages/7.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-7.x.list
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
sudo apt update
sudo apt-get install openjdk-11-jdk -y
sudo apt install -y elasticsearch
sudo /bin/systemctl daemon-reload
sudo /bin/systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo systemctl status elasticsearch.service

echo "Elasticsearch master ip:"
read master
echo "Elasticsearch nodes ip:"
read node_1
read node_2

echo "discovery.seed_hosts: [$master, $node_1, $node_2]" >> elasticsearch.yml
echo "cluster.initial_master_nodes: [$master]" >> elasticsearch.yml
cp elasticsearch.yml /etc/elasticsearch/
echo "Is it master - y or n?"
read vm


cd /usr/share/elasticsearch
bin/elasticsearch-certutil ca
bin/elasticsearch-certutil cert --ca elastic-stack-ca.p12
cp elastic-certificates.p12 /etc/elasticsearch/

if [[ vm == "y" ]]; then
  sudo /usr/share/elasticsearch/bin/elasticsearch-setup-passwords interactive
  sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add azure.client.default.account
  sudo /usr/share/elasticsearch/bin/elasticsearch-keystore add azure.client.default.key
  scp /usr/share/elasticsearch/elastic-certificates.p12 okosyiev@am@$node_1:/home/am.elcompanies.net/okosyiev
  scp /usr/share/elasticsearch/elastic-certificates.p12 okosyiev@am@$node_2:/home/am.elcompanies.net/okosyiev
fi

if [[ vm != "y" ]]; then
  cp ~/elastic-certificates.p12 /etc/elasticsearch/
fi

chown root:elasticsearch /etc/elasticsearch/elastic-certificates.p12
chmod 660 /etc/elasticsearch/elastic-certificates.p12
systemctl restart elasticsearch

echo "Elasticsearch password:"
read password
if [[ vm == "y" ]]; then
  curl -u elastic:$password-XPUT http://$master:9200/_snapshot/prod-cdpuk-repository -H 'Content-Type: application/json' -d '{"type": "azure",
  "settings": {
  "location": "https://saeuuksprodcdpuksnap01.blob.core.windows.net",
  "container": "prod-cdpuk-repository",
  "base_path": "/"
  }}'
fi

  #statements
