
import 'dart:convert';
import 'dart:html' as html;

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:soltwin_se2702/Animation/water_level_animation.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/Providers/water_level_provider.dart';
import 'package:soltwin_se2702/Services/getset_preferences.dart';
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
  double maxX = 50;
  double minX = 0;

  //API Service
  final APIServices apiServices = APIServices();

  //Animation State
  bool p201Stat = false;
  bool sv203Stat = false;
  bool tankFilled = false;
  bool powerStat = false;
  bool isFillingTank = false;
  bool isFillingCylinder = false;
  bool isDrainingTank = false;
  bool isDrainingCylinder = false;

  //PID Control and Value
  String currentMode = 'Manual';
  String currentStatus = 'Stop';
  double pvValue = 0.0;
  double mvValue = 0.0;
  double svValue = 0.0;

  final kP = TextEditingController(text: '0');
  final kI = TextEditingController(text: '0');
  final kD = TextEditingController(text: '0');
  final svTextController = TextEditingController(text: '0');
  final mvTextController = TextEditingController(text: '0');

  //fl_chart settings
  final limitCount = 1000;
  var svPoints = <FlSpot>[const FlSpot(1.0, 20.0),const FlSpot(2.0, 25.0),const FlSpot(3.0, 30.0),const FlSpot(4.0, 35.0),const FlSpot(5.0, 40.0),const FlSpot(6.0, 45.0),const FlSpot(7.0, 50.0)];
  var pvPoints = <FlSpot>[const FlSpot(1.0, 50.0),const FlSpot(2.0, 45.0),const FlSpot(3.0, 40.0),const FlSpot(4.0, 35.0),const FlSpot(5.0, 30.0),const FlSpot(6.0, 25.0),const FlSpot(7.0, 20.0)];

  // Prepare the data
  List<List<dynamic>> csvData = [
    ['time', 'Setpoint (SV)', 'Process Variable (PV)']  // Headers
  ];

  double xValue = 0;
  double step = 0.05;

  //Display API status message
  String statusMessage = '';
  bool isShowingMessage = false;

  void startWSConnections() {
    try{
      webSocketServices = WebSocketServices('ws://192.168.1.102:3003');
      webSocketServices?.onMessageReceived = (message) {
        //print('WebSocket message: ${message.toString()}');
        var jsonData = jsonDecode(message);
        processWSData(jsonData);
      };
    }catch(e){
      if(!mounted)return;
      showDialog(
          context: context,
          builder: (context) => const ShareMessageDialog(
              contentMessage: 'Unable to communicate with the server. Please try again later.'
          ));
    }
  }

  void stopWSConnections() {
    webSocketServices?.disconnect();
  }

  void processWSData(var jsonData) async{
    // Extract data from jsonData and use it as needed
    String userID = jsonData['userID'];
    double time = jsonData['time'];
    double output = jsonData['output'] * 100 ?? 0;
    double controlSignal = jsonData['control_signal']?? 0;
    double setPoint = jsonData['setPoint'] * 100 ?? 0;
    //String mode = jsonData['mode'];
    final provider = Provider.of<WaterLevelProvider>(context, listen: false);
    provider.setTankLevel(1, jsonData['output']);
    final userIDStored = await getUserID();

    setState(() {
      if(userID == userIDStored){
        pvValue = output;
        mvValue = controlSignal;
        svValue = setPoint;

        pvPoints.add(FlSpot(time, output));
        svPoints.add(FlSpot(time, setPoint));

        csvData.add([time, output, setPoint]); // For excel export

        //change maxX if longer than 50 seconds
        if(time > maxX){
          setState(() {
            maxX += 1;
          });
        }
      }
      // Update your chart or state based on new data
    });
  }

  void updateWaterLevel() {
    final provider = Provider.of<WaterLevelProvider>(context, listen: false);
    double currentLevel = provider.tank2Level; // Get current level for tank 1
    bool shouldAnimate = false;

    if (isFillingTank && !isDrainingTank) {
      currentLevel = (currentLevel + 0.01).clamp(0.0, 1.0); // Increment level
      shouldAnimate = true;
    } else if (isDrainingTank && !isFillingTank) {
      currentLevel = (currentLevel - 0.01).clamp(0.0, 1.0); // Decrement level
      shouldAnimate = true;
    }else{
      shouldAnimate = false;
    }

    if(currentLevel > 0.0){
      setState(() {
        tankFilled = true;
      });
    }else if(currentLevel == 1.0){
      isDrainingTank = false;
      isFillingTank = false;
    }
    else {
      setState(() {
        tankFilled = false;
        isDrainingTank = false;
        isFillingTank = false;
      });
    }
    // If both are true or both are false, do nothing (stops where it is)

    provider.setTankLevel(2, currentLevel); // Update the level in the provider

    if (shouldAnimate) {
      if(!mounted)return;
      Future.delayed(const Duration(milliseconds: 100), () => updateWaterLevel()); // Continue updating
    }
  }

  void exportChartToCSV(List<List<dynamic>> data) {
    // Convert data to CSV string
    String csvData = const ListToCsvConverter().convert(data);
    DateTime dateTime = DateTime.now();
    String dateTimeString = dateTime.toString();

    // Encode the CSV data
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url);

    // Set the download name for the CSV file
    anchor.download = '$dateTimeString-se2702.csv';

    // Trigger the download
    anchor.click();

    // Cleanup
    html.Url.revokeObjectUrl(url);
  }

  @override
  void initState() {
    super.initState();
    try{
      APIServices().runSE2702Model();
    }catch(e){
      showDialog(context: context, builder: (context) => ShareMessageDialog(
          contentMessage: 'Failed to start SE2702 Model. Error message: ${e.toString()}'
      ));
    }

    for (int i = 0; i < svPoints.length; i++) {
      csvData.add([svPoints[i].x, svPoints[i].y, pvPoints[i].y]);
    }
    //startWSConnections();  // Start Web Socket connection when the widget is initialized
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
                                color: powerStat ? Colors.green : Colors
                                    .grey,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: powerStat
                                        ? Colors.green[200] ?? Colors.green
                                        : Colors.transparent,
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
                                color: powerStat & p201Stat
                                    ? Colors.green
                                    : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: powerStat & p201Stat ?
                                    Colors.green[200] ?? Colors.green : Colors.transparent,
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
                          children: [
                            Container(
                              width: 12.0,
                              height: 12.0,
                              decoration: BoxDecoration(
                                color: powerStat & sv203Stat ? Colors
                                    .green : Colors.grey,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: powerStat & sv203Stat ? Colors
                                        .green[200] ?? Colors.green : Colors.transparent,
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
                      const Positioned(
                          top: 80,
                          left: 154,
                          child: WaterLevelAnimation(
                            key: ValueKey('cylinderTankAnimation'),
                            width: 10,
                            height: 130,
                            tankNumber: 1,
                          )
                      ),
                      //Water Tank Animation
                      const Positioned(
                          bottom: 40,
                          left: 153,
                          child: WaterLevelAnimation(
                            key: ValueKey('waterTankAnimation'),
                            width: 22,
                            height: 45,
                            tankNumber: 2,
                          )
                      ),
                      //Arrow
                      Visibility(
                        visible: sv203Stat && powerStat && p201Stat &&
                            tankFilled,
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
                        visible: sv203Stat && powerStat && p201Stat &&
                            tankFilled,
                        child: Positioned(
                            left: 160,
                            top: 20,
                            child: Transform.rotate(
                              angle: 1.571,
                              //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                              child: Lottie.asset(
                                  'assets/lotties/arrow-lottie.json',
                                  width: 50,
                                  height: 50
                              ),
                            )
                        ),
                      ),
                      Visibility(
                        visible: sv203Stat && powerStat && p201Stat &&
                            tankFilled,
                        child: Positioned(
                            left: 200,
                            top: 110,
                            child: Transform.rotate(
                              angle: 3.142,
                              //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                              child: Lottie.asset(
                                  'assets/lotties/arrow-lottie.json',
                                  width: 50,
                                  height: 50
                              ),
                            )
                        ),
                      ),
                      Visibility(
                        visible: sv203Stat && powerStat && p201Stat &&
                            tankFilled,
                        child: Positioned(
                            left: 250,
                            top: 155,
                            child: Transform.rotate(
                              angle: 1.571,
                              //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
                              child: Lottie.asset(
                                  'assets/lotties/arrow-lottie.json',
                                  width: 50,
                                  height: 50
                              ),
                            )
                        ),
                      ),
                      Visibility(
                        visible: sv203Stat && powerStat && p201Stat &&
                            tankFilled,
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
                        visible: sv203Stat && powerStat && p201Stat &&
                            tankFilled,
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
                              crossAxisAlignment: CrossAxisAlignment
                                  .start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        powerStat = !powerStat;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(
                                          powerStat
                                              ? Colors.green
                                              : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty
                                          .all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text(
                                      'Power On',
                                    )
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        p201Stat = !p201Stat;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(
                                          p201Stat ? Colors.green : Colors
                                              .red
                                      ),
                                      minimumSize: MaterialStateProperty
                                          .all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('P-201')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        sv203Stat = !sv203Stat;
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(
                                          sv203Stat
                                              ? Colors.green
                                              : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty
                                          .all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('SV-203')
                                ),
                              ],
                            ),
                            const SizedBox(height: 12,),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment
                                  .start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isFillingTank = !isFillingTank;
                                        updateWaterLevel();
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(
                                          isFillingTank
                                              ? Colors.green
                                              : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty
                                          .all<Size>(
                                          const Size(100, 48)
                                      ),
                                    ),
                                    child: const Text('Fill Up Tank')
                                ),
                                const SizedBox(width: 12,),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isDrainingTank = !isDrainingTank;
                                        updateWaterLevel();
                                      });
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius
                                              .circular(4.0),
                                        ),
                                      ),
                                      backgroundColor: MaterialStateProperty
                                          .all<Color>(
                                          isDrainingTank
                                              ? Colors.green
                                              : Colors.red
                                      ),
                                      minimumSize: MaterialStateProperty
                                          .all<Size>(
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
                            Text('Simulation: $currentStatus'),
                            //${cosPoints.last.x.toStringAsFixed(2)}
                            const SizedBox(height: 4,),
                            Text('PID Mode: $currentMode'),
                            const SizedBox(height: 12,),
                            Text('Process Variable: ${pvValue
                                .toStringAsFixed(2)}'),
                            //${cosPoints.last.x.toStringAsFixed(2)}
                            const SizedBox(height: 4,),
                            Text('Manipulated Variable: ${mvValue
                                .toStringAsFixed(2)}'),
                            //${sinPoints.last.x.toStringAsFixed(2)}
                            const SizedBox(height: 4,),
                            Text('Setpoint Variable: $svValue'),
                          ],
                        ),
                      )
                  ),
                ),
                Visibility(
                  visible: true,
                  child: Padding(
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
                                crossAxisAlignment: CrossAxisAlignment
                                    .start,
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ElevatedButton(
                                      onPressed: () async {
                                        try{
                                          startWSConnections();
                                          setState(() {
                                            pvPoints = []; // Clear the data
                                            svPoints = []; // Clear the data
                                            maxX = 50;
                                          });
                                          bool success = await apiServices.matlabControl('se270', null, 'start');
                                          if(success){
                                            setState(() {
                                              currentStatus = 'Start';
                                            });
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .circular(4.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty
                                            .all<Size>(
                                            const Size(100, 48)
                                        ),
                                      ),
                                      child: const Text('Start')
                                  ),
                                  const SizedBox(width: 12,),
                                  ElevatedButton(
                                      onPressed: () async {
                                        try{
                                          stopWSConnections();
                                          bool success = await apiServices.matlabControl('se270', null, 'exit');
                                          if(success){
                                            setState(() {
                                              currentStatus = 'Stop';
                                            });
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .circular(4.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty
                                            .all<Size>(
                                            const Size(100, 48)
                                        ),
                                      ),
                                      child: const Text('Stop')
                                  ),
                                  const SizedBox(width: 24,),
                                  const VerticalDivider(
                                    width: 20, // Width of the divider
                                    thickness: 2, // Thickness of the line
                                    color: Colors
                                        .white, // Color of the divider
                                  ),
                                  const SizedBox(width: 24,),
                                  ElevatedButton(
                                      onPressed: () async {
                                        try{
                                          bool success = await apiServices.setControlCommand('se270', null, 'auto');
                                          if(success){
                                            setState(() {
                                              currentMode = 'Auto';
                                            });
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .circular(4.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty
                                            .all<Size>(
                                            const Size(100, 48)
                                        ),
                                      ),
                                      child: const Text('Auto')
                                  ),
                                  const SizedBox(width: 12,),
                                  ElevatedButton(
                                      onPressed: () async {
                                        try{
                                          bool success = await apiServices.setControlCommand('se270', null, 'manual');
                                          if(success){
                                            setState(() {
                                              currentMode = 'Manual';
                                              mvTextController.text = mvValue.toStringAsFixed(2);
                                            });
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
                                      },
                                      style: ButtonStyle(
                                        shape: MaterialStateProperty.all<
                                            RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius
                                                .circular(4.0),
                                          ),
                                        ),
                                        minimumSize: MaterialStateProperty
                                            .all<Size>(
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
                                crossAxisAlignment: CrossAxisAlignment
                                    .center,
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Text(
                                    'P Value: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: kP,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(
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
                                        try{
                                          await apiServices.setValueCommand('se270',null,'updatePID', 'P', double.parse(value));
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
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
                                      keyboardType: const TextInputType
                                          .numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        isDense: true,
                                        filled: true,
                                        //labelText: '  P Value',
                                      ),
                                      onSubmitted: (String value) async {
                                        try{
                                          await apiServices.setValueCommand(
                                            'se270',null,
                                            'updatePID', 'I',
                                            double.parse(value));
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
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
                                      keyboardType: const TextInputType
                                          .numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        isDense: true,
                                        filled: true,
                                        //labelText: '  P Value',
                                      ),
                                      onSubmitted: (String value) async {
                                        try{
                                          await apiServices.setValueCommand(
                                              'se270',null,
                                              'updatePID', 'D',
                                              double.parse(value));
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
                                      },
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(height: 12,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment
                                    .center,
                                mainAxisAlignment: MainAxisAlignment
                                    .start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  const Text(
                                    'Setpoint:  ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: svTextController,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Enter a number (0-100)',
                                        border: UnderlineInputBorder(),
                                        isDense: true,
                                        filled: true,
                                        //labelText: '  P Value',
                                      ),
                                      onSubmitted: (String value) async {
                                        try{
                                          double filterValue = double.tryParse(value) ?? 0;
                                          if(filterValue < 0 || filterValue > 100){
                                            if(!mounted)return;
                                            showDialog(
                                                context: context,
                                                builder: (context) => const AlertDialog(
                                                    title: Text('Invalid Input'),
                                                    content: Text('Please enter a number between 0 and 100.')
                                                ));
                                          }else{
                                            filterValue = filterValue / 100;
                                            await apiServices.setValueCommand('se270',null, 'changeSetPoint', 'setPoint', filterValue);
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
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
                                      keyboardType: const TextInputType
                                          .numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        isDense: true,
                                        filled: true,
                                        //labelText: '  P Value',
                                      ),
                                      onSubmitted: (String value) async {
                                        try{
                                          double filterValue = double.tryParse(value) ?? 0;
                                          if(filterValue < 0 || filterValue > 100){
                                            if(!mounted)return;
                                            showDialog(
                                                context: context,
                                                builder: (context) => const AlertDialog(
                                                    title: Text('Invalid Input'),
                                                    content: Text('Please enter a number between 0 and 100.')
                                                ));
                                          }else{
                                            await apiServices.setValueCommand('se270',null, 'updateConstant', 'constantValue', filterValue);
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                              context: context,
                                              builder: (context) => const ShareMessageDialog(
                                                  contentMessage: 'Unable to communicate with the server. Please try again later.'
                                              ));
                                        }
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
                ),
              ],
            ),
            pvPoints.isNotEmpty && svPoints.isNotEmpty
                ? Padding(
              padding: const EdgeInsets.all(20),
              child: Card(
                elevation: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          const Text(
                            'SE270-2 PROCESS CONTROL CHART',
                            style: TextStyle(
                                fontSize: 24
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              exportChartToCSV(csvData);
                            },
                            icon: const Icon(Icons.import_export_sharp))
                        ],
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 3.5,
                      child: LineChart(
                        LineChartData(
                          minY: 0,
                          maxY: 100,
                          minX: minX,
                          //sinPoints.first.x,
                          maxX: maxX,
                          //sinPoints.last.x,
                          lineTouchData: LineTouchData(
                            enabled: true,
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems: (
                                  List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  String label;
                                  switch (spot.barIndex) {
                                    case 0:
                                      label =
                                      'SV: ${spot.y.toStringAsFixed(2)}';
                                      break;
                                    case 1:
                                      label =
                                      'PV: ${spot.y.toStringAsFixed(2)}';
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
                            graphLine(svPoints, Colors.green),
                            graphLine(pvPoints, Colors.blue),
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
                    )
                  ],
                ),
              ),
            ): Container(),
          ],
        ),
      ),
    );
  }

  LineChartBarData graphLine(List<FlSpot> points, Color? color){
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      color: color,
      barWidth: 2,
    );
  }

  @override
  void dispose() {
    stopWSConnections();  // Close the TCP connection when the widget is disposed
    super.dispose();
  }
}

Widget visibleArrow(bool visible, double? left, double? top, double? right, double? bottom, double angle){
  return Visibility(
    visible: visible,
    child: Positioned(
        left: left,
        top: top,
        right: right,
        bottom: bottom,
        child: Transform.rotate(
          angle: angle,
          //90Deg = 1.571, 180Deg = 3.142, 270Deg = 4.712,
          child: Lottie.asset(
              'assets/lotties/arrow-lottie.json',
              width: 50,
              height: 50
          ),
        )
    ),
  );
}