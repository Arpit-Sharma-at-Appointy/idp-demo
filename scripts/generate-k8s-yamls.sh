#!/bin/bash

# Script to generate Kubernetes YAML files
# Usage: ./generate-k8s-yamls.sh [config_file]

set -e

# Default config file
CONFIG_FILE="${1:-config.env}"

# Check if config file exists
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found!"
    echo "Usage: $0 [config_file]"
    exit 1
fi

# Source the configuration file
echo "Loading configuration from: $CONFIG_FILE"
source "$CONFIG_FILE"

# Validate required variables
required_vars=("DEPLOYMENT_NAME" "IMAGE_NAME" "IMAGE_TAG" "PORT" "NAMESPACE" "SERVICE_NAME" "VS_NAME")
missing_vars=()

for var in "${required_vars[@]}"; do
    if [[ -z "${!var}" ]]; then
        missing_vars+=("$var")
    fi
done

if [[ ${#missing_vars[@]} -gt 0 ]]; then
    echo "Error: Missing required variables:"
    printf '  %s\n' "${missing_vars[@]}"
    exit 1
fi

# Create output directory if it doesn't exist
OUTPUT_DIR="${2:-generated-yamls}"
mkdir -p "$OUTPUT_DIR"

echo "Generating YAML files with the following configuration:"
echo "  Deployment Name: $DEPLOYMENT_NAME"
echo "  Image: $IMAGE_NAME:$IMAGE_TAG"
echo "  Port: $PORT"
echo "  Namespace: $NAMESPACE"
echo "  Service Name: $SERVICE_NAME"
echo "  VirtualService Name: $VS_NAME"
echo ""

# Generate deployment.yaml
cat > "$OUTPUT_DIR/deployment.yaml" << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: $DEPLOYMENT_NAME
  namespace: $NAMESPACE
  labels:
    app: $DEPLOYMENT_NAME
spec:
  replicas: 1
  selector:
    matchLabels:
      app: $DEPLOYMENT_NAME
  template:
    metadata:
      labels:
        app: $DEPLOYMENT_NAME
    spec:
      containers:
      - name: $DEPLOYMENT_NAME
        image: $IMAGE_NAME:$IMAGE_TAG
        ports:
        - containerPort: $PORT
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
EOF

# Generate service.yaml
cat > "$OUTPUT_DIR/service.yaml" << EOF
apiVersion: v1
kind: Service
metadata:
  name: $SERVICE_NAME
  namespace: $NAMESPACE
  labels:
    app: $DEPLOYMENT_NAME
spec:
  selector:
    app: $DEPLOYMENT_NAME
  ports:
  - name: http
    port: $PORT
    targetPort: $PORT
    protocol: TCP
  type: ClusterIP
EOF

# Generate virtualservice.yaml
cat > "$OUTPUT_DIR/virtualservice.yaml" << EOF
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: $VS_NAME
  namespace: $NAMESPACE
spec:
  hosts:
  - ${DEPLOYMENT_NAME}.idp.appointy.com
  gateways:
  - istio-system/gateway
  http:
  - match:
    - uri:
        prefix: /
  - route:
    - destination:
        host: $SERVICE_NAME
        port:
          number: $PORT
EOF

echo "YAML files generated successfully in '$OUTPUT_DIR/' directory:"
echo "  - deployment.yaml"
echo "  - service.yaml"
echo "  - virtualservice.yaml"
echo ""
echo "To apply these resources:"
echo "  kubectl apply -f $OUTPUT_DIR/"