FROM trenpixster/elixir:latest
MAINTAINER Chris Zhu <chris.zhu12@gmail.com>

RUN apt-get update && apt-get install -qy curl postgresql-client sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*


# gpg keys listed at https://github.com/nodejs/node
RUN set -ex \
  && for key in \
    9554F04D7259F04124DE6B476D5A82AC7E37093B \
    94AE36675C464D64BAFA68DD7434390BDBE9B9C5 \
    0034A06D9D9B0064CE8ADF6BF1747F4AD2306D93 \
    FD3A5288F042B6850C66B31F09FE44734EB7990E \
    71DCFD284A79C3B38668286BC97EC7A07EDE3FC1 \
    DD8F2338BAE7501E3DD5AC78C273792F7D83545D \
    B9AE9905FFD7803F25714661B63B535A4C206CA9 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
  ; do \
    gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$key"; \
  done

ENV NODE_VERSION 0.12.12

RUN curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-x64.tar.xz" \
	&& curl -SLO "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
	&& gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
	&& grep " node-v$NODE_VERSION-linux-x64.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
	&& tar -xJf "node-v$NODE_VERSION-linux-x64.tar.xz" -C /usr/local --strip-components=1 \
	&& rm "node-v$NODE_VERSION-linux-x64.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt


# Install Phantom JS
RUN wget -O - https://gist.githubusercontent.com/juliobetta/57709252d24502d36b92/raw/9005a9ef4da1de3dc0e3fb358b1820d7e19744b4/install_phantomjs.sh | sh

RUN apt-get install -y libxml2-dev libxslt1-dev
RUN apt-get install -y libqt4-webkit libqt4-dev xvfb


RUN echo %sudo    ALL=NOPASSWD: ALL>>/etc/sudoers

RUN useradd -m -G sudo app

RUN mkdir /phoenixapp
WORKDIR /phoenixapp

COPY ./mix.exs /phoenixapp/mix.exs
COPY ./mix.lock /phoenixapp/mix.lock

RUN yes | mix deps.get

COPY ./ /phoenixapp

ENV PORT 4000
ENV MIX_ENV prod

RUN mix deps.compile

RUN npm install -g webpack
RUN npm install

EXPOSE 4000
