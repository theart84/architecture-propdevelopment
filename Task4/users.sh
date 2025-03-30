#!/bin/bash

users=("DevOps" "TeamLeader" "Developer" "QA")

if [[ ! -f kubernetes-ca.crt || ! -f kubernetes-ca.key ]]; then
  echo "Файлы CA не найдены!"
  exit 1
fi

for user in "${users[@]}"; do
  echo "Генерация сертификатов для ${user}..."

  openssl genrsa -out ${user}.key 2048
  openssl req -new -key ${user}.key -out ${user}.csr -subj "/CN=${user}/O=${user}-group"

  openssl x509 -req -in ${user}.csr -CA kubernetes-ca.crt -CAkey kubernetes-ca.key -CAcreateserial -out ${user}.crt -days 365

  kubectl config set-credentials ${user} --client-certificate=${user}.crt --client-key=${user}.key
  kubectl config set-context ${user}-context --cluster=kubernetes --user=${user}

  echo "Пользователь ${user} добавлен."
done
