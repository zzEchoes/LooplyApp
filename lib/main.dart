import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(LooplyApp());
}

class LooplyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: HabitHome());
  }
}

class HabitHome extends StatefulWidget {
  @override
  _HabitHomeState createState() => _HabitHomeState();
}

class _HabitHomeState extends State<HabitHome> {
  List<_Habit> habits = [];
  late BannerAd _bannerAd;
  InterstitialAd? _interstitialAd;
  int _toggleCount = 0;

  @override
  void initState() {
    super.initState();
    // Load banner ad
    _bannerAd = BannerAd(
      adUnitId: Config.adMobBannerUnitId,
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(),
    )..load();
    // Load interstitial ad
    _loadInterstitial();
  }

  void _loadInterstitial() {
    InterstitialAd.load(
      adUnitId: Config.adMobInterstitialUnitId,
      request: AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (error) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialIfNeeded() {
    _toggleCount++;
    if (_toggleCount % 3 == 0 && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitial();
    }
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Looply')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: habits.map((h) => _buildHabitTile(h)).toList(),
            ),
          ),
          Container(
            width: _bannerAd.size.width.toDouble(),
            height: _bannerAd.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _showAddDialog(),
      ),
    );
  }

  Widget _buildHabitTile(_Habit habit) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: habit.done ? Colors.green[100] : Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        title: Text(habit.name),
        trailing: Checkbox(
          value: habit.done,
          onChanged: (v) {
            setState(() {
              habit.done = v!;
            });
            _showInterstitialIfNeeded();
          },
        ),
      ),
    );
  }

  void _showAddDialog() {
    String name = '';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Habit'),
        content: TextField(onChanged: (v) => name = v),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => habits.add(_Habit(name)));
              Navigator.pop(context);
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _Habit {
  String name;
  bool done = false;
  _Habit(this.name);
}
