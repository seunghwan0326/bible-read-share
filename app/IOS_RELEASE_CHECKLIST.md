# iOS Release Checklist

## 기능
- [ ] 66권 본문 로딩
- [ ] 읽음 체크 및 재실행 후 유지
- [ ] 방 2개 이상 생성/참여
- [ ] Android ↔ iPhone 같은 초대코드 참여
- [ ] Android에서 읽음 변경 → iPhone 방 새로고침 시 진도 확인
- [ ] iPhone에서 기도제목 추가 → Android에서 확인
- [ ] 방별 기도제목 분리
- [ ] 초대 버튼을 눌렀을 때만 Share Sheet 표시

## Apple
- [ ] Apple Developer Program
- [ ] Bundle ID 확정
- [ ] Xcode Signing Team 선택
- [ ] 앱 아이콘 1024x1024
- [ ] Privacy Policy URL
- [ ] App Store 개인정보 질문 작성
- [ ] TestFlight 실기기 테스트

## 공개 배포 전 보안
- [ ] 사용자 인증 방식 확정
- [ ] Supabase RPC/RLS 재검토
- [ ] 초대코드 brute-force 방지
- [ ] rate limiting
- [ ] 기도제목 신고/삭제 운영 정책 검토
