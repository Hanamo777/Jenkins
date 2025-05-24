#!/bin/bash

# 업데이트 및 업그레이드
echo "시스템 업데이트 및 업그레이드 중..."
sudo apt update && sudo apt upgrade -y

# Docker 설치
echo "Docker 설치 중..."
curl -fsSL https://get.docker.com -o dockerSetter.sh
chmod 711 dockerSetter.sh
./dockerSetter.sh
rm dockerSetter.sh

# Docker 이미지 빌드
echo "Docker 이미지 빌드 중..."
sudo docker build -t my-jenkins:latest .

# Jenkins 컨테이너 실행
echo "Jenkins 컨테이너 실행 중..."
sudo docker run -d -p 8080:8080 -p 50000:50000 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --group-add "$(getent group docker | cut -d: -f3)" \
  --name jenkins-server my-jenkins:latest

echo "Jenkins 컨테이너 시작 및 초기 비밀번호 생성 대기 중 (최대 5분)..."

# Jenkins 초기 관리자 비밀번호가 나올 때까지 로그 감시
# -f: 로그를 계속 스트리밍 (follow)
# -m 1: 첫 번째 매칭 후 종료
# --since "5m": 최근 5분간의 로그만 확인하여 불필요한 과거 로그 검색 방지
timeout 300s bash -c 'until sudo docker logs jenkins-server 2>&1 | grep -q "Please use the following password"; do sleep 5; done' || echo "비밀번호를 찾지 못했거나 타임아웃 되었습니다. 수동으로 확인해 주세요."

# 초기 관리자 비밀번호 출력
echo "====== Jenkins 초기 관리자 비밀번호 ======"
sudo docker logs jenkins-server 2>&1 | grep -A 2 "Please use the following password"

echo "Jenkins 초기 설정 완료 준비됨. 웹 브라우저에서 접속하세요: http://[당신의_EC2_인스턴스_IP]:8080"