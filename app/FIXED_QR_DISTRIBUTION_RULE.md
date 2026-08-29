# 함께읽는성경 — 고정 QR 배포 규칙

## 고정 QR 주소
`https://seunghwan0326.github.io/bible-read-share/`

## 절대 규칙
- Android와 iPhone은 **같은 QR 1개**를 사용한다.
- 새 버전이 나와도 QR 이미지를 바꾸지 않는다.
- QR이 가리키는 GitHub Pages 주소를 유지한다.
- Android APK와 iPhone PWA만 같은 주소 아래에서 최신 버전으로 교체한다.
- 모든 안내문/PDF/이미지/배포자료에는 이 QR만 사용한다.

## Android
QR → 통합 배포 페이지 → Android 앱 다운로드 → APK 설치

## iPhone
QR → 통합 배포 페이지 → iPhone에서 성경앱 열기 → Safari → 홈 화면에 추가

## V1.2.1 수정
- Android release INTERNET 권한 강제 삽입
- 빌드 중 INTERNET 권한 검증
- Supabase DNS 검증
- 방 생성/참여/동기화 네트워크 오류 메시지 개선
- Supabase 프로젝트 URL 유지
