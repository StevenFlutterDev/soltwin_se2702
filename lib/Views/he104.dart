import 'package:flutter/material.dart';
import 'package:soltwin_se2702/CustomWidget/custom_app_bar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:soltwin_se2702/Services/rest_api.dart';

class HE104 extends StatefulWidget {
  const HE104({Key? key}) : super(key: key);

  @override
  State<HE104> createState() => _HE104State();
}

class _HE104State extends State<HE104> {
  final cosPoints = <FlSpot>[];
  final APIServices apiServices = APIServices();
  String modelMode = 'CO-Current';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      cosPoints.add(const FlSpot(0, 0));
    });
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
                        child: Image.asset(
                          'assets/images/HE104.png',
                          filterQuality: FilterQuality.high,
                          fit: BoxFit.fill,
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
                                        bool result = await apiServices.matlabControl('he104', 'co', 'run');
                                        if(result){
                                          setState(() {
                                            modelMode = 'CO-Current';
                                          });
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
                                        bool result = await apiServices.matlabControl('he104', 'counter', 'run');
                                        if(result){
                                          setState(() {
                                            modelMode = 'Counter Current';
                                          });
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
                                        await apiServices.matlabControl('he104', 'co', 'start');
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
                                        await apiServices.matlabControl('he104', 'co', 'stop');
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
            ],
          ),
        ),
      ),
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
    // TODO: implement dispose
    super.dispose();
  }
}
