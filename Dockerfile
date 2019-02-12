FROM ubuntu:16.04

# Install base dependencies
RUN apt-get update \
    && apt-get install -y \
        wget \
        xvfb \
        mercurial \
        ssh-client \
        unzip \
        iputils-ping \
        python-pip \
        python-dev \
        zip \
        firefox \
        chromium-browser \
        software-properties-common \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean -y

RUN add-apt-repository ppa:deadsnakes/ppa -y -u \
    && apt-get install python3.7 -y \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean -y

# Default to UTF-8 file.encoding
ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    LANGUAGE=C.UTF-8

# Xvfb provide an in-memory X-session for tests that require a GUI
ENV DISPLAY=:99


# Set firefox version and installation directory through environment variables.
# Prepend firefox dir to PATH
ENV FIREFOX_DIR=/usr/bin/firefox \
    GECKO_DIR=/usr/bin/gecko_driver \
    GECKO_VERSION=0.24.0 \
    CHROME_DIR=/usr/bin/chrome_driver \
    CHROME_VERSION=2.46

ENV PATH=$FIREFOX_DIR:$GECKO_DIR:$CHROME_DIR:$PATH \
    GOCEPT_WEBDRIVER_FF_BINARY=$FIREFOX_DIR/firefox-bin \
    GECKO_FILENAME=${GECKO_DIR}/geckodriver-v${GECKO_VERSION}-linux64.tar.gz \
    CHROME_FILENAME=${CHROME_DIR}/chromedriver_linux64.zip

# Download the gecko driver for firefox of specified version from Mozilla and
# untar it.
RUN mkdir $GECKO_DIR; \
    wget -q --continue --output-document $GECKO_FILENAME "https://github.com/mozilla/geckodriver/releases/download/v${GECKO_VERSION}/geckodriver-v${GECKO_VERSION}-linux64.tar.gz"; \
    tar -xzf "$GECKO_FILENAME" --directory "$GECKO_DIR"; \
    rm $GECKO_FILENAME

# Download the chrome driver and unzip it.
RUN mkdir $CHROME_DIR; \
    wget -q --continue --output-document $CHROME_FILENAME "https://chromedriver.storage.googleapis.com/${CHROME_VERSION}/chromedriver_linux64.zip"; \
    unzip "$CHROME_FILENAME" -d "$CHROME_DIR"; \
    rm $CHROME_FILENAME

RUN pip install tox

RUN echo "Xvfb :99 -ac >/dev/null 2>/dev/null &" >> /root/.bashrc

# Create dirs and users
RUN mkdir -p /opt/atlassian/bitbucketci/agent/build \
    && sed -i '/[ -z \"PS1\" ] && return/a\\ncase $- in\n*i*) ;;\n*) return;;\nesac' /root/.bashrc \
    && useradd --create-home --shell /bin/bash --uid 1000 pipelines

WORKDIR /opt/atlassian/bitbucketci/agent/build

ENTRYPOINT ["/bin/bash"]
