FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl

WORKDIR /app
COPY websocket_api/ .

RUN python3 -m pip install --break-system-packages -r requirements.txt


CMD ["python3", "app.py", "--mode", "developer"]
