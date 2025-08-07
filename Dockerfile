# OpenShift-optimized Dockerfile for Knowledge Extraction AI Agent
# Uses Red Hat Universal Base Image (UBI) for CSC Rahti 2 compatibility
FROM registry.access.redhat.com/ubi9/python-312:latest

# Metadata for Red Hat certification and OpenShift
LABEL name="knowledge-extraction-ai-agent" \
      vendor="Knowledge Extraction Team" \
      version="1.0.0" \
      release="1" \
      summary="AI-powered knowledge extraction from documents using OpenAI and Claude" \
      description="Streamlit-based service providing document parsing and knowledge extraction using various AI models"

# Only keep essential environment variable for containers
ENV PYTHONUNBUFFERED=1

# Set work directory (using default user's home which is writable)
WORKDIR /opt/app-root/src

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create Use-cases directory in a location where we have write permissions
# /opt/app-root/src is writable by default in UBI images
RUN mkdir -p /opt/app-root/src/Use-cases && \
    chmod 775 /opt/app-root/src/Use-cases

# Expose port (Streamlit default is 8501)
EXPOSE 8501

# The UBI image already runs as non-root user (UID 1001)
# No need to explicitly set USER

# Command to run the application
CMD ["streamlit", "run", "ui_app.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true", "--server.fileWatcherType=none"]