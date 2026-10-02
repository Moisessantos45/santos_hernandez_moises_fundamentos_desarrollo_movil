import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spyer/models/nfl_scoreboard_model.dart';
import 'package:spyer/presentation/screens/scoreboard_screen.dart';
import 'package:spyer/presentation/widgets/game_card.dart';
import 'package:spyer/services/nfl_api_service.dart';

class FakeNflApiService extends NflApiService {
  @override
  Future<NflScoreboardResponse> getScoreboard({int? limit, int? page, String? dates}) async {
    return NflScoreboardResponse(
      leagueName: 'NFL',
      weekNumber: 4,
      seasonYear: 2026,
      events: [
        NflEvent(
          id: '1',
          name: 'Pittsburgh Steelers at Cleveland Browns',
          shortName: 'PIT @ CLE',
          status: NflStatus(
            clock: 0,
            displayClock: '0:00',
            period: 0,
            state: 'pre',
            completed: false,
            description: 'Scheduled',
            detail: '8:15 PM EDT',
            shortDetail: '8:15 PM',
          ),
          competitions: [
            NflCompetition(
              id: '1',
              broadcasts: ['ESPN'],
              competitors: [
                NflCompetitor(
                  id: '5',
                  homeAway: 'home',
                  score: '0',
                  recordSummary: '2-1',
                  team: NflTeam(
                    id: '5',
                    name: 'Browns',
                    displayName: 'Cleveland Browns',
                    shortDisplayName: 'Browns',
                    abbreviation: 'CLE',
                  ),
                ),
                NflCompetitor(
                  id: '23',
                  homeAway: 'away',
                  score: '0',
                  recordSummary: '2-1',
                  team: NflTeam(
                    id: '23',
                    name: 'Steelers',
                    displayName: 'Pittsburgh Steelers',
                    shortDisplayName: 'Steelers',
                    abbreviation: 'PIT',
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

void main() {
  testWidgets('ScoreboardScreen displays games correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ScoreboardScreen(apiService: FakeNflApiService()),
      ),
    );

    // Initial loading or frame
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('NFL Scoreboard'), findsOneWidget);
    expect(find.text('Cleveland Browns'), findsOneWidget);
    expect(find.text('Pittsburgh Steelers'), findsOneWidget);
    expect(find.byType(GameCard), findsOneWidget);
  });
}
