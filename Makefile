DB_URL=postgresql://root:secret@localhost:5432/go-template-http?sslmode=disable

postgres:
	docker run --name postgres -p 5432:5432 -e POSTGRES_USER=root -e POSTGRES_PASSWORD=secret -d postgres:12-alpine

start_postgres:
	docker start postgres

createdb:
	docker exec -it postgres createdb --username=root --owner=root go-template-http

dropdb:
	docker exec -it postgres dropdb go-template-http

migrateup:
	migrate -path=db/migration -database="$(DB_URL)" --verbose up

migrateup1:
	migrate -path=db/migration -database="$(DB_URL)" --verbose up 1

migratedown:
	migrate -path=db/migration -database="$(DB_URL)" --verbose down

migratedown1:
	migrate -path=db/migration -database="$(DB_URL)" --verbose down 1

new_migration:
	migrate create -ext sql -dir db/migration -seq $(name)

db_schema:
	dbml2sql --postgres -o doc/schema.sql doc/db.dbml

sqlc:
	sqlc generate

test:
	go test -v -cover -short ./...

server:
	go run main.go

mock:
	mockgen -package mockdb -destination db/mock/store.go github.com/ltcong1411/go-template-http/db/sqlc Store

.PHONY: postgres createdb dropdb migrateup migratedown migrateup1 migratedown1 sqlc test server mock new_migration db_schema