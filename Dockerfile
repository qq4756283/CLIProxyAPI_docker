FROM eceasy/cli-proxy-api:latest
LABEL "language"="go"

# Create necessary directories
RUN mkdir -p /CLIProxyAPI /root/.cli-proxy-api

# Write the config.yaml file
RUN cat > /CLIProxyAPI/config.yaml << 'EOF'
host: ""
port: 8317

tls:
  enable: false
  cert: ""
  key: ""

remote-management:
  allow-remote: false
  secret-key: ""
  disable-control-panel: false
  panel-github-repository: "https://github.com/router-for-me/Cli-Proxy-API-Management-Center"

auth-dir: "~/.cli-proxy-api"

api-keys:
  - "your-api-key-1"
  - "your-api-key-2"
  - "your-api-key-3"

debug: false

pprof:
  enable: false
  addr: "127.0.0.1:8316"

commercial-mode: false
logging-to-file: false
logs-max-total-size-mb: 0
error-logs-max-files: 10
usage-statistics-enabled: false
proxy-url: ""
force-model-prefix: false
passthrough-headers: false
request-retry: 3
max-retry-credentials: 0
max-retry-interval: 30

quota-exceeded:
  switch-project: true
  switch-preview-model: true

routing:
  strategy: "round-robin"

ws-auth: false
nonstream-keepalive-interval: 0
EOF

EXPOSE 8317
CMD ["eceasy/cli-proxy-api"]
