//player.dart
import 'dart:async';
import 'dart:convert';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:radio/switch_class.dart';
import 'package:wakelock/wakelock.dart';
import 'package:radio_player/radio_player.dart';
import 'package:radio/radio_list.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_picker_sheet/widget/sheet.dart';
import 'package:time_picker_sheet/widget/time_picker.dart';
import 'metadata.dart';
import 'package:mini_music_visualizer/mini_music_visualizer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

final databaseReference = FirebaseDatabase.instance.ref();

class PlayerPage extends StatefulWidget {
  final List<RadioStation> stations;
  final int currentIndex;
  final List<Song> songs; // Eklenen satır
  const PlayerPage(
      {Key? key,
      required this.stations,
      required this.currentIndex,
      required this.songs})
      : super(key: key);
  @override
  _PlayerPageState createState() => _PlayerPageState(metadataList: []);
}

class _PlayerPageState extends State<PlayerPage> {
  bool albumSwitchStatus = true;
  bool albumKey = true;
  bool dateKey = true;
  bool writerKey = true;
  bool videoButtonKey = false;
  bool ircButtonKey = true;
  bool timerButtonKey = true;
  bool historyButtonKey = true;


  BannerAd? _bannerAd;
  final String _adUnitId = 'ca-app-pub-8418530968906083/5921197475';
  bool _over = false;
  DateTime? dateTimeSelected;
  String? lastProcessedMetadata;
  final String jsonFilePath = 'metadata.json';
  late List<Map<String, dynamic>> metadataList;
  List songs = [];
  _PlayerPageState({
    required this.metadataList,
  });
  int _remainingSeconds = -1;
  late Timer _timer;
  String title3 = "";
  String title5 = "";
  Color snoozeButtonColor = const Color(0x8A5db2ff);

  Future<void> getAlbumSwitchStatus() async {
    albumKey = await SwitchPreferences.getSwitchValue('albumKey') ?? false;
    dateKey = await SwitchPreferences.getSwitchValue('dateKey') ?? false;
    writerKey = await SwitchPreferences.getSwitchValue('writerKey') ?? false;
    videoButtonKey =
        await SwitchPreferences.getSwitchValue('videoButtonKey') ?? false;
    historyButtonKey =
        await SwitchPreferences.getSwitchValue('historyButtonKey') ?? false;
    ircButtonKey =
        await SwitchPreferences.getSwitchValue('ircButtonKey') ?? false;
    timerButtonKey =
        await SwitchPreferences.getSwitchValue('timerButtonKey') ?? false;
    setState(() {});
  }
  Future<void> fetchData() async {
    if (currentIndex == 5){
    final response = await http.get(
      Uri.parse('https://iris-80s80s.loverad.io/flow.json?station=156&offset=1&count=1&ts=1707476654602'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      String newQuery = data['result']['entry'][0]['song']['entry'][0]['title'];

      if (newQuery != title5) {
        title5 = newQuery;
        print("songNamesongNamesongNamesongNamesongName......: $title5");
        print("widget.stations[6].imageURL......: ${widget.stations[5].imageURL}");
        saklaMetadataToSharedPreferences(title5, widget.stations[5].imageURL);
        ara(title5);
      }
    } else {
      print('Failed to load data. Status code: ${response.statusCode}');
    }}
    else{
      false;
    }
  }
  Future<void> fetchOtherData() async {
    if (currentIndex == 3) {
      final response = await http.get(
        Uri.parse(
            'https://minharadioonline.net/last/music.php?hts=hts02&porta=8062'),
      );
      if (response.statusCode == 200) {
        List<String> data = response.body.split("||");
        String targetMetadata;
        if (data.length >= 2) {
          String newQuery = data[0];
          if (newQuery != title3) {
              title3 = newQuery;
            targetMetadata = title3
                .replaceAll(RegExp(r'^[\d\s*_.\-]+_DUR_'), '')
                .replaceAll(RegExp(r'\d+'), '')
                .replaceAll(
                RegExp(r'[-,.]'), '') // -, . ve , işaretlerini kaldır
                .replaceAll(RegExp(r'\bMichael\b|\bJackson\b'),
                '') // Michael ve Jackson kelimelerini kaldır
                .trim();
            songName = targetMetadata;
            saklaMetadataToSharedPreferences(
                songName, widget.stations[3].imageURL);
            ara(songName);
          }
        } else {
          print('Invalid data format');
        }
      } else {
        print('Failed to load data. Status code: ${response.statusCode}');
      }
    }else{

    }
  }
  Future<void> saklaMetadataToSharedPreferences(
      String songName, String radioImageURL) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? previousMetadataList =
          prefs.getStringList('metadataList') ?? [];
      String formattedSaat = DateTime.now().toIso8601String().substring(11, 16);
      String newMetadata = '$formattedSaat - $songName - $radioImageURL';
      previousMetadataList.add(newMetadata);
      prefs.setStringList('metadataList', previousMetadataList);
    } catch (e) {
      print('Metadata kaydetme hatası: $e');
    }
  }
  void ara(songName) {
    List searchResults = songs
        .where(
            (song) => song.name.toLowerCase().contains(songName.toLowerCase()))
        .toList();
    if (searchResults.isNotEmpty) {
      List<String> Sonuclar = [];
      for (var result in searchResults) {
        if (result.name.toLowerCase() == songName.toLowerCase()) {
          Sonuclar = [];
          Sonuclar.add(result.name);
          Sonuclar.add(result.writer);
          Sonuclar.add(result.time);
          Sonuclar.add(result.image);
          Sonuclar.add(result.album);
          Sonuclar.add(result.date);
          Sonuclar.add(result.era);
          Sonuclar.add(result.lrc);
          Sonuclar.add(result.video);
          Sonuclar.add(result.cover);
           //print("SonuclarSonuclarSonuclarSonuclar.......: $Sonuclar");
        }
      }
      isLocalImage = false;
      updateSearchResults(Sonuclar);
    } else {
      List<String> Sonuclar = [songName,"","","assets/none.jpg","","","","","","",""];
      isLocalImage = true;
      updateSearchResults(Sonuclar);
       //print("Arama sonuç bulunamadı.................: $query");
    }
  }

// Bu fonksiyon metadata'yı bir dosyaya kaydetmek için eklenir
  Future<void> saveMetadataToSharedPreferences(
      String metadata, String radioImageURL) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? previousMetadataList =
          prefs.getStringList('metadataList') ?? [];
      String formattedSaat = DateTime.now().toIso8601String().substring(11, 16);
      String newMetadata = '$formattedSaat - $metadata - $radioImageURL';
      previousMetadataList.add(newMetadata);
      prefs.setStringList('metadataList', previousMetadataList);
    } catch (e) {
          print('Metadata kaydetme hatası: $e');
    }
  }

  late RadioPlayer radioPlayer;
  bool isPlaying = false;
  int currentIndex = 0;
  List<String>? metadata;
  String songName = "";
  String backgroundImage = "assets/opening.jpg";
  List<String> Sonuclar = [];
  String parca = "";
  String yazar = "";
  String sure = "";
  String album = "";
  String tarih = "";
  String donem = "";
  String lrc = "";
  String video = "";
  String cover = "";
  late PageController _pageController;
  bool isLocalImage = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    getAlbumSwitchStatus();
    Wakelock.enable();
    _loadAdBanner();
    songs = widget.songs;
    metadataList = [];
    currentIndex = widget.currentIndex;
    radioPlayer = RadioPlayer();
    radioPlayer.setChannel(
      title: widget.stations[currentIndex].name,
      url: widget.stations[currentIndex].streamURL,
      imagePath: widget.stations[currentIndex].imageURL,
    );
    _pageController = PageController(initialPage: widget.currentIndex);
    radioPlayer.stateStream.listen((value) {
      setState(() {
        isPlaying = value;
          if (currentIndex == 5) {
            Timer.periodic(const Duration(seconds: 5), (Timer timer) {
            fetchData();
            });
          }else if(currentIndex == 3){
            Timer.periodic(const Duration(seconds: 5), (Timer timer) {
              fetchOtherData();
            });
          }
      });
    });

    void searchSong(String query, _PlayerPageState pageState) {
      List searchResults = songs
          .where(
              (song) => song.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      if (searchResults.isNotEmpty) {
        List<String> Sonuclar = [];
        for (var result in searchResults) {
          if (result.name.toLowerCase() == query.toLowerCase()) {
            Sonuclar = [];
            Sonuclar.add(result.name);
            Sonuclar.add(result.writer);
            Sonuclar.add(result.time);
            Sonuclar.add(result.image);
            Sonuclar.add(result.album);
            Sonuclar.add(result.date);
            Sonuclar.add(result.era);
            Sonuclar.add(result.lrc);
            Sonuclar.add(result.video);
            Sonuclar.add(result.cover);
            // print(result.lrc);
          }
        }
        isLocalImage = false;
        pageState.updateSearchResults(Sonuclar);
      } else {
          List<String> Sonuclar = [query,"","","assets/none.jpg","","","","","","",""];
        isLocalImage = true;
        pageState.updateSearchResults(Sonuclar);
        // print("Arama sonuç bulunamadı.................: $query");
      }
    }

    // Metadata dinleyicisi
    radioPlayer.metadataStream.listen((value) {
      setState(() {
        metadata = value;
        if (metadata != null &&
            metadata!.isNotEmpty &&
            metadata?.join().substring(0, 20) !=
                lastProcessedMetadata?.substring(0, 20)) {
          lastProcessedMetadata = metadata!.join();

          if (widget.stations[currentIndex].number == "1") {
            String targetMetadata = metadata![0];
            if (metadata![1] != null &&
                (metadata![1].trim().isNotEmpty) &&
                !metadata![1].contains("Compilations") &&
                !metadata![1].contains("Jackson")) {
              targetMetadata = metadata![1];
            }
            songName = targetMetadata.trim();
            saveMetadataToSharedPreferences(
                songName, widget.stations[currentIndex].imageURL);
            searchSong(songName, this);

          } else if (widget.stations[currentIndex].number == "2") {
            String targetMetadata = metadata![0];
            if (metadata![1] != null &&
                (metadata![1].trim().isNotEmpty) &&
                !metadata![1].contains("Compilations") &&
                !metadata![1].contains("Jackson")) {
              targetMetadata = metadata![1];
            }
            songName = targetMetadata.trim();
            saveMetadataToSharedPreferences(
                songName, widget.stations[currentIndex].imageURL);
            searchSong(songName, this);

          } else if (widget.stations[currentIndex].number == "3") {
            List<String> parsedData = metadata![0].split("~");
            if (parsedData.length >= 3) {
              songName = parsedData[0].trim();
              saveMetadataToSharedPreferences(
                  songName, widget.stations[currentIndex].imageURL);

              searchSong(songName, this);
            }
          }/*
          else if (widget.stations[currentIndex].number == "4"){
            print("metadatametadatametadatametadatametadata $metadata");
            String targetMetadata = metadata![1];
            if (metadata![0] != null &&
                metadata![0].isNotEmpty &&
                !metadata![0].contains("Michael")&&
                !metadata![0].contains("Compilations")&&
                !metadata![0].contains("Jackson")) {
              targetMetadata = metadata![0];
            }
            targetMetadata = targetMetadata
                .replaceAll(RegExp(r'^[\d\s*_.\-]+_DUR_'), '')
                .replaceAll(RegExp(r'\d+'), '')
                .trim();
            songName = targetMetadata;
            saveMetadataToSharedPreferences(songName, widget.stations[currentIndex].imageURL);
            searchSong(songName, this);
          }*/
          else if (widget.stations[currentIndex].number == "5") {
            String targetMetadata = metadata![1];
            if (metadata![0] != null &&
                (metadata![0].trim().isNotEmpty) &&
                !metadata![0].contains("Compilations") &&
                !metadata![0].contains("Jackson")) {
              targetMetadata = metadata![0];
            }
            songName = targetMetadata.trim();
            saveMetadataToSharedPreferences(
                songName, widget.stations[currentIndex].imageURL);
            searchSong(songName, this);
          } else if (widget.stations[currentIndex].number == "6") {
            fetchData();
          } else if (widget.stations[currentIndex].number == "7") {
          } else {
            songName = "";
          }
        }
      });
    });
  }

  void selectPreviousStation() {
    setState(() {
      if (currentIndex > 0) {
        currentIndex--;
      } else {
        currentIndex = widget.stations.length - 1;
      }
      updateRadioPlayer();
    });
  }

  // Sonraki istasyonu seçen fonksiyon
  void selectNextStation() {
    setState(() {
      if (currentIndex < widget.stations.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      updateRadioPlayer();
    });
  }

  // RadioPlayer'ı güncelleyen yardımcı fonksiyon
  void updateRadioPlayer() {
    radioPlayer.setChannel(
      title: widget.stations[currentIndex].name,
      url: widget.stations[currentIndex].streamURL,
      imagePath: widget.stations[currentIndex].imageURL,
    );

  }

  void clearMetaData() {
    isLocalImage = true;
    parca = "";
    yazar = "";
    sure = "";
    album = "";
    tarih = "";
    donem = "";
    lrc = "";
    video = "";
    cover = "";
    backgroundImage = "assets/opening.jpg";
    radioPlayer.pause();
    setState(() {
      Timer(const Duration(seconds: 1), () {
        radioPlayer.play();
      });
    });
  }

  void updateSearchResults(List<String> searchResults) {
    setState(() {
      Sonuclar = searchResults;
      backgroundImage = Sonuclar[3];
      parca = Sonuclar[0];
      yazar = Sonuclar[1];
      sure = Sonuclar[2];
      album = Sonuclar[4];
      tarih = Sonuclar[5];
      donem = Sonuclar[6];
      lrc = Sonuclar[7];
      video = Sonuclar[8];
      cover = Sonuclar[9];
      _over = false;
      //'https://paxsenixofc.my.id/server/getLyricsMusix.php?q=${parca} michaeljackson&type=default'))
    });
    Timer(const Duration(seconds: 1), () {
      setState(() {
        _over = true;
        _scrollController.animateTo(
          0.0, // Sayfanın en üstüne kaydırmak için 0.0 kullanılır.
          duration: Duration(milliseconds: 500), // Kaydırma süresi
          curve: Curves.easeInOut, // Kaydırma animasyonu eğrisi
        );
      });
    });
  }

  Future<void> _showTimerDialog() async {
    final result = await TimePicker.show(
      context: context,
      sheet: TimePickerSheet(
        sheetTitle: 'Set Timer',
        hourTitle: 'Hour',
        minuteTitle: 'Minute',
        saveButtonText: 'Set',
        minMinute: 1,
        maxMinute: 60,
        saveButtonColor: const Color(0xff0c0c0c),
        hourTitleStyle: const TextStyle(color: Colors.grey),
        minuteTitleStyle: const TextStyle(color: Colors.grey),
        sheetTitleStyle: const TextStyle(
            color: Colors.grey, backgroundColor: Color(0xff0c0c0c)),
        wheelNumberItemStyle: const TextStyle(color: Colors.grey, fontSize: 17),
        wheelNumberSelectedStyle: const TextStyle(
          color: Colors.red,
          fontSize: 20,
        ),
      ),
    );
    if (result != null) {
      setState(() {
        dateTimeSelected = result;
        _startTimer();
      });
    }
  }

  // Timer'ı başlatan fonksiyon
  void _startTimer() {
    if (dateTimeSelected != null) {
      _remainingSeconds =
          dateTimeSelected!.hour * 3600 + dateTimeSelected!.minute * 60;
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else if (_remainingSeconds == 0) {
          radioPlayer.pause();
          _remainingSeconds = -1;
          _timer.cancel();
          _over = false;
        } else {
          false;
        }
      });
    }
  }

  ImageProvider _getBackgroundImage() {
    if (isLocalImage) {
      return AssetImage(backgroundImage);
    } else {
      return NetworkImage(backgroundImage);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  final _advancedDrawerController = AdvancedDrawerController();
  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }

  @override
  Widget build(BuildContext context) {
    var mediaQueryData = MediaQuery.of(context);
    var screenWidth = mediaQueryData.size.width;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        radioPlayer.pause();
      },
      child: AdvancedDrawer(
        backdrop: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xff0c0c0c),
                const Color(0xff0c0c0c).withOpacity(0.2)
              ],
            ),
          ),
        ),
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        // openScale: 1.0,
        openRatio: 0.55,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        drawer: Drawer(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xff0c0c0c),
              image: DecorationImage(
                image: AssetImage('assets/settingmj.png'),
                fit: BoxFit.fitHeight,
              ),
            ),
            child: ListView(
              children: [
                const DrawerHeader(
                    child: Center(
                        child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50.0,
                      backgroundImage: AssetImage('assets/splash.png'),
                      backgroundColor: Color(0x880c0c0c),
                    ),
                    Text(
                      "SETTING",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ))),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Lyrics",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: ircButtonKey,
                        onChanged: (value) async {
                          setState(() {
                            ircButtonKey = value;
                          });
                          await SwitchPreferences.setSwitchValue(
                              'ircButtonKey', value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  endIndent: 5,
                  indent: 5,
                  //thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Album",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: albumKey,
                        onChanged: (value) async {
                          setState(() {
                            albumKey = value;
                          });
                          await SwitchPreferences.setSwitchValue(
                              'albumKey', value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  endIndent: 5,
                  indent: 5,
                  //thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Date",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: dateKey,
                        onChanged: (value) async {
                          setState(() {
                            dateKey = value;
                          });
                          await SwitchPreferences.setSwitchValue(
                              'dateKey', value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  endIndent: 5,
                  indent: 5,
                  //thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Writer",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: writerKey,
                        onChanged: (value) async {
                          setState(() {
                            writerKey = value;
                          });
                          await SwitchPreferences.setSwitchValue(
                              'writerKey', value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  endIndent: 5,
                  indent: 5,
                  //thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "History List Button",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: historyButtonKey,
                        onChanged: (value) async {
                          setState(() {
                            historyButtonKey = value;
                          });
                          await SwitchPreferences.setSwitchValue(
                              'historyButtonKey', value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  endIndent: 5,
                  indent: 5,
                  //thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Timer Button",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: timerButtonKey,
                        onChanged: (value) async {
                          setState(() {
                            timerButtonKey = value;
                          });
                          await SwitchPreferences.setSwitchValue(
                              'timerButtonKey', value);
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 4,
                  endIndent: 5,
                  indent: 5,
                  //thickness: 1,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 0.0, 8.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Video Button",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      Switch(
                        trackColor: MaterialStateProperty.all(Colors.black38),
                        activeColor: Colors.black,
                        activeTrackColor: Colors.black,
                        inactiveThumbColor: Colors.black,
                        inactiveTrackColor: Colors.black,
                        activeThumbImage: const AssetImage('assets/mjjon.png'),
                        inactiveThumbImage:
                            const AssetImage('assets/mjjoff.png'),
                        value: videoButtonKey,
                        onChanged: null,
                        /*
                        onChanged: (value) async{
                          setState(() {
                            videoButtonKey = value;
                          });
                          await SwitchPreferences.setSwitchValue('videoButtonKey', value);
                        },
                        */
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
                TextButton(
                  onPressed: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Column(
                              children: [
                                Text(
                                  'Your feedback is valuable to us. We look forward to your questions!\n And don\'t forget to check for updates !',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                                Text('belove1564@gmail.com',style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 16),
                      ),
                                SizedBox(height: 55),
                                Text('Special Thanks :',style: TextStyle(
                                    color: Colors.black, fontSize: 15),
                                ),
                                Divider(
                                  height: 2,
                                  indent: 20,
                                  endIndent: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text('Captain EO',style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    ),
                                    Text('And',style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    ),
                                    Text('Dr.Minnie',style: TextStyle(
                                        color: Colors.black, fontSize: 15),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 25),
                              ],
                            ),
                            Container(
                              height: 40,
                              width: 40,
                              decoration: const BoxDecoration(
                                color: Color(0x8A7A7A7A),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.close,
                                  size: 25,
                                  color: Colors.black,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: _getBackgroundImage(),
                fit: BoxFit.fill,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              //  mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const SizedBox(
                      width: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 15.0, 0.0),
                      child: Image.network(
                        widget.stations[currentIndex].imageURL,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),

                Container(
                  decoration: const BoxDecoration(
                    color: Color(0x7E000000),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: _handleMenuButtonPressed,
                          icon: ValueListenableBuilder<AdvancedDrawerValue>(
                            valueListenable: _advancedDrawerController,
                            builder: (_, value, __) {
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 450),
                                child: Icon(
                                  value.visible ? Icons.clear : Icons.menu,
                                  key: ValueKey<bool>(value.visible),
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        // parca
                        Container(
                          width: screenWidth-70,
                          alignment: Alignment.center,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: AutoSizeText(
                              parca,
                              style: GoogleFonts.getFont(
                                'Barlow Condensed',
                                fontSize: 20,
                                letterSpacing: 1,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            )
                                .animate(target: _over ? 1 : 0)
                                .fadeIn()
                                .scale() // uses `Animate.defaultDuration`
                                .slideY(duration: 600.ms),
                          ),
                        ),
                        SizedBox(
                          width: 18,
                          height: 15,
                          child: (isPlaying)
                              ? const MiniMusicVisualizer(
                                  color: Colors.blueAccent,
                                  width: 4,
                                  height: 15,
                                )
                              : const Text(""),
                        ),
                      ]),
                ),
                // const Spacer(),
                Expanded(
                  child: Container(
                    //  Sağ sola kaydırma işlevi
                    decoration: const BoxDecoration(
                        // color: Color(0x74000000),
                        ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: widget.stations.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                          updateRadioPlayer();
                          clearMetaData();
                        });
                      },
                      itemBuilder: (context, index) {
                        return Center(
                          child: Visibility(
                            visible: ircButtonKey && lrc != null && lrc.isNotEmpty,
                            child: SingleChildScrollView(
                              controller: _scrollController,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: screenWidth - 20,
                                  decoration: const BoxDecoration(
                                    color: Color(0xA3000000),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      (lrc != null && lrc.isNotEmpty)
                                          ? lrc
                                          : "", //  widget.stations[index].name,
                                      style: GoogleFonts.getFont(
                                        'Barlow Condensed',
                                        // fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        letterSpacing: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    decoration: const BoxDecoration(
                        //  color: Color(0x74000000),
                        ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Color(0x8A000000),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.skip_previous,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              selectPreviousStation();
                              clearMetaData();
                            },
                          ),
                        ),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(
                            color: Color(0x8A000000),
                            shape: BoxShape.circle,
                          ),
                          // padding: const EdgeInsets.only(bottom: 16, left: 12, right: 12, top: 10),
                          child: IconButton(
                            onPressed: () {
                              if (isPlaying) {
                                radioPlayer.pause();
                              } else {
                                radioPlayer.play();
                              }
                            },
                            icon: Icon(
                              isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow_rounded,
                              size: 42,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          height: 60,
                          width: 60,
                          decoration: const BoxDecoration(
                            color: Color(0x8A000000),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              size: 40,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              selectNextStation();
                              clearMetaData();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Visibility(
                  visible: !(historyButtonKey == false && timerButtonKey == false && videoButtonKey == false),
                  child: Row(   //historyButtonKey timerButtonKey videoButtonKey
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: historyButtonKey,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: const BoxDecoration(
                              color: Color(0x8A000000),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.format_list_bulleted,
                                size: 25,
                                color: Color(0x8A5db2ff),
                              ),
                              onPressed: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const MetadataPage()));
                              },
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: timerButtonKey,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: const BoxDecoration(
                              color: Color(0x8A000000),
                              shape: BoxShape.circle,
                            ),
                            child: InkWell(
                              onTap: () {
                                if (_remainingSeconds == -1 ||
                                    _remainingSeconds == 0) {
                                  setState(() {
                                    _showTimerDialog();
                                  });
                                } else {
                                  setState(() {
                                    _remainingSeconds = -1;
                                  });
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.snooze,
                                  size: 25,
                                  color: (_remainingSeconds == -1 ||
                                          _remainingSeconds == 0)
                                      ? const Color(0x8A5db2ff)
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      (_remainingSeconds != -1)
                          ? SizedBox(
                              width: 60,
                              child: Text('$_remainingSeconds sn',
                                  style: const TextStyle(
                                    color: Colors.white,
                                  )),
                            )
                          : const SizedBox(width: 30, child: Text('    ')),

                      // const SizedBox(width: 20,),
                      Visibility(
                        visible: videoButtonKey,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 0.0),
                          child: Container(
                            height: 42,
                            width: 42,
                            decoration: const BoxDecoration(
                              color: Color(0x8A000000),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.movie,
                                size: 25,
                                color: Color(0x8A5db2ff),
                              ),
                              onPressed: () {
                                /*
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => const Video()));
                                */
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Visibility(
                      visible: !(albumKey == false && dateKey == false),
                      child: Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(3, 3, 3, 0.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0x7E000000),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 2.0, 8.0, 2.0),
                                child: Visibility(
                                  visible: albumKey,
                                  child: Text(
                                    album,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.getFont(
                                      'Barlow Condensed',
                                      // backgroundColor: Color(0x7E000000),
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  )
                                      .animate(target: _over ? 1 : 0)
                                      .fadeIn() // uses `Animate.defaultDuration`
                                      .scale() // inherits duration from fadeIn
                                      .slideX(duration: 600.ms),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    8.0, 2.0, 8.0, 2.0),
                                child: Visibility(
                                  visible: dateKey,
                                  child: Text(
                                    tarih,
                                    textAlign: TextAlign.left,
                                    style: GoogleFonts.getFont(
                                      'Barlow Condensed',
                                      // backgroundColor: Color(0x7E000000),
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  )
                                      .animate(target: _over ? 1 : 0)
                                      .fadeIn() // uses `Animate.defaultDuration`
                                      .scale() // inherits duration from fadeIn
                                      .slideX(duration: 600.ms),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Visibility(
                      visible: writerKey,
                      child: Container(
                        width: screenWidth - 5,
                        decoration: const BoxDecoration(
                          color: Color(0x7E000000),
                        ),
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(8.0, 2.0, 8.0, 0.0),
                          child: Text(
                            yazar,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.getFont(
                              'Barlow Condensed',
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )
                              .animate(target: _over ? 1 : 0)
                              .fadeIn() // uses `Animate.defaultDuration`
                              .scale() // inherits duration from fadeIn
                              .slideY(duration: 600.ms),
                        ),
                      ),
                    ),

                    if (_bannerAd != null)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: SafeArea(
                          child: SizedBox(
                            width: _bannerAd!.size.width.toDouble(),
                            height: _bannerAd!.size.height.toDouble(),
                            child: AdWidget(ad: _bannerAd!),
                          ),
                        ),
                      ),

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _loadAdBanner() async {
    BannerAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      size: AdSize.fullBanner,
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          setState(() {
            _bannerAd = ad as BannerAd;
          });
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        onAdOpened: (Ad ad) {},
        onAdClosed: (Ad ad) {},
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }
}

class SongList {
  static List<Song> songs = [];
  static Song createSongFromFirebase(Map<dynamic, dynamic> data) {
    return Song(
      name: data['name'],
      cover: data['cover'],
      writer: data['writer'],
      time: data['time'],
      lrc: data['lrc'],
      video: data['video'],
      image: data['image'],
      album: data['album'],
      date: data['date'],
      era: data['era'],
    );
  }
}
