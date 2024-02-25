class AttendanceModel {
  dynamic? id;
  String? date;
  String? timeIn;
  String? userId;
  dynamic? latIn;
  dynamic? lngIn;
 dynamic? bookerName;


  AttendanceModel({
    this.id,
    this.date,
    this.timeIn,
    this.userId,
    this.latIn,
    this.lngIn,
    this.bookerName

  });

  factory AttendanceModel.fromMap(Map<dynamic, dynamic> json) {

    return AttendanceModel(
        id: json['id'],
        date : json['date'],
        timeIn: json['timeIn'],
        userId: json['userId'],
        latIn: json['latIn'],
        lngIn: json['lngIn'],
      bookerName: json['bookerName']


    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'timeIn': timeIn,
      'userId': userId,
      'latIn': latIn,
      'lngIn': lngIn,
      'bookerName': bookerName

    };
  }
}


class AttendanceOutModel {
  dynamic? id;
  String? date;
  String? timeOut;
  String? userId;
  dynamic? totalTime;
  dynamic? latOut;
  dynamic? lngOut;
  dynamic? totalDistance;


  AttendanceOutModel({
    this.id,
    this.date,
    this.timeOut,
    this.userId,
    this.totalTime,
    this.latOut,
    this.lngOut,
    this.totalDistance
  });

  factory AttendanceOutModel.fromMap(Map<dynamic, dynamic> json) {

    return AttendanceOutModel(
      id: json['id'],
      date : json['date'],
      timeOut: json['timeOut'],
      userId: json['userId'],
      totalTime: json['totalTime'],
      latOut: json['latOut'],
      lngOut:json['lngOut'],
      totalDistance: json['totalDistance']

    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'timeOut': timeOut,
      'userId': userId,
      'totalTime':totalTime,
      'latOut': latOut,
      'lngOut':lngOut,
      'totalDistance': totalDistance
    };
  }
}