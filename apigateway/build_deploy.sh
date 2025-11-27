./gradlew clean bootjar
docker build -t apigateway:1.0.0 .
minikube image load apigateway:1.0.0
kubectl apply -f ./k8s/apigateway.yaml
kubectl get pod -o wide