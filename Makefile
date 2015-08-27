all: build

build:
	docker build -t aleph-scanner .

run:
	-docker rm aleph-scanner
	docker run -i -t -p 9001:8080 -v /var/aleph-scanner:/data --name aleph-scanner aleph-scanner
