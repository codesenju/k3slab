# Cilium - eBPF Networking & Security

## Install Cilium CLI

```bash
CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
CLI_ARCH=amd64
if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-${CLI_ARCH}-tar.gz
sudo tar xzvfC cilium-${CLI_ARCH}-tar.gz /usr/local/bin
rm cilium-${CLI_ARCH}-tar.gz
```

## Install Cilium

```bash
cilium install
```

## Verify Installation

```bash
cilium status
cilium connectivity test
```

## Enable Hubble (Observability)

```bash
cilium hubble enable
cilium hubble disable # to disable
```

## Port Forward for Hubble UI

```bash
cilium hubble ui &
kubectl port-forward -n kube-system svc/hubble-ui 12000:80
```

## Network Policy Example

```yaml
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: nginx-ingress
spec:
  endpointSelector:
    matchLabels:
      app: nginx
  ingress:
  - fromEndpoints:
    - matchLabels:
        role: frontend
    toPorts:
    - ports:
      - port: "80"
        protocol: TCP
```
