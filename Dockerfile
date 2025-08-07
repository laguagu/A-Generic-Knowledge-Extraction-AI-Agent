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

# Set work directory
WORKDIR /app

# Copy requirements first for better Docker layer caching
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Create necessary directories with correct permissions for OpenShift arbitrary user IDs
# Only set permissions for new directories and files that need to be writable
RUN mkdir -p /app/output /app/temp && \
    chgrp -R 0 /app/output /app/temp && \
    chmod -R g+rwX /app/output /app/temp

# Expose port (Streamlit default is 8501)
EXPOSE 8501

# Use numeric USER ID for OpenShift compatibility (not username)
# This allows OpenShift to run the container with arbitrary user IDs
USER 1001

# Command to run the application
CMD ["streamlit", "run", "ui_app.py", "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true", "--server.fileWatcherType=none"]