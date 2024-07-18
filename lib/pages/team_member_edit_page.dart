import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';  // JSONのエンコード/デコード用に追加

class TeamMemberEditPage extends StatefulWidget {
  @override
  _TeamMemberEditPageState createState() => _TeamMemberEditPageState();
}

class _TeamMemberEditPageState extends State<TeamMemberEditPage> {
  List<String> teamNames = ['Team A', 'Team B'];
  Map<String, List<Map<String, String>>> teamMembers = {
    'Team A': List.generate(100, (index) => {'jerseyNumber': '$index', 'name': 'メンバ$index'}),
    'Team B': List.generate(100, (index) => {'jerseyNumber': '$index', 'name': 'メンバ$index'}),
  };

  @override
  void initState() {
    super.initState();
    _loadTeams();
  }

  _loadTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? storedTeams = prefs.getStringList('teamNames');
    if (storedTeams != null) {
      setState(() {
        teamNames.addAll(storedTeams);
        for (var team in storedTeams) {
          String? membersJson = prefs.getString('members_$team');
          if (membersJson != null) {
            teamMembers[team] = List<Map<String, String>>.from(json.decode(membersJson));
          }
        }
      });
    }
  }

  _saveTeams() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('teamNames', teamNames.sublist(2));
    for (var team in teamNames.sublist(2)) {
      prefs.setString('members_$team', json.encode(teamMembers[team]));
    }
  }

  _addTeam(String teamName) {
    setState(() {
      teamNames.add(teamName);
      teamMembers[teamName] = List.generate(100, (index) => {'jerseyNumber': '$index', 'name': 'メンバ$index'});
    });
    _saveTeams();
  }

  _deleteTeam(String teamName) {
    setState(() {
      teamNames.remove(teamName);
      teamMembers.remove(teamName);
    });
    _saveTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Team Member Edit Page'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: () async {
                String? teamName = await _showAddTeamDialog(context);
                if (teamName != null && teamName.isNotEmpty) {
                  _addTeam(teamName);
                }
              },
              child: Text('チーム追加'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: teamNames.length,
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Text(teamNames[index]),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (index > 1)
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // メンバ編集の処理を追加
                              },
                            ),
                          if (index > 1)
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTeam(teamNames[index]),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showAddTeamDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('チーム名を入力'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'チーム名'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_controller.text),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
