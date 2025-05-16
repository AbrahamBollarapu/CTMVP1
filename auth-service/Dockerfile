# Use a slim Python image
FROM python:3.9-slim

# Set working dir
WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy app code + database bootstrap
COPY app/ ./app
COPY database.py .

# Expose port
EXPOSE 8001

# Start the service
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8001", "--workers", "1"]
