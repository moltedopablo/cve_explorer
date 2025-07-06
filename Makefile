.PHONY: up setup start

up:
	docker compose -f docker-compose.dev.yml up -d --wait

setup:
	cd $(PWD)/assets && npm ci 
	cd $(PWD) && mix setup 

start: 
	iex -S mix phx.server
