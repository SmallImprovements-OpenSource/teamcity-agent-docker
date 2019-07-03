FROM jetbrains/teamcity-minimal-agent:2019.1.1

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
        lsb-release \
        openssh-client \
        git && \
        rm -rf /var/lib/apt/lists/* /var/cache/apt/*;
ENV CHROME_DRIVER_VERSION 75.0.3770.90
RUN curl -Ls https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip > ~/chromedriver.zip \
    && unzip ~/chromedriver.zip -d /usr/bin \
    && chmod +x /usr/bin/chromedriver \
    && rm ~/chromedriver.zip;

ENV CLOUD_SDK_VERSION 252.0.0

RUN curl https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${CLOUD_SDK_VERSION}-linux-x86_64.tar.gz -o /tmp/sdk.tar.gz && \
    tar -xzf /tmp/sdk.tar.gz  -C /opt/ && \
    /opt/google-cloud-sdk/install.sh --quiet --additional-components app-engine-java && \
    rm /tmp/sdk.tar.gz;

#For karma
ENV CHROME_BIN=/usr/bin/chromium-browser

USER buildagent

RUN /opt/google-cloud-sdk/bin/gcloud config set core/disable_usage_reporting true && \
    /opt/google-cloud-sdk/bin/gcloud config set component_manager/disable_update_check true && \
    /opt/google-cloud-sdk/bin/gcloud config set metrics/environment github_docker_image

ENV NVM_VERSION v0.34.0
RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh;

RUN echo "export NVM_DIR="$HOME/.nvm"" >> ~/.bashrc && \
    echo ". \$NVM_DIR/nvm.sh" >> ~/.bashrc && \
    echo ". /opt/google-cloud-sdk/path.bash.inc" >> /home/buildagent/.bashrc;

USER root