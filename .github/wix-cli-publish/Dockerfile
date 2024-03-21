FROM node:20

WORKDIR /app

# Bundle your app's source code inside the Docker image
COPY . /app

RUN apt-get update && \
    apt-get install -y curl jq chromium npm --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

RUN chmod +x ./.github/wix-cli-publish/run-publish.sh

CMD ["./.github/wix-cli-publish/run-publish.sh"]
