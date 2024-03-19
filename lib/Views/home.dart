import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Dialogs/pid_dialog.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final limitCount = 100;
  final sinPoints = <FlSpot>[];
  final cosPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      while (sinPoints.length > limitCount) {
        sinPoints.removeAt(0);
        cosPoints.removeAt(0);
      }
      setState(() {
        sinPoints.add(FlSpot(xValue, math.sin(xValue)));
        cosPoints.add(FlSpot(xValue, math.cos(xValue)));
      });
      xValue += step;
    });
  }

  @override
  Widget build(BuildContext context){
    final currentWidth = MediaQuery.of(context).size.width;
    //final currentHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo[900],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: currentWidth * 50/100,
                //height: currentHeight * 30/100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  /*gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.black,
                      Colors.deepPurple,
                      //isDarkMode ? const Color.fromRGBO(20, 20, 30, 1):Colors.white,
                      //isDarkMode ? const Color.fromRGBO(41, 50, 91, 1):Colors.lightBlueAccent,
                    ],
                  ),*/
                  color: Colors.blueGrey[500],
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(-10, 15),
                        blurRadius: 10,
                        spreadRadius: 3)
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'FacePlate SE270-2',
                        style: TextStyle(
                          fontSize: 20
                        ),
                      ),
                      const SizedBox(height: 24,),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: (){

                            },
                            child: const Text('Start')
                          ),
                          const SizedBox(width: 12,),
                          ElevatedButton(
                            onPressed: (){

                            },
                            child: const Text('Stop')
                          ),
                          const SizedBox(width: 12,),
                          ElevatedButton(
                            onPressed: (){
                              showDialog(context: context, builder: (context){
                                return const PIDDialog();
                              });
                            },
                            child: const Text('PID Tuner')
                          ),
                        ],
                      ),

                    ],
                  ),
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                width: currentWidth,
                //height: currentHeight * 50/100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.blueGrey[900],
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        offset: const Offset(-10, 15),
                        blurRadius: 10,
                        spreadRadius: 3
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'SE270-2 PROCESS CONTROL CHART',
                      style: TextStyle(
                        fontSize: 24
                      ),
                    ),
                    const SizedBox(height: 24,),
                    cosPoints.isNotEmpty ? AspectRatio(
                      aspectRatio: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: LineChart(
                          LineChartData(
                            minY: -1,
                            maxY: 1,
                            minX: sinPoints.first.x,
                            maxX: sinPoints.last.x,
                            lineTouchData: const LineTouchData(enabled: false),
                            clipData: const FlClipData.all(),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: false,
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              sinLine(sinPoints),
                              cosLine(cosPoints),
                            ],
                            titlesData: const FlTitlesData(
                              show: false,
                            ),
                          ),
                        ),
                      ),
                    ): Container(),
                    /*LineChart(
                      LineChartData(
                        minX: 150,
                        minY: 100,
                        lineBarsData: [
                          LineChartBarData(
                            color: Colors.blue,
                            isCurved: true,
                          )
                        ],
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)
                          ),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)
                          ),
                          leftTitles: AxisTitles(
                            axisNameWidget: Text('Water Level Percentage (%)'),
                            sideTitles: SideTitles(showTitles: true)
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: Text('Time (seconds)'),
                              sideTitles: SideTitles(showTitles: true)
                          ),
                        )
                      )
                    )*/
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData sinLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: const LinearGradient(
        //colors: [widget.sinColor.withOpacity(0), widget.sinColor],
        colors: [Colors.blue,Colors.green],
        stops: [0.1, 1.0],
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: const LinearGradient(
        colors: [Colors.yellow, Colors.red],//[widget.cosColor.withOpacity(0), widget.cosColor],
        stops: [0.1, 1.0],
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

}
