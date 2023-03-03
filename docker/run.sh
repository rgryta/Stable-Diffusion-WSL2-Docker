echo "Removing old containers"
docker container stop `docker ps -a | grep sd | awk '{print $1}' | awk 'BEGIN { ORS = " " } { print }'`
docker container rm `docker ps -a | grep sd | awk '{print $1}' | awk 'BEGIN { ORS = " " } { print }'`

echo "Starting new container"
docker run -p 127.0.0.1:7860:7860 --gpus all sd