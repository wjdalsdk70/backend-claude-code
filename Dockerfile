# Spring Boot 멀티스테이지 빌드 템플릿
# TODO: JAVA_VERSION, APP_PORT를 프로젝트에 맞게 조정하세요

ARG JAVA_VERSION=21

# ─── Stage 1: builder ────────────────────────────────────────────────────────
FROM eclipse-temurin:${JAVA_VERSION}-jdk AS builder
WORKDIR /app

# 의존성 레이어 캐싱 (소스 변경 전에 먼저 다운로드)
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./
RUN ./mvnw dependency:go-offline -q --no-transfer-progress

# 소스 빌드
COPY src/ src/
RUN ./mvnw package -DskipTests -q --no-transfer-progress

# ─── Stage 2: runtime ────────────────────────────────────────────────────────
FROM eclipse-temurin:${JAVA_VERSION}-jre AS runtime

# 보안: 비 root 사용자로 실행
RUN groupadd --system appgroup && \
    useradd --system --gid appgroup --no-create-home appuser

WORKDIR /app

# 빌드 결과물만 복사
COPY --from=builder /app/target/*.jar app.jar

# 파일 소유권 설정
RUN chown appuser:appgroup app.jar
USER appuser

# 애플리케이션 포트 (TODO: 프로젝트 포트로 변경)
EXPOSE 8080

# JVM 최적화 옵션
# -XX:+UseContainerSupport : 컨테이너 메모리 제한 인식
# -XX:MaxRAMPercentage=75  : 컨테이너 메모리의 75% 사용
# -Djava.security.egd    : 난수 생성 속도 개선 (SSL 초기화 지연 방지)
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
