FROM jetbrains/teamcity-minimal-agent:2019.2.2

RUN apt-get -qqy update &&  apt-get install -y --no-install-recommends\
        chromium-browser \
        chromium-driver \
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
        git && rm -rf /var/lib/apt/lists/*;

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install  -y --no-install-recommends yarn

#For karma
ENV CHROME_BIN=/usr/bin/chromium-browser

USER buildagent

ENV CLOUD_SDK_VERSION 288.0.0
RUN curl -Ls https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz > /tmp/gcloud-sdk.tar.gz \
    && tar -xzf /tmp/gcloud-sdk.tar.gz -C ~/ \
    && rm /tmp/gcloud-sdk.tar.gz

RUN ~/google-cloud-sdk/install.sh --quiet  --additional-components=app-engine-java --path-update true  --command-completion true --usage-reporting false

RUN ~/google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true --installation && \
    ~/google-cloud-sdk/bin/gcloud config set metrics/environment github_docker_image --installation

ENV NVM_VERSION v0.35.3
RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh