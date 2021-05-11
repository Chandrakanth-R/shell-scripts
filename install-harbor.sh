HOST_IP=16.16.90.91
INSTALLER=harbor-online-installer-v2.0.1.tgz

curl -L "https://github.com/docker/compose/releases/download/1.26.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

wget https://github.com/goharbor/harbor/releases/download/v2.0.1/$INSTALLER

openssl genrsa -out ca.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN="$HOST_IP -key ca.key -out ca.crt

openssl genrsa -out $HOST_IP.key 4096

openssl req -sha512 -new -subj "/C=CN/ST=Beijing/L=Beijing/O=example/OU=Personal/CN="$HOST_IP -key $HOST_IP.key -out $HOST_IP.csr

cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=$HOST_IP
EOF

openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA ca.crt -CAkey ca.key -CAcreateserial -in $HOST_IP.csr -out $HOST_IP.crt

mkdir -p /data/cert
cp $HOST_IP.crt /data/cert/
cp $HOST_IP.key /data/cert/

openssl x509 -inform PEM -in $HOST_IP.crt -out $HOST_IP.cert

mkdir -p /etc/docker/certs.d/$HOST_IP/
cp $HOST_IP.cert /etc/docker/certs.d/$HOST_IP/
cp $HOST_IP.key /etc/docker/certs.d/$HOST_IP/
cp ca.crt /etc/docker/certs.d/$HOST_IP/

systemctl restart docker

tar -xf $INSTALLER

cd harbor*/

# Update harbor.yaml before executing next step

./install.sh --with-chartmuseum