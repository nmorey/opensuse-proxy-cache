.PHONY: clean

vendor:
	cargo vendor 1> ./.cargo/config.toml

proxy:
	docker buildx build --platform "linux/amd64" \
		-f ./opensuse-proxy-cache/Dockerfile \
		-t nmorey/opensuse_proxy_cache:latest .

clean:
	rm -rf ./vendor ./Cargo.lock ./opensuse-proxy-cache/Cargo.lock


all: proxy redis


