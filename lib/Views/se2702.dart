import 'dart:math' as math;
import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Animation/water_level_animation.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';
import 'package:soltwin_se2702/Services/rest_api.dart';
import 'package:soltwin_se2702/Services/socketio.dart';
import 'package:soltwin_se2702/Services/websocket.dart';
import 'package:lottie/lottie.dart';

class SE2702 extends StatefulWidget {
  const SE2702({Key? key}) : super(key: key);

  @override
  State<SE2702> createState() => _SE2702State();
}

class _SE2702State extends State<SE2702> {
  //Web socket
  WebSocketServices? webSocketServices;
  SocketIOManager? socketIOManager;

  //TCP
  Socket? _tcpSocket;
  //late Timer _dataTimer;

  //Animation State
  bool p201Stat = false;
  bool sv203Stat = false;
  bool tankFilled = false;
  bool powerStat = false;

  bool shouldAnimateTank = false;
  bool shouldAnimateCylinder = false;

  bool shouldReverseTank = false;
  bool shouldReverseCylinder = false;

  //PID Control and Value
  double pvValue = 50.0;
  double mvValue = 30.0;
  double svValue = 50.0;

  final kP = TextEditingController();
  final kI = TextEditingController();
  final kD = TextEditingController();

  //fl_chart settings
  final limitCount = 1000;
  final sinPoints = <FlSpot>[];
  final cosPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  late Timer timer;

  //functions

  void startWSConnections() {
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

  void stopWSConnections() {
    webSocketServices?.disconnect();
    socketIOManager?.close();
  }

  void startTcpConnection() async {
    try {
      _tcpSocket = await Socket.connect('192.168.1.100', 3000); // Use your server's IP and port
      _tcpSocket!.listen((List<int> data) {
        var jsonString = String.fromCharCodes(data).trim();
        var jsonData = jsonDecode(jsonString);
        processTcpData(jsonData);
      });
    } catch (e) {
      print('Failed to connect to TCP server: $e');
    }
  }

  void processTcpData(dynamic jsonData) {
    // Assuming jsonData is a Map<String, dynamic>
    setState(() {
      pvValue = double.parse(jsonData['pv'] ?? '0');
      mvValue = double.parse(jsonData['mv'] ?? '0');
      // Update your chart or state based on new data
    });
  }

  void stopTcpConnection() {
    _tcpSocket?.close();
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

    startTcpConnection();  // Start TCP connection when the widget is initialized
  }

  @override
  Widget build(BuildContext context){
    //final currentWidth = MediaQuery.of(context).size.width;
    //final currentHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const CustomAppBar(),
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
                        right: 15,
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
                                    color: powerStat ? Colors.green[200]! : Colors.transparent,
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
                                    color: powerStat & p201Stat ? Colors.green[200]! : Colors.transparent,
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
                                    color: powerStat & sv203Stat ? Colors.green[200]! : Colors.transparent,
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
                            key: const ValueKey('cylinderTankAnimation'),
                            width: 10,
                            height: 130,
                            shouldAnimate: powerStat && p201Stat && sv203Stat && tankFilled,
                            shouldReverse: !powerStat || !p201Stat || !sv203Stat || !tankFilled,)
                      ),
                      //Water Tank Animation
                      Positioned(
                          bottom: 40,
                          left: 153,
                          child: WaterLevelAnimation(
                            key: const ValueKey('waterTankAnimation'),
                            width: 22,
                            height: 45,
                            shouldAnimate: shouldAnimateTank,
                            shouldReverse: shouldReverseTank,)
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
                  child: Card(
                    elevation: 20,
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
                  child: Card(
                    elevation: 20,
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            /*Row(
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
                            const SizedBox(height: 12,),*/
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text(
                                  'P Value: ',
                                  style: TextStyle(
                                      color: Colors.white
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: kP,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      contentPadding: EdgeInsets.only(left: 12),
                                      //labelText: '  P Value',
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text(
                                  'I Value: ',
                                  style: TextStyle(
                                      color: Colors.white
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: kI,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      contentPadding: EdgeInsets.only(left: 12),
                                      //labelText: '  P Value',
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text(
                                  'D Value: ',
                                  style: TextStyle(
                                      color: Colors.white
                                  ),
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: kD,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      contentPadding: EdgeInsets.only(left: 12),
                                      //labelText: '  P Value',
                                    ),
                                  ),
                                )
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
              child: Card(
                elevation: 20,
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
    stopTcpConnection();  // Close the TCP connection when the widget is disposed
    super.dispose();
  }
}
