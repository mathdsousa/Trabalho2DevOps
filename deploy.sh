#!/bin/bash

set -e  # Interrompe em caso de erro
set -x  # Exibe os comandos sendo executados

# Inicia o Minikube
minikube start

# Configura o ambiente Docker para usar o Minikube
eval $(minikube docker-env)

# Faz o build das imagens Docker
docker build -t trabalho2devops-backend:latest ./backend
docker build -t trabalho2devops-frontend:latest ./frontend
docker build -t trabalho2devops-image-service:latest ./image-service
docker build -t trabalho2devops-send-email:latest ./send-email

# Carrega a imagem do Ingress Controller no Minikube (caso necessário)
minikube image load k8s.gcr.io/ingress-nginx/controller:v1.9.4

# Habilita os addons essenciais
minikube addons enable ingress
minikube addons enable dashboard
minikube addons enable metrics-server

# Exibe o IP do Minikube para ser colocado no /etc/hosts
minikube_ip=$(minikube ip)
echo -e "\nAdicione a seguinte linha ao seu /etc/hosts (como root):"
echo -e "${minikube_ip}\tcatlog.k8s.local\n"


# Aguarda o usuário confirmar edição do hosts
read -p "Pressione ENTER após editar o /etc/hosts e esperar um pouco para o ingress-nginx-controller-admission subir"

# Aplica o Helm chart
helm install catlog ./catlog-chart 

echo -e "\n Espere todos os pods rodarem antes de acessar catlog.k8s.local"

minikube dashboard &