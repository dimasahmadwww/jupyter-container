# Use a slim Python image
FROM python:3.13-slim

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
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
    && rm -rf /var/lib/apt/lists/*

# Install Jupyter and common data science packages
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir \
    jupyter \
    numpy \
    pandas \
    matplotlib \
    seaborn \
    scikit-learn \
    && jupyter notebook --generate-config

# Create a working directory
COPY ./samples /notebooks/samples
WORKDIR /notebooks

# Expose Jupyter port
EXPOSE 8888

# Bash script to configure and run Jupyter Notebook
RUN printf "#!/bin/bash\n" > /opt/jupyter_runner.sh && \
    printf "jupyter notebook --ip=\${JUPYTER_IP:-0.0.0.0} --port=\${PORT:-8888} --no-browser --allow-root --NotebookApp.password=\$(python -c \"from jupyter_server.auth import passwd; print(passwd('riffloric'))\")\n" >> /opt/jupyter_runner.sh

# Make the bash script executable
RUN chmod +x /opt/jupyter_runner.sh

# Start Jupyter notebook
CMD ["sh", "-c", "/opt/jupyter_runner.sh"]
