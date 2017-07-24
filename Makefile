SHELL=/bin/bash

all: test

build: .build
	cd the-law && $(MAKE) build

.build: Dockerfile postgrest.conf
	docker-compose build
	touch .build

test: build
	$(MAKE) start
	curl http://127.0.0.1:3000/test_cases | grep '\[{"id":1,"problem_id":1,"input":"1\\n0\\n3\\n2\\n","output":"()\\n\\n()()()\\n()(())\\n(())()\\n(()())\\n((()))\\n()()\\n(())\\n"},{"id":2,"problem_id":1,"input":"1\\n","output":"()\\n"},{"id":3,"problem_id":1,"input":"2\\n","output":"()()\\n(())\\n"},{"id":4,"problem_id":1,"input":"3\\n","output":"()()()\\n()(())\\n(())()\\n(()())\\n((()))\\n"}\]'
	$(MAKE) stop

clean:
	rm -f .build
	cd the-law && $(MAKE) clean
	docker-compose down --rmi local --remove-orphans --volumes

start: build
	docker-compose up -d
	$(MAKE) wait-for-postgrest

exec: build
	docker-compose up

stop:
	docker-compose down

wait-for-postgrest:
	@stop_at=60; i=1; while ! $(MAKE) postgrest-is-up 2>/dev/null; do if [ $$i = $$stop_at ]; then exit 1; fi; let i++; sleep 1; echo -n .; done; echo

postgrest-is-up:
	@curl --fail http://127.0.0.1:3000/ >/dev/null

.PHONY: all build test clean start exec stop wait-for-postgrest postgrest-is-up
