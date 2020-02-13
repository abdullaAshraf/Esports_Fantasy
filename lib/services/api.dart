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

  HttpService() {
    _cacheValidDuration = Duration(minutes: 30);
    _lastFetchTime = DateTime.fromMillisecondsSinceEpoch(0);
    _allRecords = [];
  }

  Future<void> refreshAllRecords() async {
    _allRecords = await getPlayersAPI(); // This makes the actual HTTP request
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

  Future<Player> getPlayer(String tag, {bool forceRefresh = false}) async {
    bool shouldRefreshFromApi = (null == _allRecords ||
        _allRecords.isEmpty ||
        null == _lastFetchTime ||
        _lastFetchTime.isBefore(DateTime.now().subtract(_cacheValidDuration)) ||
        forceRefresh);

    if (shouldRefreshFromApi) await refreshAllRecords();

    for (Player player in _allRecords) {
      if (player.tag == tag) {
        return player;
      }
    }
  }

  Future<List<Player>> getPlayersAPI() async {
    String url = baseUrl + '/Player/All';
    Map<String, String> headers = {"Content-type": "application/json"};
    Response response = await get(url, headers: headers);
    //int statusCode = response.statusCode;
    //print("STATUS_CODE=" + statusCode.toString());
    if (response.statusCode == 200) {
      List<dynamic> players = jsonDecode(response.body);
      List<Player> playersMapped =
          players.map((data) => Player.fromJson(data)).toList();
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
      if (gameCount + 1 == game.roundNumber) gameCount++;
      else{
        totalPoints += gamePoints/gameCount;
        gameCount = 1;
        gamePoints = 0;
      }

      gamePoints += 2*game.kills;
      gamePoints -= 0.5*game.deaths;
      gamePoints += 1.5*game.assists;
      gamePoints += 0.01*game.cs;

      if(game.kills + game.assists >= 10)
        gamePoints += 2;
      if(game.win)
        gamePoints += 5;
      totalPoints += gamePoints/gameCount;
    }
    return totalPoints;
  }

  Future<double> getPlayerPoints(Player player, Timestamp date) async {
    List<Game> games = await getGamesAPI(player.tournament,player.tag,date);
    double points = calculatePlayerPoints(games);
    return points;
  }

  Future<double> getPlayerSeasonPoints(Player player) async {
    var date = Timestamp.fromMillisecondsSinceEpoch(0);
    List<Game> games = await getGamesAPI(player.tournament,player.tag,date);
    double points = calculatePlayerPoints(games);
    return points;
  }


  Future<List<Game>> getGamesAPI(
      String tournament, String player, Timestamp date) async {
    String url = baseUrl +
        '/Performance/' +
        tournament +
        '/' +
        player +
        '/' +
        date.toDate().toUtc().toString();
    Map<String, String> headers = {"Content-type": "application/json"};
    Response response = await get(url, headers: headers);
    //int statusCode = response.statusCode;
    //print("STATUS_CODE=" + statusCode.toString());
    if (response.statusCode == 200) {
      List<dynamic> games = jsonDecode(response.body);
      List<Game> gamesMapped =
          games.map((data) => Game.fromJson(data)).toList();
      //plantsMapped.sort((a, b) => a.match.compareTo(b.match))
      return gamesMapped;
    } else {
      throw Exception('Failed to load games');
    }
  }
}
