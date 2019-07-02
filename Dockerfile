FROM jetbrains/teamcity-minimal-agent:2019.1.1

RUN apt-get -qqy update &&  apt-get install -y --no-install-recommends\
        chromium-bsu\
        bzip2 \
        apt-utils \
        gconf2 \
        unzip \
        curl \
        libfontconfig \
        python-crcmod \
        gnupg2 \
        apt-transport-https \
        lsb-release \
        openssh-client \
        git;

ENV CLOUD_SDK_VERSION 252.0.0

RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk-$(lsb_release -cs) main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
        && curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
        && apt-get update -qqy && apt-get install -qqy \
             google-cloud-sdk=${CLOUD_SDK_VERSION}-0 \
             google-cloud-sdk-app-engine-java=${CLOUD_SDK_VERSION}-0 \
        && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

ENV CHROME_DRIVER_VERSION 2.45
RUN curl -Ls https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip > ~/chromedriver.zip \
    && unzip ~/chromedriver.zip -d /usr/bin \
    && rm ~/chromedriver.zip

RUN gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image

ENV NVM_VERSION v0.34.0

#For karma
ENV CHROME_BIN=/usr/bin/chromium
RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh