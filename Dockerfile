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

# PYTHONUNBUFFERED=1 is USEFUL:
# - Ensures Python stdout/stderr appears immediately in container logs
# - Important for debugging and monitoring
# - Prevents Python output buffering
ENV PYTHONUNBUFFERED=1

# Set work directory (using OpenShift standard location)
WORKDIR /opt/app-root/src

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
# --no-cache-dir saves space in the container
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code (Use-cases excluded via .dockerignore)
COPY . .

# Create Use-cases directory if it doesn't exist
# Simple approach that works with non-root user
RUN if [ ! -d "/opt/app-root/src/Use-cases" ]; then \
        mkdir -p /opt/app-root/src/Use-cases; \
    fi

# Expose port (Streamlit default)
# This is mainly for documentation as OpenShift uses Services
EXPOSE 8501

# The UBI image already sets USER 1001
# OpenShift will override this with random UID but keeps GID 0

# Run the application
CMD ["streamlit", "run", "ui_app.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true", "--server.fileWatcherType=none"]