DOCKER_IMAGE_NAME = phoenix_trello_web

ifdef local
	local_or_docker =
else
	local_or_docker = docker exec -it $(DOCKER_IMAGE_NAME)
endif

database_create:
	mix ecto.create

database_migrate:
	mix ecto.migrate

setup: database_create database_migrate

startup: setup
	mix phoenix.server
