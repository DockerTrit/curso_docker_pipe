FROM docker:20.10.14
WORKDIR /root

ARG VENDOR
ARG DESCRIPTION
ARG AUTHORS
ARG NAME
ARG VERSION
ARG REVISION
ARG BUILD_DATE

ENV TF_VER 1.1.4
ENV TFLINT_VER v0.34.1
ENV KUBECTL_VER v1.23.3
ENV AZURE_CLI_VER 2.32.0


LABEL org.opencontainers.image.vendor="${VENDOR}" \
      org.opencontainers.image.description="${DESCRIPTION}" \
      org.opencontainers.image.authors="${AUTHORS}" \
      org.opencontainers.image.title="${NAME}" \
      org.opencontainers.image.version="${VERSION}" \
      org.opencontainers.image.revision="${REVISION}" \
      org.opencontainers.image.created="${BUILD_DATE}"

# Manage Users, Folders and Permissions
RUN addgroup -g 1000 app && adduser -D -u 1000 -G app app && \
    mkdir /home/app/.kube && \
    chown app.app -R /home/app

# Install Utils
# hadolint ignore=DL3018
RUN apk add --no-cache \
      jq \
      git \
      bash \
      curl \
      make \
      openssl \
      openssh-client \
      python3 \
      py3-pip \
      # Required by azcopy
      libc6-compat \
      # Required by PowerShell
      ca-certificates  \
      ncurses-terminfo-base \
      krb5-libs \
      libgcc \
      libintl \
      libssl1.1 \
      libstdc++ \
      tzdata \
      userspace-rcu \
      zlib \
      icu-libs \
      util-linux

# Libraries needed to install azure-cli, separated in a "build" apk world
# hadolint ignore=DL3018,DL3013
RUN apk add --no-cache --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev && \
    pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir azure-cli==${AZURE_CLI_VER} && \
    apk del --purge build && \
    az version

# Install Kubectl
RUN curl -sL https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VER}/bin/linux/amd64/kubectl -o /usr/local/bin/kubectl && \
    chmod +x /usr/local/bin/kubectl && \
    kubectl version --client

# Install Terraform
RUN curl -sL https://releases.hashicorp.com/terraform/${TF_VER}/terraform_${TF_VER}_linux_amd64.zip -o terraform.zip  && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    rm -f terraform.zip && \
    terraform version

# Copy .tflint
COPY .tflint.hcl /root
# Install tflint
RUN curl -sL https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VER}/tflint_linux_amd64.zip -o tflint.zip && \
    unzip tflint.zip && \
    mv tflint /usr/local/bin/tflint && \
    chmod +x /usr/local/bin/tflint && \
    rm -f tflint.zip && \
    tflint --init && \
    tflint --version

 
# Install Powershell
RUN curl -sL https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_CLI_VER}/powershell-${POWERSHELL_CLI_VER}-linux-alpine-x64.tar.gz -o powershell.tar.gz && \
    mkdir /opt/powershell && \
    tar -xzf powershell.tar.gz -C /opt/powershell && \
    ln -s /opt/powershell/pwsh /usr/bin/pwsh && \
    rm -f powershell.tar.gz && \
    pwsh -Version

