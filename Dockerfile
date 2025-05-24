# Jenkins LTS 버전 기반 (2.426.3-lts-jdk17)
FROM jenkins/jenkins:2.496

# 메타데이터 (선택 사항)
# LABEL maintainer="Your Name <your.email@example.com>"
#LABEL description="Custom Jenkins with Docker, Docker Compose, and SSL certificates for sambungalaxy.o-r.kr"

# 패키지 설치 및 사용자 전환을 위해 root로 변경
USER root

# Docker GID 인자 추가 (호스트와 동일하게 설정 필요)
ARG DOCKER_GID=999 # 호스트의 Docker 그룹 ID로 수정

# 빌드 시작 로깅
RUN echo "=== 빌드 시작 ===" && \
    echo "현재 사용자: $(whoami)" && \
    echo "현재 디렉토리: $(pwd)" && \
    echo "시스템 정보:" && \
    cat /etc/os-release && \
    echo "=== 패키지 설치 시작 ==="

# 필수 패키지 설치: python3-pip (docker-compose용), curl (Docker CLI 설치용)
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-setuptools \
    curl \
    && echo "=== 설치된 패키지 목록 ===" && \
    dpkg -l | grep -E 'python3-pip|python3-setuptools|curl' && \
    echo "=== apt 캐시 정리 ===" && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Docker Compose 설치 로깅
RUN echo "=== Docker Compose 설치 시작 ===" && \
    echo "아키텍처: ${TARGETARCH}" && \
    echo "Docker Compose 버전: ${DOCKER_COMPOSE_VERSION}"

ARG TARGETARCH=amd64
ARG DOCKER_COMPOSE_VERSION=v2.24.6

RUN export ARCH=$(echo ${TARGETARCH} | sed s/amd64/x86_64/) && \
    echo "=== Docker Compose 다운로드 ===" && \
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-linux-${ARCH}" -o /usr/local/bin/docker-compose && \
    echo "=== Docker Compose 권한 설정 ===" && \
    chmod +x /usr/local/bin/docker-compose && \
    mkdir -p /usr/local/lib/docker/cli-plugins && \
    ln -s /usr/local/bin/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose && \
    echo "=== Docker Compose 설치 확인 ===" && \
    docker-compose --version

# Docker CLI 설치 로깅
RUN echo "=== Docker CLI 설치 시작 ===" && \
    curl -fsSL https://get.docker.com -o get-docker.sh && \
    sh get-docker.sh && \
    rm get-docker.sh && \
    echo "=== Docker 설치 확인 ===" && \
    docker --version

# 인증서 디렉토리 설정 로깅
RUN echo "=== 인증서 디렉토리 설정 ===" && \
    mkdir -p /var/jenkins_home/certs && \
    chown jenkins:jenkins /var/jenkins_home/certs && \
    echo "인증서 디렉토리 권한:" && \
    ls -la /var/jenkins_home/certs

# 인증서 파일 복사 및 권한 설정 로깅
COPY fullchain.pem /var/jenkins_home/certs/fullchain.pem
COPY privkey.pem /var/jenkins_home/certs/privkey.pem

RUN echo "=== 인증서 파일 권한 설정 ===" && \
    chown jenkins:jenkins /var/jenkins_home/certs/fullchain.pem /var/jenkins_home/certs/privkey.pem && \
    echo "인증서 파일 권한:" && \
    ls -la /var/jenkins_home/certs/

# Docker 그룹 설정 로깅
RUN echo "=== Docker 그룹 설정 ===" && \
    echo "현재 그룹 목록:" && \
    cat /etc/group && \
    echo "systemd-journal 그룹에 Jenkins 사용자 추가" && \
    usermod -aG systemd-journal jenkins && \
    echo "=== 그룹 설정 확인 ===" && \
    echo "Jenkins 사용자 그룹:" && \
    id jenkins

# Docker 소켓 권한 설정을 위한 시작 스크립트 생성
RUN echo '#!/bin/bash\n\
echo "=== Docker 소켓 권한 설정 ==="\n\
if [ -e /var/run/docker.sock ]; then\n\
    chgrp docker /var/run/docker.sock && chmod g+rw /var/run/docker.sock\n\
    echo "Docker 소켓 권한이 그룹 읽기/쓰기로 설정되었습니다."\n\
    ls -l /var/run/docker.sock\n\
else\n\
    echo "Docker 소켓이 아직 마운트되지 않았습니다."\n\
fi\n\
\n\
# Jenkins 실행\n\
exec jenkins.sh' > /usr/local/bin/start-jenkins.sh && \
chmod +x /usr/local/bin/start-jenkins.sh

# 최종 권한 확인
RUN echo "=== 최종 권한 확인 ===" && \
    echo "Jenkins 사용자 정보:" && \
    id jenkins && \
    echo "Docker 그룹 정보:" && \
    getent group docker && \
    echo "=== 빌드 완료 ==="

# 다시 jenkins 사용자로 전환
USER jenkins

# Jenkins 기본 포트 노출
EXPOSE 8080
EXPOSE 50000

# 시작 스크립트 설정
ENTRYPOINT ["/usr/local/bin/start-jenkins.sh"]