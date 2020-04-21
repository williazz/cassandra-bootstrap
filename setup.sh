# TO RUN:
# sudo sh setup.sh PRIV_IP

PRIV_IP=$1
SEEDS="172.31.14.73,172.31.15.44"

BUCKET=twt-clone-v0
CLUSTER=twt_clone

# Install Cassandra

echo "deb https://downloads.apache.org/cassandra/debian 311x main" | tee -a /etc/apt/sources.list.d/cassandra.sources.list

curl https://downloads.apache.org/cassandra/KEYS | apt-key add -

apt-get update

apt-get install -y cassandra

# Change clustername

service cassandra start

cqlsh -e "UPDATE system.local SET cluster_name = '$CLUSTER' where key='local';"

nodetool flush

service cassandra stop

# Get YAML Template

cd /etc/cassandra/

mv cassandra.yaml cassandra.yaml.bak

curl https://$BUCKET.s3-us-west-1.amazonaws.com/cassandra.yaml -o cassandra.yaml

sed -i "s/EDIT_ME/$PRIV_IP/g" cassandra.yaml

sed -i "s/INSERT_SEEDS/\"$SEEDS\"/g" cassandra.yaml

# Init Cassandra

service cassandra start

nodetool status