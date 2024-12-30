FROM python:3.12.0b3-alpine3.18
COPY . /application
WORKDIR /application
COPY requirements.txt .
RUN pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt --index-url https://pypi.org/simple/
EXPOSE 5000
CMD ["python", "app.py"]