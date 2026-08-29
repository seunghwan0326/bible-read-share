# 안드로이드폰만으로 iPhone 앱까지 만드는 절차

## 목표
컴퓨터를 소유하지 않고 다음 흐름으로 운영한다.

`안드로이드폰 → GitHub → 클라우드 macOS → iOS 빌드 → TestFlight/App Store`

현재 함께읽는성경 Flutter 프로젝트는 Android와 iOS가 같은 Supabase `bible_*_v13` 백엔드를 사용한다.

---

# 1. 지금 당장 필요한 것

- 안드로이드폰
- GitHub 계정
- 이 프로젝트 ZIP
- 인터넷 브라우저

**Mac과 iPhone은 iOS 컴파일 파일을 만드는 단계에는 필요하지 않다.**

---

# 2. 안드로이드폰에서 GitHub 저장소 만들기 — 1회만

GitHub 앱 또는 브라우저에서:

1. GitHub 로그인
2. `Repositories`
3. `New repository`
4. 이름: `bible-read-share`
5. 가능하면 `Private` 선택
6. 저장소 생성

ChatGPT GitHub 연결에서는 현재 기존 저장소의 파일을 읽고/수정할 수 있지만
새 저장소 자체를 만드는 동작은 지원되지 않는다.
따라서 **이 한 번의 저장소 생성만 휴대폰에서 직접 한다.**

저장소를 만든 뒤 ChatGPT에:

`bible-read-share 저장소 만들었어. Flutter 성경앱 올려줘.`

라고 말하면 이후 파일 업로드/업데이트는 ChatGPT가 연결된 GitHub를 통해 이어갈 수 있다.

---

# 3. Apple 계정 없이 iOS 컴파일 검사

프로젝트에는 이미:

`.github/workflows/ios_cloud_build.yml`

이 들어 있다.

GitHub 저장소에 프로젝트가 올라가면 휴대폰에서:

1. 저장소 열기
2. `Actions`
3. `iOS Cloud Build Check`
4. `Run workflow`
5. 완료될 때까지 확인

macOS 서버가 자동으로:

- Flutter 설치
- iOS 프로젝트 생성
- `flutter analyze`
- `flutter build ios --release --no-codesign`
- 결과물을 GitHub Actions Artifact로 저장

까지 수행한다.

이 결과는 **컴파일 검사용 unsigned 앱**이며 실제 iPhone에 바로 설치하는 IPA는 아니다.

---

# 4. 실제 iPhone 설치/TestFlight가 필요할 때

여기부터 Apple 정책상 **Apple Developer Program 가입이 필요하다.**

그러나 여전히 직접 Mac을 소유할 필요는 없다.

가장 쉬운 방식은 Codemagic automatic code signing이다.

Codemagic에서는 App Store Connect API를 연결하면
Mac 없이 코드서명 인증서와 provisioning profile을 자동 생성할 수 있다.

휴대폰 브라우저에서:

1. Apple Developer Program 가입
2. App Store Connect 로그인
3. `Users and Access`
4. `Integrations`
5. App Store Connect API key 생성
6. `.p8` 키 다운로드
   - 이 파일은 한 번만 다운로드할 수 있으므로 반드시 보관
7. Issuer ID / Key ID 기록
8. Codemagic 로그인
9. GitHub의 `bible-read-share` 저장소 연결
10. Team integrations → Developer Portal
11. App Store Connect API key 등록
12. iOS code signing → Automatic
13. Bundle ID: `com.biblereadshare.app`
14. Distribution/App Store 유형 선택
15. Build

Codemagic가 Apple 인증서와 provisioning profile을 만들어 코드서명한다.

---

# 5. 실제 배포

최종 목표에 따라:

## TestFlight
가족/교회 구성원에게 테스트 배포할 때 가장 편하다.

`Codemagic → App Store Connect → TestFlight → 사용자 초대`

## App Store
일반 공개 배포.

추가로 필요:
- 앱 이름
- 앱 아이콘 1024×1024
- 스크린샷
- 개인정보 처리방침 URL
- App Store 개인정보 질문
- 카테고리/설명

---

# 6. 중요한 구분

| 단계 | 컴퓨터 | Mac | iPhone | Apple Developer |
|---|---|---|---|---|
| Flutter 소스 준비 | 불필요 | 불필요 | 불필요 | 불필요 |
| iOS 컴파일 확인 | 불필요 | 클라우드 사용 | 불필요 | 불필요 |
| signed IPA 생성 | 불필요 | 클라우드 사용 | 불필요 | 필요 |
| TestFlight 업로드 | 불필요 | 클라우드 사용 | 불필요 | 필요 |
| 실제 화면 QA | 불필요 | 불필요 | 권장 | 필요할 수 있음 |

---

# 7. 함께읽는성경 운영 방식

Android와 iPhone은 운영체제가 달라도 같은 서버를 사용한다.

예:
- 아빠: Android
- 엄마: iPhone
- 자녀: iPhone

모두 같은 `가족` 방 초대코드로 참여 가능.

방에서 같이 보이는 것:
- 사람별 성경 읽은 장 수
- 사람별 전체 진행률
- 최근 읽은 위치
- 방별 기도제목
- 기도제목 작성자
- 응답됨 상태

내 개인 읽기 진도는 내가 가입한 모든 방에 자동 반영된다.

---

# 다음 작업

1. 휴대폰에서 빈 GitHub 저장소 `bible-read-share` 생성
2. ChatGPT에 `저장소 만들었어`라고 말하기
3. ChatGPT가 Flutter 프로젝트와 Actions 파일을 저장소에 업로드
4. GitHub Actions의 iOS unsigned build 성공 확인
5. 기능 안정화 후 Apple Developer 가입 및 Codemagic 자동서명 연결
