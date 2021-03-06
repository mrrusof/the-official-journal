SHELL=/bin/bash

BUILD_DIR=_build
DOCKER_BTOKEN=$(BUILD_DIR)/docker.done

all build: $(DOCKER_BTOKEN)

$(DOCKER_BTOKEN): Dockerfile postgrest.conf
	docker-compose pull the-law
	docker-compose build the-official-journal
	touch .build

push: build
	docker-compose push the-official-journal

test: build
	$(MAKE) start
	curl 'http://127.0.0.1:3000/test_cases?id=eq.1' | grep '\[{"id":1,"problem_id":"adjacent-coins","input":"0\\n","output":"0\\n"}\]'
	$(MAKE) stop

clean:
	rm -rf $(BUILD_DIR)
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

.PHONY: all build push test clean start exec stop wait-for-postgrest postgrest-is-up
