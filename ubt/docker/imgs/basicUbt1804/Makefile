
.PHONY: all
all: dockerImg

#observer
.PHONY:dockerImg
dockerImg: clean
	docker build --rm -t ubuntu:basic1804 \
				--build-arg "group=${USER}" \
				--build-arg "gid=$$(id -u)" \
				--build-arg "user=${USER}" \
				--build-arg	"uid=$$(id -g)" \
				-f ./Dockerfile.img .
.PHONY:run
run:
	docker run --name basic1804 --rm -it --dns "192.168.11.1" --workdir=$$(pwd) --hostname "dc" -v $$(pwd):$$(pwd) ubuntu:basic1804

.PHONY: clean
clean:
	docker rmi -f ubuntu:basic1804
	docker image prune


