FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Create a non-root user
ARG USERNAME=webuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Add Mozilla PPA for Firefox
RUN apt-get update && apt-get install -y software-properties-common && \
    add-apt-repository ppa:mozillateam/ppa -y

# Set Firefox package preferences
RUN echo '\
Package: firefox* \n\
Pin: release o=Ubuntu* \n\
Pin-Priority: -1 \n\
\n\
Package: firefox* \n\
Pin: release o=LP-PPA-mozillateam \n\
Pin-Priority: 1001 \n\
' > /etc/apt/preferences.d/mozilla-firefox

# Install basic utilities and dependencies
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    unzip \
    python3 \
    python3-pip \
    firefox \
    chromium-browser \
    java-common \
    default-jre \
    nmap \
    whatweb \
    sqlmap \
    ruby \
    ruby-dev \
    build-essential \
    libpcap-dev \
    x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Install latest Go version
RUN curl -OL https://golang.org/dl/go1.21.6.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go1.21.6.linux-amd64.tar.gz && \
    rm go1.21.6.linux-amd64.tar.gz

# Set Go environment variables
ENV GOROOT=/usr/local/go
ENV GOPATH=/home/$USERNAME/go
ENV PATH=$GOPATH/bin:$GOROOT/bin:$PATH

# Create Go workspace directory
RUN mkdir -p /home/$USERNAME/go/bin && \
    chown -R $USERNAME:$USERNAME /home/$USERNAME/go

# Install Go-based tools
RUN go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest && \
    go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest && \
    go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest && \
    go install -v github.com/ffuf/ffuf@latest && \
    go install -v github.com/lc/gau/v2/cmd/gau@latest && \
    go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest && \
    go install -v github.com/owasp-amass/amass/v3/...@master

# Install Arjun
RUN pip3 install arjun

# Install feroxbuster
RUN curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash

# Download and install Burp Suite versions
RUN mkdir -p /opt/burpsuite && \
    wget "https://portswigger-cdn.net/burp/releases/download?product=community&version=1.7.36&type=jar" -O /opt/burpsuite/burpsuite_old.jar && \
    wget "https://portswigger-cdn.net/burp/releases/download?product=community&type=jar" -O /opt/burpsuite/burpsuite_new.jar

# Create shortcuts for Burp Suite
RUN echo '#!/bin/bash\njava -jar /opt/burpsuite/burpsuite_old.jar' > /usr/local/bin/burpsuite-old && \
    echo '#!/bin/bash\njava -jar /opt/burpsuite/burpsuite_new.jar' > /usr/local/bin/burpsuite-new && \
    chmod +x /usr/local/bin/burpsuite-old /usr/local/bin/burpsuite-new

# Create a welcome message
RUN echo 'echo "╔════════════════════════════════════════╗"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "║        Welcome to Web Tools!           ║"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "╚════════════════════════════════════════╝\n"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "🛠️  Available Tools:"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "──────────────────\n"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "🔍 Reconnaissance:"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • subfinder   - Subdomain discovery tool"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • amass      - Network mapping of attack surfaces"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • nmap       - Network exploration tool"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • httpx      - HTTP toolkit"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "\n🌐 Web Testing:"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • burpsuite-old  - Burp Suite 1.7.36"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • burpsuite-new  - Latest Burp Suite"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • firefox        - Firefox Browser"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • chromium       - Chromium Browser"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "\n🔨 Scanning & Fuzzing:"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • ffuf       - Fast web fuzzer"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • feroxbuster - Fast content discovery tool"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • nuclei     - Vulnerability scanner"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • naabu      - Port scanning"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • whatweb    - Web scanner"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • sqlmap     - SQL injection"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "   • Arjun      - HTTP parameter discovery"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "\n📂 Workspace: /home/$USERNAME/workspace\n"' >> /home/$USERNAME/.bashrc && \
    echo 'echo "💡 Tip: Use the workspace directory to persist your files.\n"' >> /home/$USERNAME/.bashrc

# Set ownership for the user
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# Set browser environment variables
ENV BROWSER=/usr/bin/firefox

# Switch to the non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

CMD ["/bin/bash"]