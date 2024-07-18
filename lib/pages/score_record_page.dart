import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScoreRecordPage extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;
  final String matchType;
  final bool isHalfTime;
  final int matchTime;

  ScoreRecordPage({
    required this.homeTeam,
    required this.awayTeam,
    required this.matchType,
    required this.isHalfTime,
    required this.matchTime,
  });

  @override
  _ScoreRecordPageState createState() => _ScoreRecordPageState();
}

class _ScoreRecordPageState extends State<ScoreRecordPage> {
  int homeScore = 0;
  int awayScore = 0;
  List<Map<String, dynamic>> homeGoals = [];
  List<Map<String, dynamic>> awayGoals = [];
  List<String> homePlayers = [];
  List<String> awayPlayers = [];
  bool isMatchStarted = false;
  int remainingTime = 0;

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
    remainingTime = widget.matchTime;
  }

  void _fetchPlayers() async {
    try {
      final homeTeamDoc = await FirebaseFirestore.instance.collection('teams').doc(widget.homeTeam).get();
      final awayTeamDoc = await FirebaseFirestore.instance.collection('teams').doc(widget.awayTeam).get();
      setState(() {
        homePlayers = List<String>.from(homeTeamDoc.data()?['members']?.map((member) => member['name']) ?? []);
        awayPlayers = List<String>.from(awayTeamDoc.data()?['members']?.map((member) => member['name']) ?? []);
      });
      print('Home Players: $homePlayers');
      print('Away Players: $awayPlayers');
    } catch (e) {
      print('Error fetching players: $e');
    }
  }

  void _startMatch() {
    setState(() {
      isMatchStarted = true;
    });

    // Start a timer for match duration
    Future.delayed(Duration(minutes: widget.matchTime)).then((_) {
      if (mounted) {
        setState(() {
          isMatchStarted = false;
          _saveMatchResult();
        });
      }
    });
  }

  void _incrementHomeScore() async {
    final selectedPlayer = await _selectPlayer(homePlayers);
    if (selectedPlayer != null) {
      setState(() {
        homeScore++;
        homeGoals.add({'time': DateTime.now(), 'player': selectedPlayer});
      });
    }
  }

  void _incrementAwayScore() async {
    final selectedPlayer = await _selectPlayer(awayPlayers);
    if (selectedPlayer != null) {
      setState(() {
        awayScore++;
        awayGoals.add({'time': DateTime.now(), 'player': selectedPlayer});
      });
    }
  }

  Future<String?> _selectPlayer(List<String> players) async {
    String? selectedPlayer;
    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Player'),
          content: DropdownButton<String>(
            isExpanded: true,
            value: players.isNotEmpty ? players[0] : null,
            items: players.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              selectedPlayer = newValue;
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
    return selectedPlayer;
  }

  void _saveMatchResult() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('End Match'),
        content: Text('Are you sure you want to end the match and save the result?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('matches').add({
                'date': DateTime.now(),
                'homeScore': homeScore,
                'awayScore': awayScore,
                'homeGoals': homeGoals,
                'awayGoals': awayGoals,
                'matchType': widget.matchType,
                'isHalfTime': widget.isHalfTime,
              }).then((value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Match result saved successfully')),
                );
                Navigator.pop(context);
                Navigator.pop(context);
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to save match result: $error')),
                );
              });
            },
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Score Record'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('${widget.homeTeam} vs ${widget.awayTeam}', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Text('Half Time: ${widget.isHalfTime ? "Yes" : "No"}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('${widget.homeTeam}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('$homeScore', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: isMatchStarted ? _incrementHomeScore : null,
                      child: Text('得点'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                    Text(homeGoals.map((goal) => '${goal['time'].minute}:${goal['time'].second} ${goal['player']}').join(', ')),
                  ],
                ),
                Column(
                  children: [
                    Text('${widget.awayTeam}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text('$awayScore', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                    ElevatedButton(
                      onPressed: isMatchStarted ? _incrementAwayScore : null,
                      child: Text('得点'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    ),
                    Text(awayGoals.map((goal) => '${goal['time'].minute}:${goal['time'].second} ${goal['player']}').join(', ')),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            if (!isMatchStarted)
              ElevatedButton(
                onPressed: _startMatch,
                child: Text('試合開始'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              ),
            if (isMatchStarted)
              Column(
                children: [
                  Text('残り時間: $remainingTime分', style: TextStyle(fontSize: 18)),
                  ElevatedButton(
                    onPressed: _saveMatchResult,
                    child: Text('試合終了'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.lightBlue),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('ホームへ戻る'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
