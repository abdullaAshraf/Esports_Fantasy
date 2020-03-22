import 'package:cloud_firestore/cloud_firestore.dart';

class PlayerAttachment {
  Timestamp assigned;
  double points;
  int games;

  PlayerAttachment.empty()
      : points = 0,
        games = 0;

  PlayerAttachment(Timestamp assigned, double points, int games)
      : assigned = assigned,
        points = points,
        games = games;

  double get ptsPerGame {
    return points / (games == 0 ? 1 : games);
  }
}
