import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Dialogs/share_message_dialog.dart';
import 'package:soltwin_se2702/Services/rest_api.dart';
import 'package:soltwin_se2702/Services/websocket.dart';

class HE104 extends StatefulWidget {
  const HE104({Key? key}) : super(key: key);

  @override
  State<HE104> createState() => _HE104State();
}

class _HE104State extends State<HE104> {
  final cosPoints = <FlSpot>[];
  final APIServices apiServices = APIServices();
  String modelMode = ' ';

  //CO-Current Value Settings
  final volFlowHotCO = TextEditingController();
  final volFlowColdCO = TextEditingController();
  final thInletCO = TextEditingController();
  final tcInletCO = TextEditingController();

  //Counter Current Value Settings
  final volFlowHotCounter = TextEditingController();
  final volFlowColdCounter = TextEditingController();
  final thInletCounter = TextEditingController();
  final tcInletCounter = TextEditingController();

  WebSocketServices? webSocketServices;
  double maxX = 50;

  void startWSConnections() {
    try{
      webSocketServices = WebSocketServices('ws://192.168.2.30:3003');
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

  void processWSData(var jsonData) {
    // Extract data from jsonData and use it as needed
    double time = jsonData['time'];
    var thPartialArray = jsonData['th_partial'] ?? [[0.0,0.0]];
    var tcPartialArray = jsonData['tc_partial'] ?? [[0.0,0.0]];
    double volFlowHot = jsonData['VolFlowHot'] ?? 0;
    double volFlowCold = jsonData['VolFlowCold'] ?? 0;
    double thFull = jsonData['Th_full'] ?? 0;
    double tcFull= jsonData['Tc_full'] ?? 0;
    double thOutlet = jsonData['Th_outlet'] ?? 0;
    double tcOutlet = jsonData['Tc_outlet'] ?? 0;


    setState(() {
      thPartialPlot = thPartialArray.map((e)=> FlSpot(e[0], e[1])).toList();
      tcPartialPlot = tcPartialArray.map((e)=> FlSpot(e[0], e[1])).toList();
      volFlowHotPlot.add(FlSpot(time, volFlowHot));
      volFlowColdPlot.add(FlSpot(time, volFlowCold));
      thFullPlot.add(FlSpot(time, thFull));
      tcFullPlot.add(FlSpot(time, tcFull));
      thOutletPlot.add(FlSpot(time, thOutlet));
      tcOutletPlot.add(FlSpot(time, tcOutlet));


      //change maxX if longer than 50 seconds
      if(time > maxX){
        setState(() {
          maxX += 1;
        });
      }
      // Update your chart or state based on new data
    });
  }

  //fl_chart settings
  final limitCount = 1000;
  var thPartialPlot = <FlSpot>[];
  var tcPartialPlot = <FlSpot>[];
  var volFlowHotPlot = <FlSpot>[];
  var volFlowColdPlot = <FlSpot>[];
  var thFullPlot = <FlSpot>[];
  var tcFullPlot = <FlSpot>[];
  var thOutletPlot = <FlSpot>[];
  var tcOutletPlot = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  //Display API status message
  String statusMessage = '';
  bool isShowingMessage = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final currentWidth = MediaQuery.of(context).size.width;
    final currentHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      SizedBox(
                        width: currentWidth / 5,
                        height: currentHeight / 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12.0),
                          child: Image.asset(
                            'assets/images/HE104.png',
                            filterQuality: FilterQuality.high,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
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
                              const Text(
                                'Select calculation type:',
                                style: TextStyle(
                                    fontSize: 16
                                ),
                              ),
                              const SizedBox(height: 12,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  ElevatedButton(
                                    onPressed: ()async{
                                      try{
                                        bool result = await apiServices.matlabControl('he104', 'co', 'run');
                                        if(result){
                                          setState(() {
                                            modelMode = 'CO-Current';
                                          });
                                        }else{
                                          setState(() {
                                            modelMode = ' ';
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
                                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4.0),
                                        ),
                                      ),
                                      minimumSize: MaterialStateProperty.all<Size>(
                                          const Size(100, 48)
                                      ),
                                      backgroundColor: MaterialStateProperty.all<Color>(
                                          modelMode == 'CO-Current' ? Colors.green : Colors.grey[900]!
                                      ),
                                    ),
                                    child: const Text(
                                        'CO-Current',
                                    )
                                  ),
                                  const SizedBox(width: 12,),
                                  ElevatedButton(
                                      onPressed: ()async{
                                        try{
                                          bool result = await apiServices.matlabControl('he104', 'counter', 'run');
                                          if(result){
                                            setState(() {
                                              modelMode = 'Counter Current';
                                            });
                                          }else{
                                            setState(() {
                                              modelMode = ' ';
                                            });
                                            if(!mounted)return;
                                            showDialog(
                                                context: context, builder: (BuildContext context) {
                                              return const ShareMessageDialog(
                                                  contentMessage: 'Not able to communicate to the server. Please try again later'
                                              );
                                            });
                                          }
                                        }catch(e){
                                          if(!mounted)return;
                                          showDialog(
                                            context: context,
                                            builder: (context) => const ShareMessageDialog(
                                                contentMessage: 'Unable to communicate with the server. Please try again later.'
                                            )
                                          );
                                        }
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
                                        backgroundColor: MaterialStateProperty.all<Color>(
                                            modelMode == 'Counter Current' ? Colors.green : Colors.grey[900]!
                                        ),
                                      ),
                                      child: const Text('Counter Current')
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 24,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 28,),
                              const Text(
                                'Equipment Status',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                              Text(
                                'Calculation Mode: $modelMode',
                                style: const TextStyle(
                                    fontSize: 16
                                ),
                              ),
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
                                'MODELLING HE104',
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
                                        try{
                                          await apiServices.matlabControl('he104', 'co', 'start');
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
                                        try{
                                          await apiServices.matlabControl('he104', 'co', 'stop');
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
                                'CO-Current Settings',
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
                                    'Vol Flow Hot: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: volFlowHotCO,
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
                                          await apiServices.setValueCommand(
                                              'he104','co',
                                              'updateValue', 'VolFlowHot_mpvar',
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
                                    'Vol Flow Cold:  ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: volFlowColdCO,
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
                                              'he104','co',
                                              'updateValue', 'VolFlowCold_mpvar',
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
                                    'TH Inlet: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: thInletCO,
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
                                              'he104','co',
                                              'updateValue', 'Th_inlet_mpvar',
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
                                    'TC Inlet: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: tcInletCO,
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
                                              'he104','co',
                                              'updateValue', 'Tc_inlet_mpvar',
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
                              const Text(
                                'Counter-Current Settings',
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
                                    'Vol Flow Hot: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: volFlowHotCounter,
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
                                          await apiServices.setValueCommand(
                                              'he104','counter',
                                              'updateValue', 'VolFlowHot_mpvar',
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
                                    'Vol Flow Cold:  ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: volFlowColdCounter,
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
                                              'he104','counter',
                                              'updateValue', 'VolFlowCold_mpvar',
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
                                    'TH Inlet: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: thInletCounter,
                                      keyboardType: const TextInputType
                                          .numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        border: UnderlineInputBorder(),
                                        isDense: true,
                                        filled: true,
                                      ),
                                      onSubmitted: (String value) async {
                                        try{
                                          await apiServices.setValueCommand(
                                              'he104','counter',
                                              'updateValue', 'Th_inlet_mpvar',
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
                                    'TC Inlet: ',
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: tcInletCounter,
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
                                              'he104','counter',
                                              'updateValue', 'Tc_inlet_mpvar',
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
                            ],
                          ),
                        )
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: thPartialPlot.isNotEmpty,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Card(
                    elevation: 20,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'Temperature Profile',
                                style: TextStyle(
                                    fontSize: 24
                                ),
                              ),
                            ),
                            //const SizedBox(height: 24,),
                            cosPoints.isNotEmpty ?
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Temperature (C)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Column(
                                  children: [
                                    SizedBox(
                                      height: currentHeight/1.1,
                                      width: currentWidth/3,
                                      child: LineChart(
                                        LineChartData(
                                          minY: 0,
                                          maxY: 80,
                                          minX: 0,//sinPoints.first.x,
                                          maxX: 0.5,//sinPoints.last.x,
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
                                            graphLine(thPartialPlot, Colors.red),
                                            graphLine(tcPartialPlot, Colors.blue),
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
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(top:8.0, bottom: 24.0),
                                      child: Text(
                                        'Length (m)', // Rotated Y-axis title
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1.2
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ):
                            Container(),
                          ],
                        ),
                        const SizedBox(width: 36.0,),
                        Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'Hot Stream Flowrate',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Flowrate (L/min)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                volFlowHotPlot.isNotEmpty ?
                                SizedBox(
                                  height: currentHeight/4,
                                  width: currentWidth/5,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 6,
                                      minX: 0,//sinPoints.first.x,
                                      maxX: 100,//sinPoints.last.x,
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
                                        graphLine(volFlowHotPlot, Colors.red),
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
                                ):
                                Container(),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0),
                              child: Text(
                                'Time (s)', // Rotated Y-axis title
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                'Hot Stream Inlet Temperature',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Temperature (C)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                cosPoints.isNotEmpty ?
                                SizedBox(
                                  height: currentHeight/4,
                                  width: currentWidth/5,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 20,
                                      maxY: 70,
                                      minX: 0,//sinPoints.first.x,
                                      maxX: 100,//sinPoints.last.x,
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
                                        graphLine(thFullPlot, Colors.red),
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
                                ):
                                Container(),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0),
                              child: Text(
                                'Time (s)', // Rotated Y-axis title
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                'Hot Stream Outlet Temperature',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Temperature (C)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                cosPoints.isNotEmpty ?
                                SizedBox(
                                  height: currentHeight/4,
                                  width: currentWidth/5,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 20,
                                      maxY: 70,
                                      minX: 0,//sinPoints.first.x,
                                      maxX: 100,//sinPoints.last.x,
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
                                        graphLine(thOutletPlot, Colors.red),
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
                                ):
                                Container(),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0),
                              child: Text(
                                'Time (s)', // Rotated Y-axis title
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 36.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(24.0),
                              child: Text(
                                'Cold Stream Flowrate',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Flowrate (L/min)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16,),
                                  ),
                                ),
                                cosPoints.isNotEmpty ?
                                SizedBox(
                                  height: currentHeight/4,
                                  width: currentWidth/5,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 0,
                                      maxY: 6,
                                      minX: 0,//sinPoints.first.x,
                                      maxX: 100,//sinPoints.last.x,
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
                                        graphLine(volFlowColdPlot, Colors.blue),
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
                                ):
                                Container(),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0,),
                              child: Text(
                                'Time (s)', // Rotated Y-axis title
                                style: TextStyle(
                                    fontSize: 16,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0, bottom: 8.0),
                              child: Text(
                                'Cold Stream Inlet Temperature',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Temperature (C)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16,),
                                  ),
                                ),
                                cosPoints.isNotEmpty ?
                                SizedBox(
                                  height: currentHeight/4,
                                  width: currentWidth/5,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 20,
                                      maxY: 70,
                                      minX: 0,//sinPoints.first.x,
                                      maxX: 100,//sinPoints.last.x,
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
                                        graphLine(tcFullPlot, Colors.blue),
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
                                ):
                                Container(),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0),
                              child: Text(
                                'Time (s)', // Rotated Y-axis title
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0, bottom: 8.0),
                              child: Text(
                                'Cold Stream Outlet Temperature',
                                style: TextStyle(
                                    fontSize: 20
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                const RotatedBox(
                                  quarterTurns: -1,
                                  child: Text(
                                    'Temperature (C)', // Rotated Y-axis title
                                    style: TextStyle(fontSize: 16,),
                                  ),
                                ),
                                cosPoints.isNotEmpty ?
                                SizedBox(
                                  height: currentHeight/4,
                                  width: currentWidth/5,
                                  child: LineChart(
                                    LineChartData(
                                      minY: 20,
                                      maxY: 70,
                                      minX: 0,//sinPoints.first.x,
                                      maxX: 100,//sinPoints.last.x,
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
                                        graphLine(tcOutletPlot, Colors.blue),
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
                                ) :
                                Container(),
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.only(top:8.0, bottom: 24.0),
                              child: Text(
                                'Time (s)', // Rotated Y-axis title
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    // TODO: implement dispose
    super.dispose();
  }
}
