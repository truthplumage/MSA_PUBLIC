./gradlew clean bootjar
docker build -t config:1.0.0 .
minikube image load config:1.0.0
kubectl apply -f ./k8s/config.yaml
kubectl get pod -o wide