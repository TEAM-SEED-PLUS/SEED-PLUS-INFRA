sudo mkdir -p /home/seedplus_db_data

docker build -t seedplus-db:latest .

docker run -d \
  --name seedplus_postgres \
  -p 35432:5432 \
  -v /home/seedplus_db_data:/var/lib/postgresql/data \
  -e POSTGRES_DB=seedplus_db \
  -e POSTGRES_USER=seedplus_user \
  -e POSTGRES_PASSWORD=<PW> \
  seedplus-db:latest

sudo semanage port -a -t http_port_t -p tcp 35432

### PostgreSQL 기본 버전 확인
SELECT postgis_full_version();
POSTGIS="3.4.3 e365945" [EXTENSION] PGSQL="150" GEOS="3.9.0-CAPI-1.16.2" PROJ="7.2.1 NETWORK_ENABLED=OFF URL_ENDPOINT=https://cdn.proj.org USER_WRITABLE_DIRECTORY=/var/lib/postgresql/.local/share/proj DATABASE_PATH=/usr/share/proj/proj.db" LIBXML="2.9.10" LIBJSON="0.15" LIBPROTOBUF="1.3.3" WAGYU="0.5.0 (Internal)" TOPOLOGY

