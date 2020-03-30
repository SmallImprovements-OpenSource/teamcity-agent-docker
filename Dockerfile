FROM jetbrains/teamcity-minimal-agent:2019.2.2

RUN apt-get -qqy update &&  apt-get install -y --no-install-recommends\
        chromium-browser\
        bzip2 \
        apt-utils \
        gconf2 \
        unzip \
        curl \
        build-essential \
        libfontconfig \
        python-crcmod \
        gnupg2 \
        apt-transport-https \
        openssh-client \
        zip \
        git;

ENV CLOUD_SDK_VERSION 286.0.0

# from https://cloud.google.com/sdk/docs/quickstart-debian-ubuntu?hl=de
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && apt-get update -y && apt-get install google-cloud-sdk=${CLOUD_SDK_VERSION}-0 google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 -y

ENV CHROME_DRIVER_VERSION 80.0.3987.106
RUN curl -Ls https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip > ~/chromedriver.zip \
    && unzip ~/chromedriver.zip -d /usr/bin \
    && chmod +x /usr/bin/chromedriver \
    && rm ~/chromedriver.zip

RUN gcloud config set core/disable_usage_reporting true --installation && \
    gcloud config set component_manager/disable_update_check true --installation && \
    gcloud config set metrics/environment github_docker_image --installation

ENV NVM_VERSION v0.35.3

#For karma
ENV CHROME_BIN=/usr/bin/chromium-browser

USER buildagent
RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh
USER root