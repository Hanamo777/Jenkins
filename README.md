# Jenkins 설치 과정 (Docker 활용)


1. git clone 및 script 파일 실행

git clone https://github.com/Hanamo777/Jenkins.git

cd Jenkins

chmod +x setup_jenkins.sh

./setup_jenkins.sh

2. Jenkins Docker 컨테이너와 Host Docker socket 권한 연동 확인

sudo docker exec -it (jenkins docker image id) bash

docker ps