IMG_TAG = "debtest"

all: build test

build:
	docker build -t $(IMG_TAG) .

test:
	./test.sh

