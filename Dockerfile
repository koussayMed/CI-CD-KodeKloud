# Use the official Python image with Alpine as the base
FROM python:3.12-alpine

# Install necessary build dependencies (like gcc, musl-dev, libffi-dev)
RUN apk add --no-cache gcc musl-dev libffi-dev

# Set the working directory to /application
WORKDIR /application

# Copy the application code into the container
COPY . /application

# Copy the requirements.txt file
COPY requirements.txt .

# Install pip dependencies with retries for network issues
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --index-url https://pypi.org/simple/ || \
    (echo "Retrying pip install..." && sleep 10 && pip install --no-cache-dir -r requirements.txt --index-url https://pypi.org/simple/)

# Expose the application port (5000)
EXPOSE 5000

# Command to run the application
CMD ["python", "app.py"]
