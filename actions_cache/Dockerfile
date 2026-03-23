FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

# Install tools required by action-versions scripts
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    git \
    jq \
    unzip \
    tar \
    gzip \
    rsync \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /warmer

COPY scripts/warm-cache.sh /warmer/warm-cache.sh
COPY scripts/entrypoint.sh /warmer/entrypoint.sh
COPY actions-list.txt /warmer/actions-list.txt

RUN chmod +x /warmer/warm-cache.sh /warmer/entrypoint.sh

# Default cache destination – overridable via env at runtime
ENV ACTIONS_RUNNER_ACTION_ARCHIVE_CACHE=/home/runner/action-archive-cache
ENV ACTIONS_LIST_FILE=/warmer/actions-list.txt

ENTRYPOINT ["/warmer/entrypoint.sh"]
