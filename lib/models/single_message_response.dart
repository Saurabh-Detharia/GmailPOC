class SingleMessageResponse {
  SingleMessageResponse({
    this.id,
    this.threadId,
    this.labelIds,
    this.snippet,
    this.payload,
    this.sizeEstimate,
    this.historyId,
    this.internalDate,
  });

  String id;
  String threadId;
  List<String> labelIds;
  String snippet;
  Payload payload;
  int sizeEstimate;
  String historyId;
  String internalDate;

  factory SingleMessageResponse.fromJson(Map<String, dynamic> json) => SingleMessageResponse(
    id: json["id"],
    threadId: json["threadId"],
    labelIds: List<String>.from(json["labelIds"].map((x) => x)),
    snippet: json["snippet"],
    payload: Payload.fromJson(json["payload"]),
    sizeEstimate: json["sizeEstimate"],
    historyId: json["historyId"],
    internalDate: json["internalDate"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "threadId": threadId,
    "labelIds": List<dynamic>.from(labelIds.map((x) => x)),
    "snippet": snippet,
    "payload": payload.toJson(),
    "sizeEstimate": sizeEstimate,
    "historyId": historyId,
    "internalDate": internalDate,
  };
}

class Payload {
  Payload({
    this.partId,
    this.mimeType,
    this.filename,
    this.headers,
    this.body,
  });

  String partId;
  String mimeType;
  String filename;
  List<Header> headers;
  Body body;

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
    partId: json["partId"],
    mimeType: json["mimeType"],
    filename: json["filename"],
    headers: List<Header>.from(json["headers"].map((x) => Header.fromJson(x))),
    body: Body.fromJson(json["body"]),
  );

  Map<String, dynamic> toJson() => {
    "partId": partId,
    "mimeType": mimeType,
    "filename": filename,
    "headers": List<dynamic>.from(headers.map((x) => x.toJson())),
    "body": body.toJson(),
  };
}

class Body {
  Body({
    this.size,
    this.data,
  });

  int size;
  String data;

  factory Body.fromJson(Map<String, dynamic> json) => Body(
    size: json["size"],
    data: json["data"],
  );

  Map<String, dynamic> toJson() => {
    "size": size,
    "data": data,
  };
}

class Header {
  Header({
    this.name,
    this.value,
  });

  String name;
  String value;

  factory Header.fromJson(Map<String, dynamic> json) => Header(
    name: json["name"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "value": value,
  };
}
