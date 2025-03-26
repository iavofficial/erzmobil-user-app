import 'package:erzmobil/debug/Logger.dart';
import 'package:erzmobil/model/Bus.dart';
import 'package:erzmobil/model/Location.dart';
import 'package:erzmobil/model/VehicleType.dart';
import 'package:erzmobil/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Journey {
  final int id;
  final Address? startAddress;
  final Address? destinationAddress;
  final String? time;
  final DateTime? departureTime;
  final DateTime? estimatedArrivalTime;
  final bool isDeparture;
  final int seats;
  final int seatsWheelchair;
  final int? routeId;
  final String? status;
  final String? cancellationReason;
  final DateTime? cancelledOn;
  final String? ticketType;
  final DateTime? creationDate;
  String? favoriteName;
  Bus? bus;

  Journey(
      this.id,
      this.startAddress,
      this.destinationAddress,
      this.time,
      this.departureTime,
      this.estimatedArrivalTime,
      this.isDeparture,
      this.seats,
      this.seatsWheelchair,
      this.routeId,
      this.status,
      this.cancellationReason,
      this.cancelledOn,
      this.ticketType,
      this.creationDate,
      this.bus,
      {this.favoriteName = ""});

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
        json['id'] != null ? json['id'] as int : 0,
        json['startAddress'] != null
            ? new Address.fromJson(json['startAddress'])
            : null,
        json['destinationAddress'] != null
            ? new Address.fromJson(json['destinationAddress'])
            : null,
        json['time'],
        json['departureTime'] != null
            ? DateTime.parse(json['departureTime'] as String)
            : null,
        null,
        json['isDeparture'] as bool,
        json['seats'] as int,
        json['seatsWheelchair'] != null ? json['seatsWheelchair'] as int : 0,
        json['routeId'],
        json['status'] != null ? json['status'] as String : "UNKNOWN",
        json['cancellationReason'],
        json['cancelledOn'] != null
            ? DateTime.parse(json['cancelledOn'] as String)
            : null,
        json['ticketType'] != null ? json['ticketType'] as String : null,
        null,
        json['bus'] != null ? new Bus.fromJsonDirectus(json['bus']) : null,
        favoriteName: json['favoriteName'] != null
            ? json['favoriteName'] as String
            : null);
  }

  factory Journey.fromJsonDirectus(Map<String, dynamic> json) {
    return Journey(
        json['id'] as int,
        json['start_address_id'] != null
            ? new Address.fromJsonDirectus(json['start_address_id'])
            : null,
        json['destination_address_id'] != null
            ? new Address.fromJsonDirectus(json['destination_address_id'])
            : null,
        json['timestamp'],
        json['departure_time'] != null
            ? DateTime.parse(json['departure_time'] as String)
            : null,
        json['arrival_time'] != null
            ? DateTime.parse(json['arrival_time'] as String)
            : null,
        json['is_departure'] as bool,
        json['seats'] as int,
        json['seats_wheelchair'] != null ? json['seats_wheelchair'] as int : 0,
        json['route_id'],
        json['status'],
        json['cancellation_reason'],
        json['cancelled_on'] != null
            ? DateTime.parse(json['cancelled_on'] as String)
            : null,
        json['ticketType'] != null ? json['ticketType'] as String : null,
        json['date_created'] != null
            ? DateTime.parse(json['date_created'] as String)
            : null,
        json['bus'] != null ? new Bus.fromJsonDirectus(json['bus']) : null,
        favoriteName: json['favoriteName'] != null
            ? json['favoriteName'] as String
            : null);
  }

  /*bool equals(Journey other) {
    return this.startAddress!.location!.lat ==
            other.startAddress!.location!.lat &&
        this.startAddress!.location!.lng == other.startAddress!.location!.lng;
  }*/

  String getRequestStateString(BuildContext context) {
    switch (status) {
      case 'Started':
        return AppLocalizations.of(context)!.journeyBooked;
      case 'Reserved':
        return AppLocalizations.of(context)!.journeyReserved;
      case 'RideStarted':
        return AppLocalizations.of(context)!.journeyStarted;
      case 'Cancelled':
        return AppLocalizations.of(context)!.journeyCancelled;
      case 'RideFinished':
        return AppLocalizations.of(context)!.journeyFinished;
      default:
        Logger.info("Journey status is $status");
        return "---";
    }
  }

  String getOrderStatusAsString() {
    return Uri.encodeComponent(Utils().getFormatISOTime(departureTime!));
  }

  String getEncodedDepartureTime() {
    String isoFormatTime = Utils().getFormatISOTime(departureTime!);
    Logger.info("isoFormatTime: " + isoFormatTime);
    String encodedDepartureTime =
        Uri.encodeComponent(Utils().getFormatISOTime(departureTime!));
    Logger.info("encodedDepartureTime: " + encodedDepartureTime);
    return encodedDepartureTime;
  }

  Map<String, dynamic> toJson() {
    return {
      "startAddress": this.startAddress!.toJson(),
      "destinationAddress": this.destinationAddress!.toJson(),
      "time": departureTime != null
          ? Utils().getFormatISOTime(departureTime!)
          : null,
      "isDeparture": this.isDeparture,
      "seats": this.seats,
      "seatsWheelchair": this.seatsWheelchair,
      "ticketType": this.ticketType,
      "bus": this.bus,
      "favoriteName": this.favoriteName
    };
  }

  Map<String, dynamic> toJsonDirectus() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['time'] = Utils().getFormatISOTime(departureTime!);
    data['is_departure'] = this.isDeparture;
    data['seats'] = this.seats;
    data['seats_wheelchair'] = this.seatsWheelchair;
    if (this.startAddress != null) {
      data['start_address_id'] = this.startAddress!.id;
    }
    if (this.destinationAddress != null) {
      data['destination_address_id'] = this.destinationAddress!.id;
    }
    data['ticketType'] = this.ticketType;
    data['bus'] = this.bus;
    if (this.favoriteName != null) {
      data['favoriteName'] = this.favoriteName;
    }
    return data;
  }

  void logJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    if (this.startAddress != null) {
      data['startAddress'] = this.startAddress!.toJson();
    }
    if (this.destinationAddress != null) {
      data['destinationAddress'] = this.destinationAddress!.toJson();
    }
    if (this.time != null) {
      data['time'] = time;
    }
    if (this.departureTime != null) {
      data['departureTime'] = Utils().getFormatISOTime(this.departureTime!);
    }
    data['isDeparture'] = this.isDeparture;
    data['seats'] = this.seats;
    data['seatsWheelchair'] = this.seatsWheelchair;
    if (routeId != null) {
      data['routeId'] = this.routeId;
    }
    data['status'] = this.status;
    if (this.cancellationReason != null) {
      data['cancellationReason'] = this.cancellationReason;
    }
    data['bus'] = this.bus;
    data['ticketType'] = this.ticketType;
    Logger.info(data.toString());
  }

  String getRequestVehicletypeString(BuildContext context) {
    if (bus == null) {
      return AppLocalizations.of(context)!.electrifiedBus;
    } else {
      String licensePlate =
          bus!.licenseplate == null ? Utils.EMPTY : ", " + bus!.licenseplate!;
      String vehicleType;
      switch (bus!.vehicletype) {
        case VehicleType.autonomousShuttle:
          vehicleType = AppLocalizations.of(context)!.autonomousShuttle;
          break;
        case VehicleType.other:
          vehicleType = AppLocalizations.of(context)!.other;
          break;
        case VehicleType.electrifiedBus:
        default:
          Logger.info("Journey vehicletype is ${bus!.vehicletype}");
          vehicleType = AppLocalizations.of(context)!.electrifiedBus;
      }

      return vehicleType + licensePlate;
    }
  }
}

class Address {
  final int id;
  final String? label;
  final Location? location;

  const Address(this.id, this.label, this.location);

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
        json['id'] as int,
        json['label'] as String,
        json['location'] != null
            ? new Location.fromJson(json['location'])
            : null);
  }

  factory Address.fromJsonDirectus(Map<String, dynamic> json) {
    return Address(
        json['id'] as int,
        json['label'] as String,
        json['location'] != null
            ? new Location.fromJsonDirectus(json['location'])
            : null);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['label'] = this.label;
    if (this.location != null) {
      data['location'] = this.location!.toJson();
    }
    return data;
  }

  @override
  String toString() {
    if (label != null) {
      return this.label!;
    }
    return super.toString();
  }
}
