FROM	debian:buster-slim
ARG	DEBIAN_FRONTEND=noninteractive
ENV 	RUSTUP_HOME=/usr/local/rustup \
	CARGO_HOME=/usr/local/cargo \
	PATH=/usr/local/cargo/bin:$PATH
	
RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.163.com/debian/ buster main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ buster main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian-security/ buster/updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian-security/ buster/updates main non-free contrib" >> /etc/apt/sources.list
	
RUN	apt-get update && apt-get install -y --no-install-recommends --no-install-suggests ca-certificates pkg-config libssl-dev gcc-multilib curl && \
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s \
	-- --profile minimal -y
COPY	common	/lumen/common
COPY	lumen	/lumen/lumen
COPY	Cargo.toml /lumen/
RUN	cd /lumen && cargo build --release

FROM	debian:buster-slim
ARG	DEBIAN_FRONTEND=noninteractive

RUN mv /etc/apt/sources.list /etc/apt/sources.list.bak && \
    echo "deb http://mirrors.163.com/debian/ buster main non-free contrib" > /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ buster main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ buster-updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian/ buster-backports main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb http://mirrors.163.com/debian-security/ buster/updates main non-free contrib" >> /etc/apt/sources.list && \
    echo "deb-src http://mirrors.163.com/debian-security/ buster/updates main non-free contrib" >> /etc/apt/sources.list

RUN	apt-get update && apt-get install -y --no-install-recommends --no-install-suggests openssl netcat-openbsd && \
	sed -i -e 's,\[ v3_req \],\[ v3_req \]\nextendedKeyUsage = serverAuth,' /etc/ssl/openssl.cnf 
COPY	--from=0	/lumen/target/release/lumen	/usr/bin/lumen
COPY	config-example.toml	docker-init.sh	/lumen/
RUN	chmod ug+x /lumen/docker-init.sh && chmod ug+x /usr/bin/lumen
WORKDIR	/lumen
