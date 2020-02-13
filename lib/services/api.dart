import 'package:http/http.dart';
import '../models/player.dart';
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
    int statusCode = response.statusCode;
    print("STATUS_CODE=" + statusCode.toString());
    if (response.statusCode == 200) {
      List<dynamic> players = jsonDecode(response.body);
      List<Player> playersMapped =
          players.map((data) => Player.fromJson(data)).toList();
      //plantsMapped.sort((a, b) => a.match.compareTo(b.match))
      return playersMapped;
    } else {
      throw Exception('Failed to load players');
    }
  }
}
