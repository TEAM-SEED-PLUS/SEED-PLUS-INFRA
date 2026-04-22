# Dockerfile
# PostgreSQL 15 버전과 호환되는 PostGIS 최신 안정화 버전 사용
FROM postgis/postgis:15-3.4

# OS 시간대 설정
ENV TZ=Asia/Seoul
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone