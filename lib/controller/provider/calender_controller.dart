class CalenderSettingsModel {
  int? statusCode;
  bool? success;
  String? message;
  Data? data;

  CalenderSettingsModel(
      {this.statusCode, this.success, this.message, this.data});

  CalenderSettingsModel.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  DefaultSchedule? defaultSchedule;
  GoogleCalendarSync? googleCalendarSync;
  String? sId;
  String? providerId;
  List<CustomDates>? customDates;
  List<RecurringRules>? recurringRules;
  int? bufferMinutes;
  int? advanceNoticeHours;
  int? maxBookingsPerDay;
  int? maxBookingsPerWeek;
  bool? autoBlockAfterBooking;
  int? autoBlockDuration;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? id;

  Data(
      {this.defaultSchedule,
      this.googleCalendarSync,
      this.sId,
      this.providerId,
      this.customDates,
      this.recurringRules,
      this.bufferMinutes,
      this.advanceNoticeHours,
      this.maxBookingsPerDay,
      this.maxBookingsPerWeek,
      this.autoBlockAfterBooking,
      this.autoBlockDuration,
      this.createdAt,
      this.updatedAt,
      this.iV,
      this.id});

  Data.fromJson(Map<String, dynamic> json) {
    defaultSchedule = json['defaultSchedule'] != null
        ? new DefaultSchedule.fromJson(json['defaultSchedule'])
        : null;
    googleCalendarSync = json['googleCalendarSync'] != null
        ? new GoogleCalendarSync.fromJson(json['googleCalendarSync'])
        : null;
    sId = json['_id'];
    providerId = json['providerId'];
    if (json['customDates'] != null) {
      customDates = <CustomDates>[];
      json['customDates'].forEach((v) {
        customDates!.add(new CustomDates.fromJson(v));
      });
    }
    if (json['recurringRules'] != null) {
      recurringRules = <RecurringRules>[];
      json['recurringRules'].forEach((v) {
        recurringRules!.add(new RecurringRules.fromJson(v));
      });
    }
    bufferMinutes = json['bufferMinutes'];
    advanceNoticeHours = json['advanceNoticeHours'];
    maxBookingsPerDay = json['maxBookingsPerDay'];
    maxBookingsPerWeek = json['maxBookingsPerWeek'];
    autoBlockAfterBooking = json['autoBlockAfterBooking'];
    autoBlockDuration = json['autoBlockDuration'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.defaultSchedule != null) {
      data['defaultSchedule'] = this.defaultSchedule!.toJson();
    }
    if (this.googleCalendarSync != null) {
      data['googleCalendarSync'] = this.googleCalendarSync!.toJson();
    }
    data['_id'] = this.sId;
    data['providerId'] = this.providerId;
    if (this.customDates != null) {
      data['customDates'] = this.customDates!.map((v) => v.toJson()).toList();
    }
    if (this.recurringRules != null) {
      data['recurringRules'] =
          this.recurringRules!.map((v) => v.toJson()).toList();
    }
    data['bufferMinutes'] = this.bufferMinutes;
    data['advanceNoticeHours'] = this.advanceNoticeHours;
    data['maxBookingsPerDay'] = this.maxBookingsPerDay;
    data['maxBookingsPerWeek'] = this.maxBookingsPerWeek;
    data['autoBlockAfterBooking'] = this.autoBlockAfterBooking;
    data['autoBlockDuration'] = this.autoBlockDuration;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['id'] = this.id;
    return data;
  }
}

class DefaultSchedule {
  Monday? monday;
  Monday? tuesday;
  Monday? wednesday;
  Monday? thursday;
  Monday? friday;
  Monday? saturday;
  Monday? sunday;

  DefaultSchedule(
      {this.monday,
      this.tuesday,
      this.wednesday,
      this.thursday,
      this.friday,
      this.saturday,
      this.sunday});

  DefaultSchedule.fromJson(Map<String, dynamic> json) {
    monday =
        json['monday'] != null ? new Monday.fromJson(json['monday']) : null;
    tuesday =
        json['tuesday'] != null ? new Monday.fromJson(json['tuesday']) : null;
    wednesday = json['wednesday'] != null
        ? new Monday.fromJson(json['wednesday'])
        : null;
    thursday =
        json['thursday'] != null ? new Monday.fromJson(json['thursday']) : null;
    friday =
        json['friday'] != null ? new Monday.fromJson(json['friday']) : null;
    saturday =
        json['saturday'] != null ? new Monday.fromJson(json['saturday']) : null;
    sunday =
        json['sunday'] != null ? new Monday.fromJson(json['sunday']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.monday != null) {
      data['monday'] = this.monday!.toJson();
    }
    if (this.tuesday != null) {
      data['tuesday'] = this.tuesday!.toJson();
    }
    if (this.wednesday != null) {
      data['wednesday'] = this.wednesday!.toJson();
    }
    if (this.thursday != null) {
      data['thursday'] = this.thursday!.toJson();
    }
    if (this.friday != null) {
      data['friday'] = this.friday!.toJson();
    }
    if (this.saturday != null) {
      data['saturday'] = this.saturday!.toJson();
    }
    if (this.sunday != null) {
      data['sunday'] = this.sunday!.toJson();
    }
    return data;
  }
}

class Monday {
  String? start;
  String? end;
  bool? isActive;
  int? maxBookings;
  String? sId;

  Monday({this.start, this.end, this.isActive, this.maxBookings, this.sId});

  Monday.fromJson(Map<String, dynamic> json) {
    start = json['start'];
    end = json['end'];
    isActive = json['isActive'];
    maxBookings = json['maxBookings'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['start'] = this.start;
    data['end'] = this.end;
    data['isActive'] = this.isActive;
    data['maxBookings'] = this.maxBookings;
    data['_id'] = this.sId;
    return data;
  }
}

class GoogleCalendarSync {
  String? calendarId;
  bool? syncEnabled;

  GoogleCalendarSync({this.calendarId, this.syncEnabled});

  GoogleCalendarSync.fromJson(Map<String, dynamic> json) {
    calendarId = json['calendarId'];
    syncEnabled = json['syncEnabled'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['calendarId'] = this.calendarId;
    data['syncEnabled'] = this.syncEnabled;
    return data;
  }
}

class CustomDates {
  String? date;
  String? type;
  String? start;
  String? end;
  int? maxBookings;
  String? note;
  double? rateMultiplier;
  String? sId;

  CustomDates(
      {this.date,
      this.type,
      this.start,
      this.end,
      this.maxBookings,
      this.note,
      this.rateMultiplier,
      this.sId});

  CustomDates.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    type = json['type'];
    start = json['start'];
    end = json['end'];
    maxBookings = json['maxBookings'];
    note = json['note'];
    rateMultiplier = json['rateMultiplier'];
    sId = json['_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['type'] = this.type;
    data['start'] = this.start;
    data['end'] = this.end;
    data['maxBookings'] = this.maxBookings;
    data['note'] = this.note;
    data['rateMultiplier'] = this.rateMultiplier;
    data['_id'] = this.sId;
    return data;
  }
}

class RecurringRules {
  String? type;
  int? dayOfWeek;
  bool? active;
  String? sId;
  String? start;
  String? end;
  int? maxBookings;

  RecurringRules(
      {this.type,
      this.dayOfWeek,
      this.active,
      this.sId,
      this.start,
      this.end,
      this.maxBookings});

  RecurringRules.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    dayOfWeek = json['dayOfWeek'];
    active = json['active'];
    sId = json['_id'];
    start = json['start'];
    end = json['end'];
    maxBookings = json['maxBookings'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['type'] = this.type;
    data['dayOfWeek'] = this.dayOfWeek;
    data['active'] = this.active;
    data['_id'] = this.sId;
    data['start'] = this.start;
    data['end'] = this.end;
    data['maxBookings'] = this.maxBookings;
    return data;
  }
}
