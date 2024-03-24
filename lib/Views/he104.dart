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
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Card(
                        elevation: 20,
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'EQUIPMENT CONTROL',
                                style: TextStyle(
                                    fontSize: 24
                                ),
                              ),
                              Divider(
                                height: 24,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [

                                ],
                              ),
                              SizedBox(height: 12,),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [

                                ],
                              ),
                              SizedBox(height: 28,),
                              Text(
                                'Equipment Status',
                                style: TextStyle(
                                    fontSize: 20
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
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [

                                ],
                              ),
                              const SizedBox(height: 12,),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [

                                ],
                              ),
                              const SizedBox(height: 12,),
                              const Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                mainAxisSize: MainAxisSize.max,
                                children: [

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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'HE104 HEAT CONTROL CHART',
                              style: TextStyle(
                                  fontSize: 24
                              ),
                            ),
                          ),
                          //const SizedBox(height: 24,),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/1.1,
                            width: currentWidth/3.5,
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
                      const SizedBox(width: 24,),
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Title 2',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          ),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/2.5,
                            width: currentWidth/5,
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
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Title 3',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          ),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/2.5,
                            width: currentWidth/5,
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
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Title 4',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          ),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/2.5,
                            width: currentWidth/5,
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
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Title 5',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          ),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/2.5,
                            width: currentWidth/5,
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
                      Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Title 6',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          ),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/2.5,
                            width: currentWidth/5,
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
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'Title 7',
                              style: TextStyle(
                                  fontSize: 20
                              ),
                            ),
                          ),
                          cosPoints.isNotEmpty ?
                          SizedBox(
                            height: currentHeight/2.5,
                            width: currentWidth/5,
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
