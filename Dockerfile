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

RUN apt-get install -y --no-install-recommends chromium-browser
RUN wget --quiet https://storage.googleapis.com/chrome-for-testing-public/128.0.6613.84/linux64/chromedriver-linux64.zip && unzip ./chromedriver-linux64.zip && mv chromedriver-linux64/chromedriver /usr/bin/chromedriver && chown 1000:1000 /usr/bin/chromedriver && chmod +x /usr/bin/chromedriver

ENV CLOUD_SDK_VERSION 546.0.0
ENV PYTHON_VERSION 3.11
ENV PYTHON_PATCH_VERSION $PYTHON_VERSION.14
ENV CLOUDSDK_PYTHON /usr/local/bin/python$PYTHON_VERSION

# Python >= 3.9 is required by Google Cloud SDK
RUN apt install -y libreadline-dev libncursesw5-dev libssl-dev libsqlite3-dev tk-dev libgdbm-dev libc6-dev libbz2-dev libffi-dev zlib1g-dev && wget --quiet https://www.python.org/ftp/python/${PYTHON_PATCH_VERSION}/Python-${PYTHON_PATCH_VERSION}.tgz && tar -xf Python-${PYTHON_PATCH_VERSION}.tgz && cd Python-${PYTHON_PATCH_VERSION} && ./configure --enable-optimizations && make -j4 && make altinstall
RUN $CLOUDSDK_PYTHON --version

# JDK 21+ is required by the Google Cloud SDK
RUN apt-get install -y --no-install-recommends openjdk-21-jdk
RUN mv /opt/java/openjdk /home/buildagent/jre
RUN ln -s /usr/lib/jvm/java-1.21.0-openjdk-* /opt/java/openjdk
RUN java --version

USER buildagent

# More recent versions of Google Cloud SDK do not seem to be available for Ubuntu 20.04 on their PPA.
# We therefore use versioned archives to install the correct version.
# For Google Cloud SDK to be available to non-root users, we need to install it as buildagent
RUN cd /home/buildagent && wget --quiet https://storage.googleapis.com/cloud-sdk-release/google-cloud-cli-${CLOUD_SDK_VERSION}-linux-$(uname -m | sed 's/aarch64/arm/').tar.gz && tar -xzf ./google-cloud-cli-${CLOUD_SDK_VERSION}-linux-$(uname -m | sed 's/aarch64/arm/').tar.gz
RUN cd /home/buildagent && ./google-cloud-sdk/install.sh --additional-components app-engine-java cloud-datastore-emulator cloud-firestore-emulator app-engine-python
ENV PATH="$PATH:/home/buildagent/google-cloud-sdk/bin"
RUN gcloud --version

RUN gcloud config set core/disable_usage_reporting true --installation && \
    gcloud config set component_manager/disable_update_check true --installation && \
    gcloud config set metrics/environment github_docker_image --installation

ENV NVM_VERSION v0.35.3

RUN curl -so- https://raw.githubusercontent.com/creationix/nvm/$NVM_VERSION/install.sh | sh
