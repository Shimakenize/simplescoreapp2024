import 'package:flutter/material.dart';
import 'team_settings_page.dart';
import 'match_options_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedHomeTeam = 'Team A';
  String selectedAwayTeam = 'Team B';
  String selectedMatchType = 'Official';
  int selectedMatchTime = 45;
  String selectedHalfType = 'Full';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedHomeTeam,
              onChanged: (String? newValue) {
                setState(() {
                  selectedHomeTeam = newValue!;
                });
              },
              items: ['Team A', 'Team B']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedAwayTeam,
              onChanged: (String? newValue) {
                setState(() {
                  selectedAwayTeam = newValue!;
                });
              },
              items: ['Team A', 'Team B']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedMatchType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedMatchType = newValue!;
                });
              },
              items: ['Official', 'Training']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            DropdownButton<int>(
              value: selectedMatchTime,
              onChanged: (int? newValue) {
                setState(() {
                  selectedMatchTime = newValue!;
                });
              },
              items: List<int>.generate(45, (int index) => index + 1)
                  .map<DropdownMenuItem<int>>((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value min'),
                );
              }).toList(),
            ),
            DropdownButton<String>(
              value: selectedHalfType,
              onChanged: (String? newValue) {
                setState(() {
                  selectedHalfType = newValue!;
                });
              },
              items: ['Full', 'Half']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => TeamSettingsPage()),
                );
              },
              child: Text('チーム・メンバー設定'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle match start
              },
              child: Text('試合開始'),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle match results confirmation
              },
              child: Text('試合結果確認'),
            ),
          ],
        ),
      ),
    );
  }
}
