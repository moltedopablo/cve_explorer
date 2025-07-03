up:
	docker compose -f docker-compose.dev.yml up -d --wait 
start: 
	mix ecto.migrate && iex -S mix phx.server
