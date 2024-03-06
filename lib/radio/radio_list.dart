//radio_list.dart
//import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:radio/radio/settings_screen.dart';
import 'metadata.dart';
import 'player.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadioList extends StatefulWidget {
  const RadioList({Key? key}) : super(key: key);
  @override
  _RadioListState createState() => _RadioListState();
}

class _RadioListState extends State<RadioList> {
  bool showEmptyListWarning = false;
  SharedPreferences? prefs;
  List<RadioStation> stations = [];
  List<Song> songs = [];

  @override
  void initState() {
    super.initState();
    initSharedPreferences();
    loadFavoriteStations();
    loadDataFromFirebase();
  }

  Future<void> initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  void saveFavoriteStations() {
    if (prefs != null) {
      final List<String> favoriteStationsList = stations
          .where((station) => station.isFavorite)
          .map((station) => station.number)
          .toList();
      prefs!.setStringList('favoriteStations', favoriteStationsList);
    }
  }

  void loadFavoriteStations() {
      if (prefs != null) {
        final List<String>? favoriteStationsList =
        prefs!.getStringList('favoriteStations');

        if (favoriteStationsList != null && favoriteStationsList.isNotEmpty) {
          for (String stationNumber in favoriteStationsList) {
            final int index =
            stations.indexWhere((station) => station.number == stationNumber);
            if (index != -1 && index < stations.length) {
              setState(() {
                stations[index].isFavorite = true;
              });
            }
          }
// Favori istasyonlar listesi boş değilse uyarıyı kapat
          setState(() {
            showEmptyListWarning = false;
          });
        } else {
// Favori istasyonlar listesi boşsa uyarıyı göster
          setState(() {
            showEmptyListWarning = true;
          });
        }
      }


  }

  Widget buildEmptyListWarning() {
    return showEmptyListWarning
        ? Container(
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.yellow,
      ),
      child: const Text(
        'Like ❤ the Radio(s) you want to listen to',
        style: TextStyle(color: Colors.black),
      ),
    )
        : SizedBox.shrink(); // Uyarıyı göstermeme durumu
  }

  Future<void> loadDataFromFirebase() async {
    try {
      await initSharedPreferences();
      DatabaseReference stationsReference =
      FirebaseDatabase.instance.ref().child('stations');
      DataSnapshot stationsSnapshot = (await stationsReference.once()).snapshot;
      if (stationsSnapshot.value != null) {
        Map<dynamic, dynamic> stationsData =
        stationsSnapshot.value as Map<dynamic, dynamic>;
        List<RadioStation> unsortedStations = stationsData.values
            .map((data) => createRadioStationFromFirebase(data))
            .toList();
        for (RadioStation station in unsortedStations) {
          int index = stations.indexWhere(
                  (existingStation) => existingStation.number == station.number);
          if (index != -1 && index < stations.length) {
            station.isFavorite = stations[index].isFavorite;
          } else {
            station.isFavorite = false;
          }
        }
        unsortedStations.sort((a, b) {
          return a.number.compareTo(b.number);
        });
        setState(() {
          stations = unsortedStations;
        });
        DatabaseReference songsReference =
        FirebaseDatabase.instance.ref().child('song');
        DataSnapshot songsSnapshot = (await songsReference.once()).snapshot;

        if (songsSnapshot.value != null) {
          List<dynamic> songsData = songsSnapshot.value as List<dynamic>;
          songs =
              songsData.map((data) => createSongFromFirebase(data)).toList();
        }
        loadFavoriteStations();
      }
      printSharedPreferencesContent();
    } catch (e) {
      print('Error loading data from Firebase: $e');
    }
  }

  void printSharedPreferencesContent() {
    if (prefs != null) {
      final List<String>? favoriteStationsList =
      prefs!.getStringList('favoriteStations');
    }
  }

  static Song createSongFromFirebase(Map<dynamic, dynamic> data) {
    return Song(
      name: data['name'],
      writer: data['writer'],
      time: data['time'],
      video: data['video'],
      cover: data['cover'],
      lrc: data['lrc'],
      image: data['image'],
      album: data['album'],
      date: data['date'],
      era: data['era'],
    );
  }

  RadioStation createRadioStationFromFirebase(Map<dynamic, dynamic> data) {
    return RadioStation(
      number: data['number'],
      name: data['name'],
      streamURL: data['streamURL'],
      imageURL: data['imageURL'],
      desc: data['desc'],
      location: data['location'],
      listener: data['listener'],
      isPlay: data['isPlay'],
      longDesc: data['longDesc'],
    );
  }

  @override
  Widget build(BuildContext context) {
    return
    Scaffold(
      appBar: AppBar(
        title: const Text(
          'Radio List',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.bug_report_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              ConsentInformation.instance.reset();
            }
          ),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: ()=> Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen(),
              ),
            ),
          ),
        ],

        backgroundColor: const Color(0xff0c0c0c),
      ),
      backgroundColor: const Color(0xff0c0c0c),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0x8A000000),
          image: DecorationImage(
            image: AssetImage('assets/list_bg.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: stations.length,
                itemBuilder: (context, index) {
                  return Column(children: [
                    const SizedBox(height: 5),
                    Card(
                      color: Colors.grey[200],
                      child: ListTile(
                        leading: SizedBox(
                          width: 50,
                          child: Image.network(
                            stations[index].imageURL,
                            width: 50,
                            height: 50,
                          ),
                        ),
                        title: Text(
                          stations[index].name,
                          style: const TextStyle(
                              fontSize: 15, color: Colors.white),
                        ),
                        tileColor: index % 2 == 0
                            ? const Color(0xff000000)
                            : const Color(0xff070808),
                        subtitle: Text(
                          stations[index].desc,
                          style:
                          const TextStyle(fontSize: 9, color: Colors.white),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            stations[index].isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border_outlined,
                            size: 30,
                            color: stations[index].isFavorite
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () {
                            setState(() {
                              stations[index].isFavorite = !stations[index].isFavorite;
                              saveFavoriteStations();
                              loadFavoriteStations();
                            });
                          },
                        ),
                        onTap: () {
                          if (stations[index].isFavorite) {
                            int currentIndex = stations
                                .where((station) => station.isFavorite)
                                .toList()
                                .indexWhere((station) =>
                            station.number == stations[index].number);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayerPage(
                                  stations: stations
                                      .where((station) => station.isFavorite)
                                      .toList(),
                                  songs: songs,
                                  currentIndex: currentIndex,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 5),
                  ]);
                },
              ),
            ),
            buildEmptyListWarning(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
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
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class Song {
  final String name;
  final String writer;
  final String time;
  final String cover;
  final String video;
  final String lrc;
  final String image;
  final String album;
  final String date;
  final String era;
  Song({
    required this.name,
    required this.writer,
    required this.time,
    required this.cover,
    required this.video,
    required this.lrc,
    required this.image,
    required this.album,
    required this.date,
    required this.era,
  });
  @override
  String toString() {
    return 'Song{name: $name, writer: $writer, time: $time, cover: $cover, video: $video, lrc: $lrc, image: $image, album: $album, date: $date, era: $era}';
  }
}

class RadioStation {
  final String number;
  final String name;
  final String streamURL;
  final String imageURL;
  final String desc;
  final String location;
  final String listener;
  final bool isPlay;
  final String longDesc;
  bool isFavorite;

  RadioStation({
    required this.number,
    required this.name,
    required this.streamURL,
    required this.imageURL,
    required this.desc,
    required this.location,
    required this.listener,
    required this.isPlay,
    required this.longDesc,
    this.isFavorite = true,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      number: json['number'],
      name: json['name'],
      streamURL: json['streamURL'],
      imageURL: json['imageURL'],
      desc: json['desc'],
      location: json['location'],
      listener: json['listener'],
      isPlay: json['isPlay'],
      longDesc: json['longDesc'],
    );
  }
}

