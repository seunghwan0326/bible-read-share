# Phone-Only iOS Checkpoint

## 확정 개발 환경
- 사용자 기기: Android phone only
- Local PC: required = NO
- Personal Mac: required = NO
- iPhone for build generation: required = NO
- Cloud macOS: GitHub Actions or Codemagic
- Final signed iOS/TestFlight: Apple Developer Program required

## Repository
Recommended repository: `bible-read-share`
Recommended visibility: Private

## Bundle IDs
- Android package/applicationId target: `com.biblereadshare.app`
- iOS bundle identifier target: `com.biblereadshare.app`

## Build flows
### Free compile QA
GitHub Actions:
`.github/workflows/ios_cloud_build.yml`

Output:
`BibleReadShare-iOS-unsigned` artifact

### Signed iOS
Codemagic automatic code signing:
- Apple Developer Program
- App Store Connect API key
- Key ID
- Issuer ID
- .p8 private API key
- Automatic App Store signing
- Bundle ID `com.biblereadshare.app`

## Rule
Never claim an unsigned GitHub build is an installable App Store/TestFlight IPA.
Final device install/distribution requires Apple-compliant code signing.

## Next checkpoint
User creates an empty `bible-read-share` GitHub repository from Android.
Then upload this project through the connected GitHub integration.
