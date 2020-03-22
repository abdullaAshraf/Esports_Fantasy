import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart';
import '../models/player.dart';
import '../models/game.dart';
import 'dart:convert';

class HttpService {
  static String baseUrl = 'https://esports.now.sh';

  Duration _cacheValidDuration;
  DateTime _lastFetchTime;
  List<Player> _allRecords;

  static const int UnassignableAfterGames = 3;
  static const int UnassignableAfterDays = 30;

  HttpService() {
    _cacheValidDuration = Duration(minutes: 60);
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);
    _allRecords = [];
  }

  Future<void> refreshAllRecords() async {
    // This makes the actual HTTP request
    _allRecords = await getPlayersAPI();
    _lastFetchTime = DateTime.now();
  }

  Future<List<Player>> getPlayers({bool forceRefresh = false}) async {
    bool shouldRefreshFromApi = (null == _allRecords ||
        _allRecords.isEmpty ||
        null == _lastFetchTime ||
        _lastFetchTime.isBefore(DateTime.now().subtract(_cacheValidDuration)) ||
        forceRefresh);

    if (shouldRefreshFromApi) await refreshAllRecords();

    return _allRecords;
  }

  Future<Player> getPlayer(String id, {bool forceRefresh = false}) async {
    bool shouldRefreshFromApi = (null == _allRecords ||
        _allRecords.isEmpty ||
        null == _lastFetchTime ||
        _lastFetchTime.isBefore(DateTime.now().subtract(_cacheValidDuration)) ||
        forceRefresh);

    if (shouldRefreshFromApi) await refreshAllRecords();

    for (Player player in _allRecords) {
      if (player.id == id) {
        return player;
      }
    }
    return Future.value(Player.empty());
  }

  Future<List<Player>> getPlayersAPI() async {
    String url = baseUrl + '/Players';
    Map<String, String> headers = {"Content-type": "application/json"};
    Response response = await get(url, headers: headers);

    if (response.statusCode == 200) {
      List<dynamic> players = jsonDecode(response.body);
      List<Player> playersMapped = players.map((data) => Player.fromJson(data)).toList();
      return playersMapped;
    } else {
      throw Exception('Failed to load players');
    }
  }

  double calculatePlayerPoints(List<Game> games) {
    double totalPoints = 0;
    double gamePoints = 0;
    int gameCount = 0;
    for (var game in games) {
      if (gameCount + 1 == game.roundNumber)
        gameCount++;
      else {
        totalPoints += gamePoints / gameCount;
        gameCount = 1;
        gamePoints = 0;
      }

      gamePoints += 3 * game.kills;
      gamePoints -= 1 * game.deaths;
      gamePoints += 1.5 * game.assists;
      gamePoints += 0.02 * game.cs;

      if (game.kills + game.assists >= 10) gamePoints += 3;
      if (game.win) {
        if (game.length <= 20)
          gamePoints += 5;
        else if (game.length <= 30)
          gamePoints += 3;
        else
          gamePoints += 2;
      }
      totalPoints += gamePoints / gameCount;
    }
    return totalPoints;
  }

  Future<double> getPlayerPoints(Player player, Timestamp date) async {
    if (player.id == "none") return 0;
    String playerLink = player.tag + " (" + player.originalName + ")";
    List<Game> games = await getGamesAPI(player.tournament, playerLink, date);
    double points = calculatePlayerPoints(games);
    return points;
  }

  Future<double> getPlayerSeasonPoints(Player player) async {
    var date = Timestamp.fromMillisecondsSinceEpoch(0);
    String playerLink = player.tag + " (" + player.originalName + ")";
    List<Game> games = await getGamesAPI(player.tournament, playerLink, date);
    double points = calculatePlayerPoints(games);
    return points;
  }

  Future<bool> unassignable(String tournament, String team, Timestamp date) async {
    var since = date.toDate().toUtc();
    var now = new DateTime.now().toUtc();
    var daysSinceAssign = now.difference(since).inDays;
    if (daysSinceAssign >= UnassignableAfterDays) return true;
    var gamesSinceAssign = await getTeamMatchCountAPI(tournament, team, date);
    if (gamesSinceAssign >= UnassignableAfterGames) return true;
    return false;
  }

  Future<int> getTeamMatchCountAPI(String tournament, String team, Timestamp date) async {
    String url = baseUrl + '/TeamGames/' + tournament + '/' + team + '/' + date.toDate().toUtc().toString();
    Map<String, String> headers = {"Content-type": "application/json"};
    Response response = await get(url, headers: headers);
    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Failed to load games');
    }
  }

  Future<List<Game>> getGamesAPI(String tournament, String player, Timestamp date) async {
    String url = baseUrl + '/Performance/' + tournament + '/' + player + '/' + date.toDate().toUtc().toString();
    Map<String, String> headers = {"Content-type": "application/json"};
    Response response = await get(url, headers: headers);
    //int statusCode = response.statusCode;
    //print("STATUS_CODE=" + statusCode.toString());
    if (response.statusCode == 200) {
      List<dynamic> games = jsonDecode(response.body);
      List<Game> gamesMapped = games.map((data) => Game.fromJson(data)).toList();
      //plantsMapped.sort((a, b) => a.match.compareTo(b.match))
      return gamesMapped;
    } else {
      throw Exception('Failed to load games');
    }
  }
}
