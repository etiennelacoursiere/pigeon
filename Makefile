start: db_start start_server

start_server:
	@echo "Starting Phoenix project"
	mix phx.server

db_start:
	 @echo "Starting database using docker-compose"
	 docker-compose up -d
