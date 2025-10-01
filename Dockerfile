FROM ubuntu:22.04-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates wget tar gzip \
    && rm -rf /var/lib/apt/lists/*

# Install Prometheus
ENV PROM_VERSION=3.6.0
RUN wget https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz \
    && tar -xzf prometheus-${PROM_VERSION}.linux-amd64.tar.gz \
    && mv prometheus-${PROM_VERSION}.linux-amd64 /opt/prometheus \
    && rm prometheus-${PROM_VERSION}.linux-amd64.tar.gz

# Install Grafana
ENV GRAF_VERSION=12.2.0
RUN wget https://dl.grafana.com/oss/release/grafana-${GRAF_VERSION}.linux-amd64.tar.gz \
    && tar -xzf grafana-${GRAF_VERSION}.linux-amd64.tar.gz \
    && mv grafana-${GRAF_VERSION} /opt/grafana \
    && rm grafana-${GRAF_VERSION}.linux-amd64.tar.gz

# Final runtime image
FROM ubuntu:22.04-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libfontconfig1 libpango1.0-0 libgtk-3-0 && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/prometheus /opt/prometheus
COPY --from=builder /opt/grafana /opt/grafana

# Expose ports
EXPOSE 9090 3000

# A simple entrypoint that launches both (used tini)
RUN apt-get update && apt-get install -y --no-install-recommends tini && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]

CMD ["/bin/sh", "-c", "/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml & /opt/grafana/bin/grafana-server --config=/opt/grafana/conf/grafana.ini"]