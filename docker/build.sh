echo "Building docker image"
docker buildx build -t sd:latest .
echo "Creating docker container"
docker create --name sd sd:latest
