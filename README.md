# Jenkins 설치 과정 (Docker 활용)


1. Docker , Docker compose 설치

Script

sudo apt update && sudo apt upgrade

curl -fsSL https://get.docker.com -o dockerSetter.sh

chmod 711 dockerSetter.sh

./dockerSetter.sh

2. Dockerfile jenkins 실행

sudo docker build -t my-jenkins:latest .

```
sudo docker run -d -p 8080:8080 -p 50000:50000 \
-v jenkins_home:/var/jenkins_home \
-v /var/run/docker.sock:/var/run/docker.sock \
--group-add $(getent group docker | cut -d: -f3) \
--name jenkins-server my-jenkins:latest
```

3. Jenkins Docker 컨테이너가 Host Docker socket 권한 연동됬느지 확인하는 법

sudo docker exec -it (jenkins docker image id) bash

id jenkins

4. Jenkins 초기 비밀번호 

sudo docker logs jenkins-server