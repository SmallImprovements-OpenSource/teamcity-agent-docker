FROM jetbrains/teamcity-minimal-agent:2022.04.3
ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN apt-get -qqy update &&  apt-get install -y --no-install-recommends\
    chromium-browser\
    chromium-driver \
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
    git;

RUN snap install chromium

ENV CLOUD_SDK_VERSION 376.0.0

# from https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=de
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -qqy && \
    apt-get install -qqy \
    google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
    google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
    google-cloud-sdk-datastore-emulator=${CLOUD_SDK_VERSION}-0

# datastore/emulator configuration
# these were breaking objectify 5 already, only uncomment when all our code can use the emultaor
#ENV DATASTORE_DATASET=praisemanager-dataset
#ENV DATASTORE_EMULATOR_HOST=localhost:8881
#ENV DATASTORE_EMULATOR_HOST_PATH=localhost:8881/datastore
#ENV DATASTORE_HOST=http://localhost:8881
#ENV DATASTORE_PROJECT_ID=praisemanager


RUN gcloud config set core/disable_usage_reporting true --installation && \
    gcloud config set component_manager/disable_update_check true --installation && \
    gcloud config set metrics/environment github_docker_image --installation

ENV NVM_VERSION v0.35.3

#For karma
ENV CHROME_BIN=/usr/bin/chromium-browser

USER buildagent
RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh
