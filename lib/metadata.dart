import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetadataPage extends StatefulWidget {

  const MetadataPage({
    Key? key,

  }) : super(key: key);

  @override
  _MetadataPageState createState() => _MetadataPageState();
}

class _MetadataPageState extends State<MetadataPage> {
  List<Map<String, dynamic>> metadataList = [];
  int maxListCount = 100;
  BannerAd? _bannerAd;
  final String _adUnitId = 'ca-app-pub-8418530968906083/5921197475';

  @override
  void initState() {
    super.initState();
    _loadAdBannerMeta();
    readMetadataFromSharedPreferences();
  }

  Future<void> clearAllMetadata() async {
    try {
      // SharedPreferences nesnesini al
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // metadataList anahtarına sahip veriyi sil
      prefs.remove('metadataList');

      print('SharedPreferences içeriği temizlendi');
      setState(() {
        metadataList = [];
      });
    } catch (e) {
      print('Metadata silme hatası: $e');
    }
  }
  Future<void> checkAndClearList() async {
    if (metadataList.length > maxListCount) {
      metadataList = metadataList.sublist(0, maxListCount);

      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        // metadataList'i JSON formatına çevir
        List<String> jsonList = metadataList.map((data) => jsonEncode(data)).toList();

        // SharedPreferences'e güncellenmiş listeyi kaydet
        prefs.setStringList('metadataList', jsonList);

        print('SharedPreferences içeriği maksimum $maxListCount elemanla güncellendi');
      } catch (e) {
        print('Metadata güncelleme hatası: $e');
      }
    }
  }
  Future<void> readMetadataFromSharedPreferences() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // metadataList anahtarındaki veriyi al
      List<String>? metadataListString = prefs.getStringList('metadataList');

      if (metadataListString != null) {
        setState(() {
          metadataList = metadataListString.map((metadataString) {
            // metadataString'i parse etmeden doğrudan kullan
            List<String> parts = metadataString.split(' - ');
            // parts listesinden gerekli alanlara atama yap
            return {
              'saat': parts[0],
              'calisanRadyo': parts[2], // URL'yi aldım, ancak diğer verileri gösterimde kullanabilirsiniz
              'metadata': parts[1],
            };
          }).toList();
          metadataList = metadataList.reversed.toList();
        });
      }
    } catch (e) {
      print('Metadata okuma hatası: $e');
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.grey, //change your color here
        ),
        title: Text(
          'Listening History',
          style: GoogleFonts.getFont(
            'Barlow Condensed',
            // fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xff0c0c0c),
        actions:  [
          IconButton(
            icon: const Icon(
              Icons.delete,
              size: 26,
              color: Colors.blue,
            ),
            onPressed: () {
              clearAllMetadata();
            },
          ),
        ],
      ),
      backgroundColor: const Color(0xff0c0c0c),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: DataTable2(
                columnSpacing: 12,
                horizontalMargin: 12,
                minWidth: 600,
                columns: [
                  DataColumn2(
                    label: Text(
                      'Time',
                      style: GoogleFonts.getFont(
                        'Barlow Condensed',
                        fontSize: 18,
                        letterSpacing: 2,
                        color: Colors.white,
                      //  backgroundColor: Color(0x74F10000),
                      ),
                    ),
                    fixedWidth: 50,
                  ),
                  DataColumn2(
                    label: Text('Radio',
                      style: GoogleFonts.getFont(
                        'Barlow Condensed',
                        fontSize: 18,
                        letterSpacing: 2,
                        color: Colors.white,
                      //  backgroundColor: Color(0x74F10000),
                      ),
                    ),
                    fixedWidth: 60,
                  ),
                  DataColumn2(
                    label: Text('Songs',
                      style: GoogleFonts.getFont(
                        'Barlow Condensed',
                        fontSize: 16,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                    fixedWidth: 300,
                  ),
                ],
                rows: metadataList.map((data) {
                  return DataRow(
                    cells: [
                      DataCell(Text(data['saat'],
                        style: GoogleFonts.getFont(
                          'Barlow Condensed',
                          fontSize: 14,
                          color: Colors.white,
                        ),)),
                      DataCell(
                          Image.network(data['calisanRadyo'], width: 30, height: 30)),
                      DataCell(Text(data['metadata'],
                        style: GoogleFonts.getFont(
                          'Roboto',
                          fontSize: 14,
                          color: Colors.white,
                        ),)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          /*
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
            )
           */
        ],
      ),
    );
  }
  void _loadAdBannerMeta() async {
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
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
        // Called when an ad opens an overlay that covers the screen.
        onAdOpened: (Ad ad) {},
        // Called when an ad removes an overlay that covers the screen.
        onAdClosed: (Ad ad) {},
        // Called when an impression occurs on the ad.
        onAdImpression: (Ad ad) {},
      ),
    ).load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
