#!/bin/bash
THIS_NAME=example

KEY_FILE=./.${THIS_NAME}nc-plain-secrets.yaml
SECRET_FILE=./${THIS_NAME}nc-secrets.yaml 

phile_checkr () {
if [[ $# -eq 1 ]]; then
TARGET_FILE=$1
  if [[ -f $TARGET_FILE ]]; then
    echo "$TARGET_FILE exists, leaving untouched"
    exit 0
  fi
else
  echo "Wrong number of args! $#"
  echo "usage: $0 file_to_check"
fi
}

if [[ ! $1 == '--force' ]]; then
  phile_checkr $SECRET_FILE
  phile_checkr $KEY_FILE
fi

liner () {
  echo "  $1 $2" >> $SECRET_FILE
  echo "  $1 $3" >> $KEY_FILE
}

munger () {
  if [[ $# -eq 2 ]]; then
    based=$(echo -n $2 | base64)
    liner $1 $based $2
  else
    SECRET=$(openssl rand -base64 33)
    based=$(echo -n $SECRET | base64)
    liner $1 $based $SECRET
  fi
}

# make the headers
cat << EOF > $SECRET_FILE
apiVersion: v1
kind: Secret
metadata:
  name: ${THIS_NAME}nc-secrets
  namespace: ${THIS_NAME}
type: Opaque
data:
EOF
cat << EOF > $KEY_FILE
apiVersion: v1
kind: Secret
metadata:
  name: ${THIS_NAME}nc-secrets
  namespace: ${THIS_NAME}
type: Opaque
stringData:
EOF
# munge the date
munger  argocdadmin-password: 
munger  collabora-username: collabadmin
munger  collabora-password: 
munger  db-password: 
munger  db-hostname: "${THIS_NAME}nc-postgres:5432"
munger  db-name: ${THIS_NAME}ncdb
munger  db-username: ${THIS_NAME}nc
munger  db-admin-pass: 
munger  nextcloud-username: ncadmin
munger  nextcloud-password: 
munger  nextcloud-token: 
munger  redis-pass: 
munger  replicationUserPassword:
munger  smtp-username: mailadmin@${THIS_NAME}.com
munger  smtp-password: 
munger  smtp-host: mail.${THIS_NAME}.com
