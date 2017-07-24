SHELL=/bin/bash

all: test

test:
	cd the-law && $(MAKE) build
	$(MAKE) start
	curl -v http://127.0.0.1:3000/test_cases
	curl http://127.0.0.1:3000/test_cases | grep '\[{"id":1,"problem_id":1,"input":"1\\n0\\n3\\n2\\n","output":"()\\n\\n()()()\\n()(())\\n(())()\\n(()())\\n((()))\\n()()\\n(())\\n"},{"id":2,"problem_id":1,"input":"1\\n","output":"()\\n"},{"id":3,"problem_id":1,"input":"2\\n","output":"()()\\n(())\\n"},{"id":4,"problem_id":1,"input":"3\\n","output":"()()()\\n()(())\\n(())()\\n(()())\\n((()))\\n"}\]'
	$(MAKE) stop

clean:
	cd the-law && $(MAKE) clean
	docker-compose down --rmi local --remove-orphans --volumes

start:
	docker-compose up -d
	cd the-law && $(MAKE) wait-for-db

exec:
	docker-compose up

stop:
	docker-compose down

.PHONY: all test clean start exec stop
