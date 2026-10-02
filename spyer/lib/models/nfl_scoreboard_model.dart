class NflScoreboardResponse {
  final String? leagueName;
  final String? leagueSeason;
  final int? seasonYear;
  final int? seasonType;
  final int? weekNumber;
  final List<NflEvent> events;

  NflScoreboardResponse({
    this.leagueName,
    this.leagueSeason,
    this.seasonYear,
    this.seasonType,
    this.weekNumber,
    required this.events,
  });

  factory NflScoreboardResponse.fromJson(Map<String, dynamic> json) {
    String? leagueName;
    String? leagueSeason;
    final leaguesData = json['leagues'];
    if (leaguesData is List && leaguesData.isNotEmpty) {
      final firstLeague = leaguesData.first;
      if (firstLeague is Map) {
        final nameVal = firstLeague['name'];
        final abbrVal = firstLeague['abbreviation'];
        leagueName = nameVal?.toString() ?? abbrVal?.toString();

        final seasonVal = firstLeague['season'];
        if (seasonVal is Map) {
          leagueSeason = seasonVal['displayName']?.toString();
        }
      }
    }

    int? seasonYear;
    int? seasonType;
    final seasonData = json['season'];
    if (seasonData is Map) {
      final yearVal = seasonData['year'];
      final typeVal = seasonData['type'];
      seasonYear = yearVal is int ? yearVal : int.tryParse(yearVal?.toString() ?? '');
      seasonType = typeVal is int ? typeVal : int.tryParse(typeVal?.toString() ?? '');
    }

    int? weekNumber;
    final weekData = json['week'];
    if (weekData is Map) {
      final numVal = weekData['number'];
      weekNumber = numVal is int ? numVal : int.tryParse(numVal?.toString() ?? '');
    }

    final eventsList = <NflEvent>[];
    final eventsData = json['events'];
    if (eventsData is List) {
      for (final eventItem in eventsData) {
        if (eventItem is Map) {
          final eventMap = eventItem.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          eventsList.add(NflEvent.fromJson(eventMap));
        }
      }
    }

    return NflScoreboardResponse(
      leagueName: leagueName ?? 'NFL',
      leagueSeason: leagueSeason,
      seasonYear: seasonYear,
      seasonType: seasonType,
      weekNumber: weekNumber,
      events: eventsList,
    );
  }
}

class NflEvent {
  final String id;
  final String name;
  final String shortName;
  final DateTime? date;
  final NflStatus status;
  final List<NflCompetition> competitions;
  final String? weatherDisplay;
  final int? temperature;

  NflEvent({
    required this.id,
    required this.name,
    required this.shortName,
    this.date,
    required this.status,
    required this.competitions,
    this.weatherDisplay,
    this.temperature,
  });

  NflCompetition? get primaryCompetition =>
      competitions.isNotEmpty ? competitions.first : null;

  NflCompetitor? get homeCompetitor => primaryCompetition?.homeCompetitor;
  NflCompetitor? get awayCompetitor => primaryCompetition?.awayCompetitor;

  factory NflEvent.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    final dateVal = json['date'];
    if (dateVal != null) {
      parsedDate = DateTime.tryParse(dateVal.toString())?.toLocal();
    }

    final comps = <NflCompetition>[];
    final compsData = json['competitions'];
    if (compsData is List) {
      for (final item in compsData) {
        if (item is Map) {
          final map = item.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          comps.add(NflCompetition.fromJson(map));
        }
      }
    }

    String? weather;
    int? temp;
    final weatherData = json['weather'];
    if (weatherData is Map) {
      weather = weatherData['displayValue']?.toString();
      final tempVal = weatherData['temperature'];
      if (tempVal != null) {
        temp = tempVal is int ? tempVal : int.tryParse(tempVal.toString());
      }
    }

    final statusData = json['status'];
    final statusMap = statusData is Map
        ? statusData.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    return NflEvent(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Partido NFL',
      shortName: json['shortName']?.toString() ?? '',
      date: parsedDate,
      status: NflStatus.fromJson(statusMap),
      competitions: comps,
      weatherDisplay: weather,
      temperature: temp,
    );
  }
}

class NflCompetition {
  final String id;
  final List<NflCompetitor> competitors;
  final NflVenue? venue;
  final List<String> broadcasts;

  NflCompetition({
    required this.id,
    required this.competitors,
    this.venue,
    required this.broadcasts,
  });

  NflCompetitor? get homeCompetitor {
    try {
      return competitors.firstWhere((c) => c.homeAway.toLowerCase() == 'home');
    } catch (_) {
      return competitors.isNotEmpty ? competitors.first : null;
    }
  }

  NflCompetitor? get awayCompetitor {
    try {
      return competitors.firstWhere((c) => c.homeAway.toLowerCase() == 'away');
    } catch (_) {
      return competitors.length > 1 ? competitors[1] : null;
    }
  }

  factory NflCompetition.fromJson(Map<String, dynamic> json) {
    final compList = <NflCompetitor>[];
    final competitorsData = json['competitors'];
    if (competitorsData is List) {
      for (final c in competitorsData) {
        if (c is Map) {
          final map = c.map((key, value) => MapEntry(key.toString(), value));
          compList.add(NflCompetitor.fromJson(map));
        }
      }
    }

    NflVenue? parsedVenue;
    final venueData = json['venue'];
    if (venueData is Map) {
      final map = venueData.map((key, value) => MapEntry(key.toString(), value));
      parsedVenue = NflVenue.fromJson(map);
    }

    final broadcastNames = <String>[];
    final broadcastsData = json['broadcasts'];
    if (broadcastsData is List) {
      for (final b in broadcastsData) {
        if (b is Map) {
          final namesData = b['names'];
          if (namesData is List) {
            for (final n in namesData) {
              if (n != null) broadcastNames.add(n.toString());
            }
          }
        }
      }
    }

    return NflCompetition(
      id: json['id']?.toString() ?? '',
      competitors: compList,
      venue: parsedVenue,
      broadcasts: broadcastNames,
    );
  }
}

class NflCompetitor {
  final String id;
  final String homeAway;
  final String score;
  final bool? winner;
  final NflTeam team;
  final String? recordSummary;

  NflCompetitor({
    required this.id,
    required this.homeAway,
    required this.score,
    this.winner,
    required this.team,
    this.recordSummary,
  });

  factory NflCompetitor.fromJson(Map<String, dynamic> json) {
    String? record;
    final recordsData = json['records'];
    if (recordsData is List && recordsData.isNotEmpty) {
      for (final r in recordsData) {
        if (r is Map && r['type']?.toString() == 'total') {
          record = r['summary']?.toString();
          break;
        }
      }
      if (record == null) {
        final firstRecord = recordsData.first;
        if (firstRecord is Map) {
          record = firstRecord['summary']?.toString();
        }
      }
    }

    final teamData = json['team'];
    final teamMap = teamData is Map
        ? teamData.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final winnerVal = json['winner'];
    final bool? parsedWinner = winnerVal is bool ? winnerVal : null;

    return NflCompetitor(
      id: json['id']?.toString() ?? '',
      homeAway: json['homeAway']?.toString() ?? 'unknown',
      score: json['score']?.toString() ?? '0',
      winner: parsedWinner,
      team: NflTeam.fromJson(teamMap),
      recordSummary: record,
    );
  }
}

class NflTeam {
  final String id;
  final String name;
  final String displayName;
  final String shortDisplayName;
  final String abbreviation;
  final String? colorHex;
  final String? alternateColorHex;
  final String? logo;

  NflTeam({
    required this.id,
    required this.name,
    required this.displayName,
    required this.shortDisplayName,
    required this.abbreviation,
    this.colorHex,
    this.alternateColorHex,
    this.logo,
  });

  factory NflTeam.fromJson(Map<String, dynamic> json) {
    return NflTeam(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      displayName: json['displayName']?.toString() ??
          json['name']?.toString() ??
          'Equipo',
      shortDisplayName: json['shortDisplayName']?.toString() ??
          json['name']?.toString() ??
          '',
      abbreviation: json['abbreviation']?.toString() ?? '',
      colorHex: json['color']?.toString(),
      alternateColorHex: json['alternateColor']?.toString(),
      logo: json['logo']?.toString(),
    );
  }
}

class NflStatus {
  final double clock;
  final String displayClock;
  final int period;
  final String state; // "pre", "in", "post"
  final bool completed;
  final String description; // "Scheduled", "In Progress", "Final", "Halftime"
  final String detail; // "Thu, October 1st at 8:15 PM EDT"
  final String shortDetail; // "10/1 - 8:15 PM EDT"

  NflStatus({
    required this.clock,
    required this.displayClock,
    required this.period,
    required this.state,
    required this.completed,
    required this.description,
    required this.detail,
    required this.shortDetail,
  });

  bool get isLive => state.toLowerCase() == 'in';
  bool get isScheduled => state.toLowerCase() == 'pre';
  bool get isFinal => completed || state.toLowerCase() == 'post';

  factory NflStatus.fromJson(Map<String, dynamic> json) {
    final typeData = json['type'];
    final typeMap = typeData is Map
        ? typeData.map((k, v) => MapEntry(k.toString(), v))
        : <String, dynamic>{};

    final clockVal = json['clock'];
    double parsedClock = 0.0;
    if (clockVal is num) {
      parsedClock = clockVal.toDouble();
    } else if (clockVal != null) {
      parsedClock = double.tryParse(clockVal.toString()) ?? 0.0;
    }

    final periodVal = json['period'];
    int parsedPeriod = 0;
    if (periodVal is int) {
      parsedPeriod = periodVal;
    } else if (periodVal != null) {
      parsedPeriod = int.tryParse(periodVal.toString()) ?? 0;
    }

    return NflStatus(
      clock: parsedClock,
      displayClock: json['displayClock']?.toString() ?? '0:00',
      period: parsedPeriod,
      state: typeMap['state']?.toString() ?? 'pre',
      completed: typeMap['completed'] == true,
      description: typeMap['description']?.toString() ?? 'Scheduled',
      detail: typeMap['detail']?.toString() ?? '',
      shortDetail: typeMap['shortDetail']?.toString() ?? '',
    );
  }
}

class NflVenue {
  final String fullName;
  final String? city;
  final String? state;

  NflVenue({required this.fullName, this.city, this.state});

  String get location {
    if (city != null && state != null) return '$city, $state';
    if (city != null) return city!;
    return '';
  }

  factory NflVenue.fromJson(Map<String, dynamic> json) {
    String? city;
    String? state;
    final addressData = json['address'];
    if (addressData is Map) {
      city = addressData['city']?.toString();
      state = addressData['state']?.toString();
    }
    return NflVenue(
      fullName: json['fullName']?.toString() ?? '',
      city: city,
      state: state,
    );
  }
}
