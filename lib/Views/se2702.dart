
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Animation/water_level_animation.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';
import 'package:soltwin_se2702/Services/rest_api.dart';
import 'package:soltwin_se2702/Services/websocket.dart';
import 'package:lottie/lottie.dart';

class SE2702 extends StatefulWidget {
  const SE2702({Key? key}) : super(key: key);

  @override
  State<SE2702> createState() => _SE2702State();
}

class _SE2702State extends State<SE2702> {
  //Web socket Service
  WebSocketServices? webSocketServices;

  void startWSConnections() {
    webSocketServices = WebSocketServices('ws://192.168.1.102:3001');
    webSocketServices?.onMessageReceived = (message) {
      //print('WebSocket message: ${message.toString()}');
      var jsonData = jsonDecode(message);
      processWSData(jsonData);
    };
  }

  void stopWSConnections() {
    webSocketServices?.disconnect();
  }

  void processWSData(var jsonData) {
    // Extract data from jsonData and use it as needed
    double time = jsonData['time'];
    double output = jsonData['output'] * 100 ?? 0;
    double controlSignal = jsonData['control_signal'] * 100 ?? 0;
    double setPoint = jsonData['setPoint'] * 100 ?? 0;
    //String mode = jsonData['mode'];

    setState(() {
      pvValue = output;
      mvValue = controlSignal;
      svValue = setPoint;

      pvPoints.add(FlSpot(time, output));
      svPoints.add(FlSpot(time, setPoint));
      /*while (pvPoints.length > limitCount) {
        pvPoints.removeAt(0);
        svPoints.removeAt(0);
        setState(() {
          pvPoints.add(FlSpot(50, output));
          svPoints.add(FlSpot(50, setPoint));
        });
      }*/
      // Update your chart or state based on new data
    });
  }

  //API Service
  final APIServices apiServices = APIServices();

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
  final svTextController = TextEditingController();
  final mvTextController = TextEditingController();

  //fl_chart settings
  final limitCount = 1000;
  var svPoints = <FlSpot>[];
  var pvPoints = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  //Display API status message
  String statusMessage = '';
  bool isShowingMessage = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      pvPoints.add(const FlSpot(0, 0));
      svPoints.add(const FlSpot(0, 0));
    });

    startWSConnections();  // Start TCP connection when the widget is initialized
  }

  @override
  Widget build(BuildContext context){
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
                                  child: const Text(
                                    'Power On',
                                  )
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
                          const Text('Simulation: Stop'), //${cosPoints.last.x.toStringAsFixed(2)}
                          const SizedBox(height: 4,),
                          const Text('PID Mode: Auto'),
                          const SizedBox(height: 12,),
                          Text('Process Variable: ${pvValue.toStringAsFixed(2)}'), //${cosPoints.last.x.toStringAsFixed(2)}
                          const SizedBox(height: 4,),
                          Text('Manipulated Variable: ${mvValue.toStringAsFixed(2)}'), //${sinPoints.last.x.toStringAsFixed(2)}
                          const SizedBox(height: 4,),
                          Text('Setpoint Variable: $svValue'),
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
                                      startWSConnections();
                                      setState(() {
                                        pvPoints = []; // Clear the data
                                        svPoints = []; // Clear the data
                                      });
                                      await apiServices.matlabControl('se270', null, 'start');
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
                                      stopWSConnections();
                                      await apiServices.matlabControl('se270', null, 'stop');
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
                                const SizedBox(width: 24,),
                                const VerticalDivider(
                                  width: 20, // Width of the divider
                                  thickness: 2, // Thickness of the line
                                  color: Colors.white, // Color of the divider
                                ),
                                const SizedBox(width: 24,),
                                ElevatedButton(
                                    onPressed: ()async{
                                      await apiServices.switchAutoMode();
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
                                    child: const Text('Auto')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: ()async{
                                      await apiServices.switchManualMode();
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
                                    child: const Text('Manual')
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
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                const Text(
                                  'P Value: ',
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: kP,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(
                                        borderSide: BorderSide()
                                      ),
                                      isDense: true,
                                      filled: true,
                                      //labelText: '  P Value',
                                    ),
                                    onSubmitted: (String value) async {
                                      await apiServices.setPID('updatePID', 'P', double.parse(value));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12,),
                                const Text(
                                  'I Value:  ',
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
                                      isDense: true,
                                      filled: true,
                                      //labelText: '  P Value',
                                    ),
                                    onSubmitted: (String value) async {
                                      await apiServices.setPID('updatePID', 'I', double.parse(value));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12,),
                                const Text(
                                  'D Value: ',
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
                                      isDense: true,
                                      filled: true,
                                      //labelText: '  P Value',
                                    ),
                                    onSubmitted: (String value) async {
                                      await apiServices.setPID('updatePID', 'D', double.parse(value));
                                    },
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
                                  'Setpoint:  ',
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: svTextController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      isDense: true,
                                      filled: true,
                                      //labelText: '  P Value',
                                    ),
                                    onSubmitted: (String value) async {
                                      await apiServices.setPID('changeSetPoint', 'setPoint', double.parse(value));
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12,),
                                const Text(
                                  'Manipulated Value (MV): ',
                                ),
                                SizedBox(
                                  width: 100,
                                  child: TextField(
                                    controller: mvTextController,
                                    keyboardType: const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    decoration: const InputDecoration(
                                      border: UnderlineInputBorder(),
                                      isDense: true,
                                      filled: true,
                                      //labelText: '  P Value',
                                    ),
                                    onSubmitted: (String value) async {
                                      await apiServices.setPID('updateConstant', 'constantValue', double.parse(value));
                                    },
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12,),
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
                    pvPoints.isNotEmpty ? AspectRatio(
                      aspectRatio: 3.5,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          minX: 0,//sinPoints.first.x,
                          maxX: 50,//sinPoints.last.x,
                          lineTouchData: LineTouchData(
                            enabled: true,
                              touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  String label;
                                  switch (spot.barIndex) {
                                    case 0:
                                      label = 'SV: ${spot.y.toStringAsFixed(2)}';
                                      break;
                                    case 1:
                                      label = 'PV: ${spot.y.toStringAsFixed(2)}';
                                      break;
                                    default:
                                      label = 'Unknown: ${spot.y}';
                                  }
                                  return LineTooltipItem(
                                    label,
                                    const TextStyle(color: Colors.black),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          clipData: const FlClipData.all(),
                          gridData: const FlGridData(
                            show: true,
                            drawVerticalLine: true,
                          ),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            sinLine(svPoints),
                            cosLine(pvPoints),
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
      barWidth: 2,
    );
  }

  LineChartBarData cosLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      color: Colors.blue,
      barWidth: 2,
    );
  }

  @override
  void dispose() {
    stopWSConnections();  // Close the TCP connection when the widget is disposed
    super.dispose();
  }
}
