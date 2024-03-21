import 'dart:math' as math;
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Animation/water_level_animation.dart';
import 'package:soltwin_se2702/Dialogs/pid_dialog.dart';
import 'package:soltwin_se2702/Services/rest_api.dart';
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

  bool p201Stat = false;
  bool sv203Stat = false;
  bool tankFilled = false;
  bool powerStat = false;

  bool shouldAnimateTank = false;
  bool shouldAnimateCylinder = false;

  bool shouldReverseTank = false;
  bool shouldReverseCylinder = false;

  double pvValue = 50.0;
  double mvValue = 30.0;
  double svValue = 50.0;


  final limitCount = 1000;
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
                    //LED P-201
                    Positioned(
                      right: 35,
                      top: 40,
                      child: Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            decoration: BoxDecoration(
                              color: powerStat ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: powerStat ? Colors.green[200]! : Colors.black,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4,),
                          const Text('Power Status'),
                        ],
                      ),
                    ),
                    //LED P-201
                    Positioned(
                      right: 35,
                      bottom: 40,
                      child: Row(
                        children: [
                          Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: powerStat & p201Stat ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: powerStat & p201Stat ? Colors.green[200]! : Colors.black,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4,),
                          const Text('P-201'),
                        ],
                      ),
                    ),
                    //LED SV-203
                    Positioned(
                      right: 15,
                      bottom: 160,
                      child: Row(
                        children:[
                          Container(
                            width: 12.0,
                            height: 12.0,
                            decoration: BoxDecoration(
                              color: powerStat & sv203Stat ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: powerStat & sv203Stat ? Colors.green[200]! : Colors.black,
                                  blurRadius: 10.0,
                                  spreadRadius: 5.0,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4,),
                          const Text('SV-203'),
                        ],
                      ),
                    ),
                    //Cylinder Tank Animation
                    Positioned(
                        top: 80,
                        left: 154,
                        child: WaterLevelAnimation(
                          width: 10,
                          height: 130,
                          shouldAnimate: powerStat && p201Stat && sv203Stat && tankFilled,
                          shouldReverse: !powerStat || !p201Stat || !sv203Stat || !tankFilled,)
                    ),
                    //Water Tank Animation
                    Positioned(
                      bottom: 40,
                      left: 153,
                      child: WaterLevelAnimation(width: 22, height: 45, shouldAnimate: shouldAnimateTank, shouldReverse: shouldReverseTank,)
                    ),
                    //Arrow
                    Visibility(
                      visible: sv203Stat && powerStat && p201Stat && tankFilled,
                      child: Positioned(
                        left: 110,
                        top: 90,
                        child: Lottie.asset(
                          'assets/lotties/arrow-lottie.json',
                          width: 50,
                          height: 100
                        )
                      ),
                    ),
                    Visibility(
                      visible: sv203Stat && powerStat && p201Stat && tankFilled,
                      child: Positioned(
                        left: 160,
                        top: 20,
                        child: Transform.rotate(
                          angle: 1.571, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                          child: Lottie.asset(
                            'assets/lotties/arrow-lottie.json',
                            width: 50,
                            height: 50
                          ),
                        )
                      ),
                    ),
                    Visibility(
                      visible: sv203Stat && powerStat && p201Stat && tankFilled,
                      child: Positioned(
                        left: 200,
                        top: 110,
                        child: Transform.rotate(
                          angle: 3.142, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                          child: Lottie.asset(
                            'assets/lotties/arrow-lottie.json',
                            width: 50,
                            height: 50
                          ),
                        )
                      ),
                    ),
                    Visibility(
                      visible: sv203Stat && powerStat && p201Stat && tankFilled,
                      child: Positioned(
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
                    ),
                    Visibility(
                      visible: sv203Stat && powerStat && p201Stat && tankFilled,
                      child: Positioned(
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
                    ),
                    Visibility(
                      visible: sv203Stat && powerStat && p201Stat && tankFilled,
                      child: Positioned(
                          left: 450,
                          top: 230,
                          child: Transform.rotate(
                            angle: 3.142, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                            child: Lottie.asset(
                                'assets/lotties/arrow-lottie.json',
                                width: 50,
                                height: 50
                            ),
                          )
                      ),
                    ),
                    Visibility(
                      visible: powerStat && p201Stat && tankFilled,
                      child: Positioned(
                          left: 400,
                          top: 325,
                          child: Transform.rotate(
                            angle: 3.142, //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                            child: Lottie.asset(
                                'assets/lotties/arrow-lottie.json',
                                width: 50,
                                height: 50
                            ),
                          )
                      ),
                    ),
                    Visibility(
                      visible: tankFilled,
                      child: Positioned(
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
                                      setState(() {
                                        powerStat = !powerStat;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          powerStat ? Colors.green : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('Power On')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        p201Stat = !p201Stat;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          p201Stat ? Colors.green : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('P-201')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        sv203Stat = !sv203Stat;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          sv203Stat ? Colors.green : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('SV-203')
                                ),
                              ],
                            ),
                            const SizedBox(height: 12,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        shouldAnimateTank = !shouldAnimateTank;
                                        tankFilled = true;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          shouldAnimateTank ? Colors.green : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('Fill Up Tank')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: (){
                                      setState(() {
                                        shouldReverseTank = !shouldReverseTank;
                                        if(shouldAnimateTank == false){
                                          tankFilled = false;
                                        }
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          shouldReverseTank ? Colors.green : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('Drain Out Water')
                                ),
                              ],
                            ),
                            const SizedBox(height: 28,),
                            const Text(
                              'Equipment Status',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                            const SizedBox(height: 12,),
                            Text('Process Variable: $pvValue'), //${cosPoints.last.x.toStringAsFixed(2)}
                            const SizedBox(height: 4,),
                            Text('Manipulated Variable: $mvValue'), //${sinPoints.last.x.toStringAsFixed(2)}
                            const SizedBox(height: 4,),
                            Text('Setpoint Variable: ${svValue.toStringAsFixed(2)}'),
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
                            'MODELLING SE270-2',
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
                                  onPressed: ()async{
                                    await APIServices().startMatlab();
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
                                  onPressed: ()async{
                                    await APIServices().stopMatlab();
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
                      child: LineChart(
                        LineChartData(
                          minY: -2,
                          maxY: 2,
                          minX: 0,//sinPoints.first.x,
                          maxX: 50,//sinPoints.last.x,
                          lineTouchData: const LineTouchData(
                              enabled: true
                          ),
                          clipData: const FlClipData.all(),
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: true,
                          ),
                          borderData: FlBorderData(show: true),
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
                                showTitles: true,
                                reservedSize: 30
                              )
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 40
                              )
                            ),
                          ),
                        ),
                      ),
                    ): Container(),
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
      color: Colors.green,
      /*gradient: const LinearGradient(
        //colors: [widget.sinColor.withOpacity(0), widget.sinColor],
        colors: [Colors.green],
        stops: [0.1, 1.0],
      ),*/
      barWidth: 2,
      isCurved: true,
    );
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      color: Colors.blue,
      /*gradient: const LinearGradient(
        colors: [Colors.blue],//[widget.cosColor.withOpacity(0), widget.cosColor],
        stops: [0.1, 1.0],
      ),*/
      barWidth: 2,
      isCurved: true,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

}
