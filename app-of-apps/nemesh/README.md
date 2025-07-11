# nemesh

This project was automatically generated by the Backstage Kubernetes Project template.

## Project Details

- **Project Name:** `nemesh`
- **Created:** `2025-07-04T08:33:46Z`

## Resources Created

### ArgoCD Application
- **Name:** `nemesh`
- **Path:** `./app-of-apps/nemesh/`
- **Auto-sync:** Enabled with prune

### Kubernetes Namespace
- **Name:** `nemesh`
- **Labels:** Project metadata and creation info

## Directory Structure

```
app-of-apps/nemesh/
├── argocd-application.yaml    # ArgoCD Application resource
├── namespace.yaml             # Kubernetes Namespace resource
└── README.md                  # This file
```

## Next Steps

1. **Review and merge** the pull request
2. **Apply ArgoCD Application** to your cluster:
   ```bash
   kubectl apply -f app-of-apps/nemesh/argocd-application.yaml
   ```
3. **Verify namespace creation**:
   ```bash
   kubectl get namespace nemesh
   ```
4. **Check ArgoCD dashboard** for application status
5. **Add your application manifests** to this directory

## Usage

Deploy your applications by adding Kubernetes manifests to this directory. ArgoCD will automatically sync them to the `nemesh` namespace.

Example:
```bash
# Add your deployment files
echo "apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  namespace: nemesh
# ... rest of your deployment" > app-of-apps/nemesh/my-app-deployment.yaml
```

---

*Generated by Backstage Template on 2025-07-04T08:33:46Z*
