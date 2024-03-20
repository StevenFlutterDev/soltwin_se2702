import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Animation/water_level_animation.dart';
import 'package:soltwin_se2702/Dialogs/pid_dialog.dart';
import 'package:soltwin_se2702/Services/socketio.dart';
import 'package:soltwin_se2702/Services/websocket.dart';
import 'package:lottie/lottie.dart';


class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WebSocketServices? webSocketServices;
  SocketIOManager? socketIOManager;

  final limitCount = 2000;
  final sinPoints = <FlSpot>[];
  final cosPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  late Timer timer;

  void startConnections() {
    webSocketServices = WebSocketServices('ws://example.com/socket');
    webSocketServices?.onMessageReceived = (message) {
      print('WebSocket message: $message');
      // Update your UI or data model based on WebSocket messages
    };

    socketIOManager = SocketIOManager('http://example.com');
    socketIOManager?.onMessageReceived = (message) {
      print('Socket.IO message: $message');
      // Update your UI or data model based on Socket.IO messages
    };
  }

  void stopConnections() {
    webSocketServices?.disconnect();
    socketIOManager?.close();
  }

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      while (sinPoints.length > limitCount) {
        sinPoints.removeAt(0);
        cosPoints.removeAt(0);
        setState(() {
          timer.cancel();
        });
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
        leading: Image.asset(
          'assets/images/SOLLOGO.png',
          fit: BoxFit.fitWidth,
        ),
        title: const Text(
          'SOLTWIN',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: (){},
              child: const Text(
                'Login',
                style: TextStyle(
                  letterSpacing: 1.2,
                  color: Colors.white
                ),
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Image.asset(
                      'assets/images/P&ID-SE2702.png',
                      filterQuality: FilterQuality.high,
                      fit: BoxFit.fill,
                    ),
                    //Cylinder Tank
                    const Positioned(
                        bottom: 38,
                        left: 151,
                        child: WaterLevelAnimation(width: 70, height: 45,)
                    ),
                    //Water Tank
                    const Positioned(
                      bottom: 38,
                      left: 151,
                      child: WaterLevelAnimation(width: 70, height: 45,)
                    ),
                    Positioned(
                      left: 100,
                      child: Lottie.asset(
                        'assets/lotties/arrow-lottie.json',
                        width: 50,
                        height: 100
                      )
                    ),
                    Positioned(
                      left: 200,
                      top: 80,
                      child: Transform.rotate(
                        angle: 3.142, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                        child: Lottie.asset(
                          'assets/lotties/arrow-lottie.json',
                          width: 50,
                          height: 50
                        ),
                      )
                    ),
                    Positioned(
                      left: 200,
                      top: 130,
                      child: Transform.rotate(
                        angle: 3.142, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                        child: Lottie.asset(
                          'assets/lotties/arrow-lottie.json',
                          width: 50,
                          height: 50
                        ),
                      )
                    ),
                    Positioned(
                      left: 250,
                      top: 155,
                      child: Transform.rotate(
                        angle: 1.571, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                        child: Lottie.asset(
                          'assets/lotties/arrow-lottie.json',
                          width: 50,
                          height: 50
                        ),
                      )
                    ),
                    Positioned(
                      left: 375,
                      top: 155,
                      child: Transform.rotate(
                        angle: 1.571, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                        child: Lottie.asset(
                          'assets/lotties/arrow-lottie.json',
                          width: 50,
                          height: 50
                        ),
                      )
                    ),
                    Positioned(
                        left: 450,
                        top: 250,
                        child: Transform.rotate(
                          angle: 3.142, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                          child: Lottie.asset(
                              'assets/lotties/arrow-lottie.json',
                              width: 50,
                              height: 50
                          ),
                        )
                    ),
                    Positioned(
                        left: 300,
                        top: 400,
                        child: Transform.rotate(
                          angle: 4.712, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                          child: Lottie.asset(
                              'assets/lotties/arrow-lottie.json',
                              width: 50,
                              height: 50
                          ),
                        )
                    ),
                  ]
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    //width: currentWidth * 50/100,
                    //height: currentHeight * 30/100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
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
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Text(
                              'EQUIPMENT CONTROL',
                              style: TextStyle(
                                  fontSize: 24
                              ),
                            ),
                            const Divider(
                              height: 24,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(
                                    onPressed: (){

                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('Start')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: (){

                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('Stop')
                                ),
                              ],
                            ),
                            const SizedBox(height: 28,),
                            const Text(
                              'PID Control',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                            const SizedBox(height: 12,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      showDialog(context: context, builder: (context){
                                        return const PIDDialog();
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
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
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    //width: currentWidth * 50/100,
                    //height: currentHeight * 30/100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Text(
                            'FACEPLATE SE270-2',
                            style: TextStyle(
                              fontSize: 24
                            ),
                          ),
                          const Divider(
                            height: 24,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ElevatedButton(
                                  onPressed: (){

                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                      const Size(100, 48)
                                    ),
                                  ),
                                  child: const Text('Start')
                              ),
                              const SizedBox(width: 12,),
                              ElevatedButton(
                                  onPressed: (){

                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                        const Size(100, 48)
                                    ),
                                  ),
                                  child: const Text('Stop')
                              ),
                            ],
                          ),
                          const SizedBox(height: 28,),
                          const Text(
                            'PID Control',
                            style: TextStyle(
                                fontSize: 20
                            ),
                          ),
                          const SizedBox(height: 12,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              ElevatedButton(
                                  onPressed: (){
                                    showDialog(context: context, builder: (context){
                                      return const PIDDialog();
                                    });
                                  },
                                  style: ButtonStyle(
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4.0),
                                      ),
                                    ),
                                    minimumSize: MaterialStateProperty.all<Size>(
                                        const Size(100, 48)
                                    ),
                                  ),
                                  child: const Text('PID Tuner')
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ),
                ),
              ],
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
                    const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'SE270-2 PROCESS CONTROL CHART',
                        style: TextStyle(
                          fontSize: 24
                        ),
                      ),
                    ),
                    //const SizedBox(height: 24,),
                    cosPoints.isNotEmpty ? AspectRatio(
                      aspectRatio: 3.5,
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: LineChart(
                          LineChartData(
                            minY: -1,
                            maxY: 1,
                            minX: 0,//sinPoints.first.x,
                            maxX: 100,//sinPoints.last.x,
                            /*lineTouchData: const LineTouchData(
                                enabled: true
                            ),*/
                            clipData: const FlClipData.all(),
                            gridData: const FlGridData(
                              show: true,
                              drawVerticalLine: true,
                            ),
                            borderData: FlBorderData(show: false),
                            lineBarsData: [
                              sinLine(sinPoints),
                              cosLine(cosPoints),
                            ],
                            titlesData: const FlTitlesData(
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false)
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true
                                )
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: true
                                )
                              ),
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
