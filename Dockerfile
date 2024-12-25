# Use a slim Python image
FROM python:3.13-slim

# Set environment variables to allow sudo and apt commands in terminal
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies and additional packages
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    sudo \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    git \
    ffmpeg \
    nodejs \
    npm \
    wget \
    mc \
    imagemagick && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js 23.5.0
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install 23.5.0 && \
    npm install -g pm2

# Install Python libraries
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir \
    jupyter \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn && \
    jupyter notebook --generate-config

# Create a working directory and copy samples
COPY ./samples /notebooks/samples
WORKDIR /notebooks

# Expose Jupyter port
EXPOSE 8888

# Allow terminal access as root with sudo
RUN echo "root ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Bash script to configure and run Jupyter Notebook
RUN printf "#!/bin/bash\n" > /opt/jupyter_runner.sh && \
    printf "jupyter notebook --ip=\${JUPYTER_IP:-0.0.0.0} --port=\${PORT:-8888} --no-browser --allow-root --NotebookApp.password=\$(python -c \"from jupyter_server.auth import passwd; print(passwd('riffloric'))\")\n" >> /opt/jupyter_runner.sh

# Make the bash script executable
RUN chmod +x /opt/jupyter_runner.sh

# Start a shell as root for terminal access, with the option to run Jupyter
CMD ["sh", "-c", "/bin/bash || /opt/jupyter_runner.sh"]
