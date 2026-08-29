# 함께읽는성경 V1.2 — Android APK + iPhone PWA 배포

## 목표
한 QR로 배포 페이지를 연다.

- Android: `Android 앱 다운로드` → 최신 APK
- iPhone: `iPhone에서 사용` → PWA
- iPhone PWA: Safari → 공유 → 홈 화면에 추가

## 무료 배포
- GitHub Actions: Android APK + Flutter Web 자동 빌드
- GitHub Releases: 최신 APK
- GitHub Pages: PWA 및 통합 설치 페이지
- Apple Developer 연회비 없음

## 예상 URL
통합 QR:
`https://seunghwan0326.github.io/bible-read-share/`

Android APK:
`https://seunghwan0326.github.io/bible-read-share/BibleReadShare-Android.apk`

iPhone PWA:
`https://seunghwan0326.github.io/bible-read-share/app/`

## 주의
- Android는 처음 한 번 `이 출처의 앱 설치 허용`이 필요할 수 있다.
- iPhone은 QR을 찍자마자 자동 설치되지 않는다.
  Safari에서 PWA를 열고 `홈 화면에 추가`를 한 번 눌러야 한다.
- iPhone PWA에서 66권 전체 오프라인 저장은 브라우저 저장공간 제약 때문에 비활성화한다.
- 방/진도/기도제목은 기존 Supabase `bible_*_v13` 서버를 공용으로 사용한다.
