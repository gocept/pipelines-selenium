FROM ubuntu:16.04

# Install base dependencies
RUN apt-get update \
    && apt-get install -y \
        wget \
        xvfb \
        mercurial \
        maven \
        ant \
        ssh-client \
        unzip \
        iputils-ping \
        python-pip \
        python-dev \
        openjdk-8-jre-headless \
        libxi6 \
        libgconf-2-4 \
        zip \
        libxcomposite-dev \
        libasound2 \
        libatk1.0-0 \
        libatomic1 \
        libc6 \
        libc6 \
        libc6 \
        libcairo-gobject2 \
        libcairo2 \
        libcairo2 \
        libdbus-1-3 \
        libdbus-glib-1-2 \
        libffi6 \
        libfontconfig1 \
        libfreetype6 \
        libfreetype6 \
        libgcc1 \
        libgcc1 \
        libgcc1 \
        libgdk-pixbuf2.0-0 \
        libglib2.0-0 \
        libglib2.0-0  \
        libgtk-3-0 \
        libgtk2.0-0 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libstartup-notification0  \
        libstdc++6 \
        libstdc++6 \
        libx11-6 \
        libx11-xcb1 \
        libxcb-shm0 \
        libxcb1  \
        libxcomposite1 \
        libxdamage1 \
        libxext6 \
        libxfixes3 \
        libxrender1 \
        libxt6  \
        lsb-release \
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
ENV FIREFOX_VERSION=45.0 \
    FIREFOX_DIR=/usr/bin/firefox
ENV FIREFOX_FILENAME=$FIREFOX_DIR/firefox.tar.bz2 \
    PATH=$FIREFOX_DIR:$PATH \
    GOCEPT_WEBDRIVER_FF_BINARY=$FIREFOX_DIR/firefox-bin

# Download the firefox of specified version from Mozilla and untar it.
RUN mkdir $FIREFOX_DIR; \
    wget -q --continue --output-document $FIREFOX_FILENAME "https://ftp.mozilla.org/pub/firefox/releases/${FIREFOX_VERSION}/linux-x86_64/en-US/firefox-${FIREFOX_VERSION}.tar.bz2"; \
    tar -xaf "$FIREFOX_FILENAME" --strip-components=1 --directory "$FIREFOX_DIR"; \
    rm $FIREFOX_FILENAME


RUN wget -q -N http://selenium-release.storage.googleapis.com/2.53/selenium-server-standalone-2.53.1.jar -P ~/; \
    mv -f ~/selenium-server-standalone-2.53.1.jar /usr/local/share/; \
    chmod +x /usr/local/share/selenium-server-standalone-2.53.1.jar; \
    ln -s /usr/local/share/selenium-server-standalone-2.53.1.jar /usr/local/bin/selenium-server-standalone-2.53.1.jar

RUN echo "#!/usr/bin/env bash" >> /usr/local/bin/selenium-server; \
    echo "java -jar /usr/local/share/selenium-server-standalone-2.53.1.jar -Dwebdriver.firefox.bin=$GOCEPT_WEBDRIVER_FF_BINARY" >> /usr/local/bin/selenium-server; \
    chmod +x /usr/local/bin/selenium-server

RUN pip install tox


RUN echo "selenium-server >/dev/null 2>/dev/null &" >> /root/.bashrc; \
    echo "Xvfb :99 -ac >/dev/null 2>/dev/null &" >> /root/.bashrc

# Create dirs and users
RUN mkdir -p /opt/atlassian/bitbucketci/agent/build \
    && sed -i '/[ -z \"PS1\" ] && return/a\\ncase $- in\n*i*) ;;\n*) return;;\nesac' /root/.bashrc \
    && useradd --create-home --shell /bin/bash --uid 1000 pipelines

WORKDIR /opt/atlassian/bitbucketci/agent/build

ENTRYPOINT ["/bin/bash"]
