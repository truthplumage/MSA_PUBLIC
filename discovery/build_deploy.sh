./gradlew clean bootjar
docker build -t discovery:1.0.0 .
minikube image load discovery:1.0.0
kubectl apply -f ./k8s/discovery.yaml
kubectl get pod -o wide