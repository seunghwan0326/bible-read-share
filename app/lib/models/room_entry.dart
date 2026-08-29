class RoomEntry {
  final String roomId;
  final String roomName;
  final String inviteCode;
  final String memberId;
  final String memberToken;
  final String displayName;

  const RoomEntry({
    required this.roomId,
    required this.roomName,
    required this.inviteCode,
    required this.memberId,
    required this.memberToken,
    required this.displayName,
  });

  factory RoomEntry.fromMap(Map<String, dynamic> map) => RoomEntry(
        roomId: '${map['room_id'] ?? ''}',
        roomName: '${map['room_name'] ?? '함께 읽는 방'}',
        inviteCode: '${map['invite_code'] ?? ''}',
        memberId: '${map['member_id'] ?? ''}',
        memberToken: '${map['member_token'] ?? ''}',
        displayName: '${map['display_name'] ?? ''}',
      );

  Map<String, dynamic> toMap() => {
        'room_id': roomId,
        'room_name': roomName,
        'invite_code': inviteCode,
        'member_id': memberId,
        'member_token': memberToken,
        'display_name': displayName,
      };

  RoomEntry copyWith({
    String? roomId,
    String? roomName,
    String? inviteCode,
    String? memberId,
    String? memberToken,
    String? displayName,
  }) =>
      RoomEntry(
        roomId: roomId ?? this.roomId,
        roomName: roomName ?? this.roomName,
        inviteCode: inviteCode ?? this.inviteCode,
        memberId: memberId ?? this.memberId,
        memberToken: memberToken ?? this.memberToken,
        displayName: displayName ?? this.displayName,
      );
}
