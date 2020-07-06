class UserMessageListResponse {
  UserMessageListResponse({
    this.messages,
    this.nextPageToken,
    this.resultSizeEstimate,
  });

  List<Message> messages;
  String nextPageToken;
  int resultSizeEstimate;

  factory UserMessageListResponse.fromJson(Map<String, dynamic> json) => UserMessageListResponse(
    messages: List<Message>.from(json["messages"].map((x) => Message.fromJson(x))),
    nextPageToken: json["nextPageToken"],
    resultSizeEstimate: json["resultSizeEstimate"],
  );

  Map<String, dynamic> toJson() => {
    "messages": List<dynamic>.from(messages.map((x) => x.toJson())),
    "nextPageToken": nextPageToken,
    "resultSizeEstimate": resultSizeEstimate,
  };
}

class Message {
  Message({
    this.id,
    this.threadId,
  });

  String id;
  String threadId;

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    id: json["id"],
    threadId: json["threadId"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "threadId": threadId,
  };
}