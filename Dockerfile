FROM python:3.12-alpine
COPY . /application
WORKDIR /application
COPY requirements.txt .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]