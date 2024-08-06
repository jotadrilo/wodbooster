FROM node:20 as deps

COPY src/package.json /src/
COPY src/yarn.lock /src/

RUN cd /src && \
    yarn install

FROM node:20-slim

ARG DEBIAN_FRONTEND=noninteractive

# Install deps
RUN apt-get update && apt-get install -y ca-certificates xvfb fluxbox wmctrl gnupg2 curl

RUN curl -fsSL https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb http://dl.google.com/linux/chrome/deb/ stable main" | tee /etc/apt/sources.list.d/google.list && \
    apt-get update && apt-get install -y google-chrome-stable

COPY --from=deps /src /src

COPY src/tsconfig.json /src/
COPY src/*.ts /src/
COPY src/lib /src/lib
RUN cd /src && yarn build

WORKDIR /src/.build

COPY config.yml /
COPY run.sh /
RUN chmod 755 /run.sh

ENV WB_CONFIG_FILE="/config.yml"

CMD ["/run.sh"]
