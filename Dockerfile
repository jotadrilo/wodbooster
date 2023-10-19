FROM node:16 as deps

RUN apt-get update && apt-get install -y ca-certificates \
    g++ \
    make \
    cmake \
    unzip \
    libcurl4-openssl-dev

COPY src/package.json /src/
COPY src/yarn.lock /src/

RUN cd /src && \
    yarn add aws-lambda-ric && \
    yarn install

FROM node:16-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install deps
RUN apt-get update && apt-get install -y ca-certificates xvfb fluxbox wmctrl gnupg2 curl libcurl4-openssl-dev dbus

RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get install -y google-chrome-stable

RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_16.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && apt-get install -y nodejs

# Add Lambda Runtime Interface Emulator and use a script in the ENTRYPOINT for simpler local runs
ADD https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/latest/download/aws-lambda-rie /usr/local/bin/aws-lambda-rie
RUN chmod 755 /usr/local/bin/aws-lambda-rie

COPY --from=deps /src /src

COPY src/tsconfig.json /src/
COPY src/*.ts /src/
COPY src/lib /src/lib
RUN cd /src && yarn build

WORKDIR /src/.build

COPY bootstrap.sh /
COPY config.yml /
RUN chmod 755 /bootstrap.sh

ENV WB_NO_HEADLESS="0" \
    WB_USE_LAMBDA_API="0" \
    WB_CHROME_ENDPOINT="" \
    WB_CHROME_PATH="google-chrome" \
    WB_CONFIG_FILE="/config.yml" \
    AWS_LAMBDA_FUNCTION_MEMORY_SIZE="10240"

ENTRYPOINT [ "/bootstrap.sh" ]
CMD ["index.enroll"]
