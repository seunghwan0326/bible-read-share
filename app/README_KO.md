# 함께읽는성경 Flutter V1.0

현재 Android CAPROJ V1.3.4의 핵심 기능을 Android + iPhone 공용 Flutter 코드로 이식한 첫 버전입니다.

## 공용 기능
- 개역한글 66권 / 1,189장
- 읽은 장 체크 및 진행률
- 최근 읽은 위치
- 글자크기 조절
- 본문 캐시 / 66권 오프라인 저장
- 현재 말씀 공유
- 읽기 진행률 공유
- 여러 방 생성 / 초대코드 참여
- 방마다 독립된 멤버 목록
- 멤버별 `N/1,189`, 진행률 %, 최근 위치 공유
- 내 읽기 진도는 가입한 모든 방에 자동 동기화
- 방별 기도제목
- 사람별 여러 기도제목 등록
- 작성자 표시
- 작성자 자신의 기도제목 응답됨/삭제
- 방 초대는 사용자가 초대 버튼을 눌렀을 때만 시스템 공유창 표시

Android와 iPhone은 동일한 Supabase `bible_*_v13` 데이터를 사용하므로 서로 같은 방에 참여할 수 있습니다.

---

## Windows 설치

### 1. 설치
- Git for Windows
- Flutter SDK
- VS Code
- VS Code Flutter/Dart 확장
- Android 테스트가 필요하면 Android Studio

Flutter를 PATH에 추가한 뒤 PowerShell:

```powershell
flutter doctor
```

### 2. 프로젝트 압축 해제 후
PowerShell을 프로젝트 폴더에서 열고:

```powershell
Set-ExecutionPolicy -Scope Process Bypass
.\setup_windows.ps1
```

이 스크립트가 `android/`, `ios/` 플랫폼 폴더를 Flutter 표준 형식으로 생성하고 `flutter pub get`까지 실행합니다.

### 3. Windows에서 Android 테스트

```powershell
flutter devices
flutter run
```

---

## iPhone 빌드

Windows에서는 iOS Simulator/Xcode를 실행할 수 없습니다.

### 방법 A — GitHub Actions로 iOS 컴파일 검증
프로젝트를 GitHub에 올리면 `.github/workflows/ios_compile_check.yml`이 macOS runner에서:

```bash
flutter build ios --release --no-codesign
```

을 실행해 iOS 코드가 컴파일되는지 검증합니다.

### 방법 B — 실제 iPhone/TestFlight/App Store
최종 설치 가능한 iOS 앱에는 아래가 필요합니다.

- Apple Developer 계정
- macOS
- Xcode
- Bundle ID / Signing 설정
- 실제 iPhone 또는 TestFlight

Mac에서:

```bash
flutter pub get
flutter build ipa --release
```

Xcode에서 Team/Signing을 설정한 후 TestFlight/App Store Connect로 업로드합니다.

---

## 중요한 현재 제한

현재 방 식별은 기기 안의 `member_token` 기반입니다. Android 사용자와 iPhone 사용자는 같은 방에서 정상적으로 서로 다른 멤버로 사용할 수 있습니다.

다만 **한 사람이 Android와 iPhone 두 기기를 번갈아 쓰며 동일한 계정/동일한 개인 진도를 자동 복원**하려면 다음 단계에서 로그인(Apple/Google/이메일 등) 기반 사용자 계정을 추가해야 합니다.

또한 현재 Supabase RPC 구조는 가족/소그룹 테스트용으로 유지한 것입니다. App Store 공개 배포 전에는 사용자 인증, RLS/RPC 권한, 악용 방지 정책을 한 번 더 강화하는 것을 권장합니다.
