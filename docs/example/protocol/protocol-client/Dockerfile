# Build stage for the example client
FROM client-image AS client

FROM base-image

# Add client binary from client build stage
COPY --from=client /usr/bin/client /root/bin/client

# Copy protocol files
COPY templates/Caddyfile.template /var/lib/babel/templates/
COPY templates/config-alloy.template /var/lib/babel/templates/
COPY aux.rhai /var/lib/babel/plugin/
COPY main.rhai /var/lib/babel/plugin/