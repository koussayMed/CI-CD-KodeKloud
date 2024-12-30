# Use a stable Python Alpine version
FROM python:3.12-alpine

# Copy the application files into the container
COPY . /application

# Set the working directory
WORKDIR /application

# Copy requirements.txt for installing dependencies
COPY requirements.txt .

# Install dependencies with retries and using a reliable mirror
RUN pip install --no-cache-dir -r requirements.txt --index-url https://pypi.tuna.tsinghua.edu.cn/simple || (sleep 10 && pip install --no-cache-dir -r requirements.txt --index-url https://pypi.tuna.tsinghua.edu.cn/simple)

# Expose the application port
EXPOSE 5000

# Set the command to run the application
CMD ["python", "app.py"]
