import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../data.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  StatisticsPageState createState() => StatisticsPageState();
}

class StatisticsPageState extends State<StatisticsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final rdm = Random();

  int _dotIndex = 0;
  late Timer timer;

  bool rebuild = false;
  bool _isLoading = true;
  var unsignedInt = 0;
  var signedInt = 0;
  var dicomStatsData = [];

  @override
  void initState() {
    timer = Timer.periodic(const Duration(seconds: 500), (_) {
      setState(() {
        rebuild = false;
        _dotIndex = (_dotIndex + 1) % 3;
      });
    });

    Future<void> _fetchData() async {
      try {
        print("Trying to fetch data");
        final response = await http.get(
          Uri.parse(
              'http://127.0.0.1:8001/stats'), // Replace with your API endpoint
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
        print(response.statusCode);
        if (response.statusCode == 200) {
          final Map<dynamic, dynamic> responseData = json.decode(response.body);
          print(responseData);
          print(responseData.runtimeType);
          // final List<Map<String, Object>> dicomStatsData = json.decode(response.body)['modalities_count'] as List<Map<String, Object>>;
          // print(responseData["modalities_count"].runtimeType);
          // // dicomStatsData = responseData["modalities_count"];
          // print(dicomStatsData);
          print(responseData["pixel_types"]);
          print(responseData["pixel_types"]["0"]);

          // Parse the responseData here

          setState(() {
            _isLoading = false; // Hide the loading indicator
            unsignedInt = responseData["pixel_types"]["0"];
            signedInt = responseData["pixel_types"]["1"];

            // dicomStatsData;
          });
        } else {
          // Show error message
          final String errorMessage =
              response.reasonPhrase ?? 'Failed to fetch data';
          print(
              'Failed to fetch data. Status: ${response.statusCode} - $errorMessage');
          setState(() {
            _isLoading = false; // Hide the loading indicator
          });
        }
      } catch (e) {
        // Show error message
        print("Server error: $e");
        setState(() {
          _isLoading = false; // Hide the loading indicator
        });
        // print('Failed to fetch data. Status: ${response.statusCode} - $errorMessage');
      }
    }

    _fetchData();

    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Statistics'),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() {
          rebuild = true;
        }),
        child: Icon(Icons.refresh),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _isLoading
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height / 3),
                    LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.black,
                      size: MediaQuery.of(context).size.width / 8,
                    ),
                  ],
                )
              : Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                      child: const Text(
                        'Number of Modalities',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 350,
                      height: 300,
                      child: Chart(
                        data: roseData,
                        variables: {
                          'name': Variable(
                            accessor: (Map map) => map['name'] as String,
                          ),
                          'value': Variable(
                            accessor: (Map map) => map['value'] as num,
                          ),
                        },
                        marks: [
                          IntervalMark(
                            label: LabelEncode(
                                encoder: (tuple) =>
                                    Label(tuple['value'].toString())),
                            elevation: ElevationEncode(value: 1, updaters: {
                              'tap': {true: (_) => 5}
                            }),
                            color: ColorEncode(
                                value: Defaults.primaryColor,
                                updaters: {
                                  'tap': {
                                    false: (color) => color.withAlpha(100)
                                  }
                                }),
                          )
                        ],
                        axes: [
                          Defaults.horizontalAxis,
                          Defaults.verticalAxis,
                        ],
                        selections: {'tap': PointSelection(dim: Dim.x)},
                        tooltip: TooltipGuide(),
                        crosshair: CrosshairGuide(),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height / 17),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 10),
                      child: const Text(
                        'Types of Integers',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThresholdCard(
                            backgroundColor: Colors.grey.shade700,
                            textColor: Colors.white,
                            label: 'Unsigned Integer',
                            count: unsignedInt.toString(),
                            fontFamily: GoogleFonts.lato),
                        SizedBox(width: MediaQuery.of(context).size.width/17),
                        ThresholdCard(
                            backgroundColor: Colors.green.shade400,
                            textColor: Colors.black,
                            label: 'Signed Integer',
                            count: signedInt.toString(),
                            fontFamily: GoogleFonts.lato),
                      ],
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class ThresholdCard extends StatelessWidget {
  final Color backgroundColor;
  final Color textColor;
  final String label;
  final String count;
  final TextStyle Function(
      {Color? color, double? fontSize, FontWeight? fontWeight}) fontFamily;

  ThresholdCard({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.count,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width / 2.42,
      height: MediaQuery.of(context).size.height / 5,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: fontFamily(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Spacer(),
          Text(
            count,
            style: fontFamily(
              color: textColor,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
