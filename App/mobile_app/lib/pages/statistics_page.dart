import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:graphic/graphic.dart';
import 'package:single_value_charts/single_value_charts.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../data.dart';

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

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
          final Map<dynamic, dynamic> responseData = jsonDecode(response.body);
          print(responseData);
          print(responseData.runtimeType);
          // final List<Map<String, Object>> dicomStatsData = json.decode(response.body)['modalities_count'] as List<Map<String, Object>>;
          // print(responseData["modalities_count"].runtimeType);
          // // dicomStatsData = responseData["modalities_count"];
          // print(dicomStatsData);

          // Parse the responseData here

          setState(() {
            _isLoading = false; // Hide the loading indicator
            dicomStatsData;
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
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThresholdCard(
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          label: 'Threshold background off',
                          percentage: '20.43%',
                        ),
                        SizedBox(width: 20),
                        ThresholdCard(
                          backgroundColor: Colors.green,
                          textColor: Colors.black,
                          label: 'Threshold background on',
                          percentage: '20.43%',
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
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
                    // Container(
                    //   margin: const EdgeInsets.only(top: 10),
                    //   width: 350,
                    //   height: 300,
                    //   child: Chart(
                    //     rebuild: rebuild,
                    //     data: roseData,
                    //     variables: {
                    //       'name': Variable(
                    //         accessor: (Map map) => map['name'] as String,
                    //       ),
                    //       'value': Variable(
                    //         accessor: (Map map) => map['value'] as num,
                    //         scale: LinearScale(min: 0, marginMax: 0.1),
                    //       ),
                    //     },
                    //     marks: [
                    //       IntervalMark(
                    //         label: LabelEncode(
                    //             encoder: (tuple) =>
                    //                 Label(tuple['name'].toString())),
                    //         shape: ShapeEncode(
                    //             value: RectShape(
                    //           borderRadius:
                    //               const BorderRadius.all(Radius.circular(10)),
                    //         )),
                    //         color: ColorEncode(
                    //             variable: 'name', values: Defaults.colors10),
                    //         elevation: ElevationEncode(value: 5),
                    //         transition: Transition(
                    //             duration: Duration(seconds: 2),
                    //             curve: Curves.elasticOut),
                    //         entrance: {MarkEntrance.y},
                    //       )
                    //     ],
                    //     coord: PolarCoord(startRadius: 0.15),
                    //   ),
                    // ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                      child: const Text(
                        'Morphing',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 5),
                      child: const Text(
                        'Line and Area chart animated Entrance',
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '- With tree entrance values: x, y, alpha',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
                      alignment: Alignment.centerLeft,
                      child: const Text(
                        '- Press refreash to rebuild.',
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      width: 350,
                      height: 300,
                      child: Chart(
                        rebuild: rebuild,
                        data: invalidData,
                        variables: {
                          'Date': Variable(
                            accessor: (Map map) => map['Date'] as String,
                            scale: OrdinalScale(tickCount: 5),
                          ),
                          'Close': Variable(
                            accessor: (Map map) =>
                                (map['Close'] ?? double.nan) as num,
                          ),
                        },
                        marks: [
                          AreaMark(
                            shape: ShapeEncode(
                                value: BasicAreaShape(smooth: true)),
                            gradient: GradientEncode(
                                value: LinearGradient(colors: [
                              Defaults.colors10.first.withAlpha(80),
                              Defaults.colors10.first.withAlpha(10),
                            ])),
                            transition:
                                Transition(duration: Duration(seconds: 2)),
                            entrance: {
                              MarkEntrance.x,
                              MarkEntrance.y,
                              MarkEntrance.opacity
                            },
                          ),
                          LineMark(
                            shape: ShapeEncode(
                                value: BasicLineShape(smooth: true)),
                            size: SizeEncode(value: 0.5),
                            transition:
                                Transition(duration: Duration(seconds: 2)),
                            entrance: {
                              MarkEntrance.x,
                              MarkEntrance.y,
                              MarkEntrance.opacity
                            },
                          ),
                        ],
                        axes: [
                          Defaults.horizontalAxis,
                          Defaults.verticalAxis,
                        ],
                      ),
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
  final String percentage;

  ThresholdCard({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          Spacer(),
          Text(
            percentage,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
