#!/bin/bash

# 업데이트 및 업그레이드
sudo apt update && sudo apt upgrade -y

# Docker 설치
curl -fsSL https://get.docker.com -o dockerSetter.sh
chmod 711 dockerSetter.sh
./dockerSetter.sh
rm dockerSetter.sh

# Docker 이미지 빌드
sudo docker build -t my-jenkins:latest .

# Jenkins 컨테이너 실행
sudo docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add $(getent group docker | cut -d: -f3) \
  --name jenkins-server my-jenkins:latest

# 초기 관리자 비밀번호 출력
echo "====== Jenkins 초기 관리자 비밀번호 ======"
sudo docker logs jenkins-server 2>&1 | grep -A 2 "Please use the following password"
