FROM jetbrains/teamcity-minimal-agent:2024.03.3
ENV DEBIAN_FRONTEND=noninteractive

USER root

RUN apt-get -qqy update && apt-get install -y --no-install-recommends \
    bzip2 \
    apt-utils \
    gconf2 \
    unzip \
    curl \
    build-essential \
    libfontconfig \
    python3-crcmod \
    gnupg2 \
    apt-transport-https \
    openssh-client \
    zip \
    wget \
    git \
    libgtk2.0-0 \
    libgtk-3-0 \
    libgbm-dev \
    libnotify-dev \
    libnss3 \
    libxss1 \
    libasound2 \
    libxtst6 \
    xauth \
    xvfb

RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb
RUN wget https://storage.googleapis.com/chrome-for-testing-public/128.0.6613.84/linux64/chromedriver-linux64.zip && unzip ./chromedriver-linux64.zip && mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && chown 1000:1000 /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver

ENV CLOUD_SDK_VERSION 410.0.0-0

# from https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=de
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk=${CLOUD_SDK_VERSION} google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION} google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION} google-cloud-sdk-app-engine-python=${CLOUD_SDK_VERSION} -y

# Datastore/emulator configuration
# These were breaking Objectify 5 already, only uncomment when all our code can use the emulator
# ENV DATASTORE_DATASET=praisemanager-dataset
# ENV DATASTORE_EMULATOR_HOST=localhost:8881
# ENV DATASTORE_EMULATOR_HOST_PATH=localhost:8881/datastore
# ENV DATASTORE_HOST=http://localhost:8881
# ENV DATASTORE_PROJECT_ID=praisemanager

RUN gcloud config set core/disable_usage_reporting true --installation && \
    gcloud config set component_manager/disable_update_check true --installation && \
    gcloud config set metrics/environment github_docker_image --installation

ENV NVM_VERSION v0.35.3

# For karma
ENV CHROME_BIN=/usr/bin/google-chrome-stable

USER buildagent
RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh
