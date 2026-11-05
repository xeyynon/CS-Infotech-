/// Plain data classes mirroring the Calley mock API ("Mock API V2").
/// Nothing here invents a value: a field the server did not send stays null.
library;

int? _int(Object? v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? _str(Object? v) => v?.toString();

class User {
  const User({
    required this.id,
    required this.username,
    required this.email,
    this.phone,
    this.subscription,
  });

  final String id;
  final String username;
  final String email;
  final String? phone;
  final String? subscription;

  /// The server may return the user at the top level or under `user`.
  factory User.fromJson(Map<String, dynamic> json) {
    final j = (json['user'] is Map<String, dynamic>)
        ? json['user'] as Map<String, dynamic>
        : json;
    return User(
      id: _str(j['_id'] ?? j['id'] ?? j['userId']) ?? '',
      username: _str(j['username'] ?? j['name']) ?? '',
      email: _str(j['email']) ?? '',
      phone: _str(j['phone'] ?? j['mobile']),
      subscription: _str(j['subscription'] ?? j['plan']),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'username': username,
    'email': email,
    'phone': phone,
    'subscription': subscription,
  };

  /// First name for greetings ("Hello Swati").
  String get firstName => username.trim().split(RegExp(r'\s+')).first;

  String get initial =>
      username.trim().isEmpty ? '?' : username.trim()[0].toUpperCase();
}

class CallingList {
  const CallingList({
    required this.id,
    required this.name,
    this.clientId,
    this.agents = const [],
  });

  final String id;
  final String name;
  final String? clientId;
  final List<String> agents;

  factory CallingList.fromJson(Map<String, dynamic> j) => CallingList(
    id: _str(j['_id'] ?? j['id']) ?? '',
    name: _str(j['name']) ?? 'Untitled list',
    clientId: _str(j['clientId']),
    agents: (j['agents'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'clientId': clientId,
    'agents': agents,
  };
}

enum CallStatus {
  pending,
  called,
  rescheduled;

  static CallStatus parse(String? s) => switch (s?.toLowerCase()) {
    'called' || 'done' || 'completed' => CallStatus.called,
    'rescheduled' || 'scheduled' || 'schedule' => CallStatus.rescheduled,
    _ => CallStatus.pending,
  };

  /// Label as the Figma dashboard words it.
  String get label => switch (this) {
    CallStatus.pending => 'Pending',
    CallStatus.called => 'Done',
    CallStatus.rescheduled => 'Scheduled',
  };
}

class CallRecord {
  const CallRecord({
    required this.firstName,
    required this.lastName,
    this.title,
    this.phone,
    this.otherPhones = const [],
    this.email,
    this.address,
    this.company,
    this.age,
    this.zip,
    this.maritalStatus,
    this.notes,
    this.calledAt,
    this.rescheduledAt,
    this.createdAt,
    required this.status,
    this.agentName,
    this.agentId,
    this.duration,
    this.feedback,
  });

  final String firstName;
  final String lastName;
  final String? title;

  /// Kept as a string: the API sends a number, but a phone is not arithmetic.
  final String? phone;
  final List<String> otherPhones;
  final String? email;
  final String? address;
  final String? company;
  final int? age;
  final int? zip;
  final String? maritalStatus;
  final String? notes;
  final DateTime? calledAt;
  final DateTime? rescheduledAt;
  final DateTime? createdAt;
  final CallStatus status;
  final String? agentName;
  final String? agentId;
  final int? duration;
  final String? feedback;

  String get fullName => [
    title,
    firstName,
    lastName,
  ].whereType<String>().where((s) => s.isNotEmpty).join(' ');

  String get displayName => '$firstName $lastName'.trim();

  /// B-09: the server never sends status "rescheduled"; a call that was made
  /// and moved to a later time comes as status "called" with rescheduledAt
  /// set. Either form counts as scheduled.
  bool get isRescheduled =>
      status == CallStatus.rescheduled || rescheduledAt != null;

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();

  /// A stable identity for UI keys and local disposition notes.
  String get key => '${phone ?? ''}|${email ?? ''}|$firstName|$lastName';

  static DateTime? _date(Object? v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    // "2025-06-22 19:41:31" has no zone; treat it as given (the API is in IST,
    // but we do not know that for sure, so we do not shift it).
    return DateTime.tryParse(s.replaceFirst(' ', 'T'));
  }

  factory CallRecord.fromJson(Map<String, dynamic> j) {
    final others = <String>[];
    for (var i = 1; i <= 4; i++) {
      final v = j['Other Phone $i'];
      if (v != null && v.toString().isNotEmpty) others.add(v.toString());
    }
    return CallRecord(
      firstName: _str(j['FirstName'] ?? j['firstName']) ?? '',
      lastName: _str(j['LastName'] ?? j['lastName']) ?? '',
      title: _str(j['Title'] ?? j['title']),
      phone: _str(j['Phone'] ?? j['phone']),
      otherPhones: others,
      email: _str(j['Email'] ?? j['email']),
      address: _str(j['Address'] ?? j['address']),
      company: _str(j['Company'] ?? j['company']),
      age: _int(j['Age'] ?? j['age']),
      zip: _int(j['Zip'] ?? j['zip']),
      maritalStatus: _str(j['MaritalStatus'] ?? j['maritalStatus']),
      notes: _str(j['Notes'] ?? j['notes']),
      calledAt: _date(j['calledAt']),
      rescheduledAt: _date(j['rescheduledAt']),
      createdAt: _date(j['createdAt']),
      status: CallStatus.parse(_str(j['status'])),
      agentName: _str(j['agentName']),
      agentId: _str(j['agentId']),
      duration: _int(j['duration']),
      feedback: _str(j['feedback']),
    );
  }
}

class ListDetails {
  const ListDetails({
    required this.pending,
    required this.called,
    required this.rescheduled,
    required this.calls,
  });

  /// Counts as the server reports them. They need not equal `calls.length`
  /// (the sample data has 61 in counts and 50 records); we show both as sent.
  final int pending;
  final int called;
  final int rescheduled;
  final List<CallRecord> calls;

  // The server's three counts overlap: "rescheduled" calls are also among
  // "called" (sample: 27 pending + 23 called = 50 records, 11 of the called
  // have a rescheduledAt). The chart needs parts that add up to the whole,
  // so these split the records into three disjoint groups. With no records
  // they fall back to the summary numbers.

  /// Not yet called.
  int get pendingCount => calls.isEmpty
      ? pending
      : calls
            .where((r) => r.status == CallStatus.pending && !r.isRescheduled)
            .length;

  /// Called and finished (not moved to a later time).
  int get doneCount => calls.isEmpty
      ? (called - rescheduled).clamp(0, called)
      : calls
            .where((r) => r.status == CallStatus.called && !r.isRescheduled)
            .length;

  /// Moved to a later time.
  int get scheduledCount =>
      calls.isEmpty ? rescheduled : calls.where((r) => r.isRescheduled).length;

  /// Every contact in the list, counted once.
  int get total => pendingCount + doneCount + scheduledCount;

  factory ListDetails.fromJson(Map<String, dynamic> j) => ListDetails(
    pending: _int(j['pending']) ?? 0,
    called: _int(j['called'] ?? j['done']) ?? 0,
    rescheduled: _int(j['rescheduled'] ?? j['scheduled']) ?? 0,
    calls: (j['calls'] as List? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(CallRecord.fromJson)
        .toList(),
  );
}
