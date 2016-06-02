FROM python:2.7-slim
ENV HOME /root
RUN pip install --upgrade pip && \
    pip install awscli && \
    apt-get update && \
    apt-get install groff -y -qq && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /src
