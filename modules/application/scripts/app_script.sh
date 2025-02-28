#! /bin/bash
apt-get -y update
apt-get -y install nginx
apt-get -y install jq

REACT_APP_APIHOSTPORT=${REACT_APP_APIHOSTPORT}
MONGODB_PRIVATEIP=${MONGODB_PRIVATEIP}

mkdir -p /tmp/cloudacademy-app
cd /tmp/cloudacademy-app

echo ===========================
echo FRONTEND - download latest release and install...
mkdir -p ./voteapp-frontend-react-2023
pushd ./voteapp-frontend-react-2023
curl -OL https://gitlab.com/terraform1382002/voteapp_2025/-/raw/main/release-3.2.1.tar.gz
INSTALL_FILENAME=$(basename https://gitlab.com/terraform1382002/voteapp_2025/-/raw/main/release-3.2.1.tar.gz)
tar -xvzf $INSTALL_FILENAME
rm -rf /var/www/html
cp -R build /var/www/html
cat > /var/www/html/env-config.js << EOFF
window._env_ = {REACT_APP_APIHOSTPORT: "$REACT_APP_APIHOSTPORT"}
EOFF
popd

echo ===========================
echo API - download latest release, install, and start...
mkdir -p ./voteapp-api-go
pushd ./voteapp-api-go
curl -OL https://gitlab.com/terraform1382002/voteapp_2025/-/raw/main/release-1.2.2.linux-amd64.tar.gz
INSTALL_FILENAME=$(basename https://gitlab.com/terraform1382002/voteapp_2025/-/raw/main/release-1.2.2.linux-amd64.tar.gz)
tar -xvzf $INSTALL_FILENAME
#start the API up...
MONGO_CONN_STR=mongodb://$MONGODB_PRIVATEIP:27017/langdb ./api &
popd

systemctl restart nginx
systemctl status nginx
echo fin v1.00!