import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class DataStore {
  double data;
  void set store(double l){
    this.data = l;
  }
  double get getData {
    return this.data;
  }
}

class MonitorData extends StatefulWidget {
  double temp, humid, light;
  MonitorData(this.temp, this.humid, this.light);
  double get getData {
    return this.temp;
  }
  @override
  _MonitorDataState createState() => _MonitorDataState(temp, humid, light);
}



class _MonitorDataState extends State<MonitorData>
    with SingleTickerProviderStateMixin {
  bool isLoading = false;
  DataStore sensorData;
  double temp = 3, humid = 4, light = 50;
  _MonitorDataState(this.temp, this.humid, this.light);
  AnimationController progressController;
  Animation<double> tempAnimation;
  Animation<double> humidityAnimation;
  Animation<double> lightAnimation;


  @override
  void initState() {
    super.initState();
    isLoading = true;
    //_DashboardInit(temp, humid, light);
  }
  

  _DashboardInit(double temp, double humid, double light) {
    progressController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 2000));

    tempAnimation =
    Tween<double>(begin: -40, end: temp).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    humidityAnimation =
    Tween<double>(begin: 0, end: humid).animate(progressController)
      ..addListener(() {
        setState(() {});
      });

    lightAnimation =
    Tween<double>(begin: 0, end: light).animate(progressController)
      ..addListener(() {
        setState(() {});
      });
    progressController.forward();
  }

  @override
  Widget build(BuildContext context) {
    //final myDataStore = MyDataStore();
    //dataController.stream.listen((event) {print('gia tri vua nap la $event'); });
    //dataController.stream.listen((event) { _DashboardInit(temp, humid, light);})
                return isLoading?
                Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: SfRadialGauge(
                  title: GaugeTitle(
                    text: 'Temperature'
                  ),
                  enableLoadingAnimation: true,
                  animationDuration: 4500,
                  axes: <RadialAxis>[
                    RadialAxis(minimum: -50, maximum: 100,
                    pointers: <GaugePointer>[
                      NeedlePointer(value: 2,
                      enableAnimation: true)
                    ],
                     ranges: <GaugeRange>[
                       GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                       GaugeRange(startValue: 50, endValue: 100, color: Colors.orange),
                       GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
                     ],
                      annotations: <GaugeAnnotation>[
                        GaugeAnnotation(widget: Text('C Degrees'),
                          positionFactor: 0.8,
                          angle: 90
                        ),
                      ]
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SfRadialGauge(
                  title: GaugeTitle(
                      text: 'Humidity'
                  ),
                  enableLoadingAnimation: true,
                  animationDuration: 4500,
                  axes: <RadialAxis>[
                    RadialAxis(minimum: 0, maximum: 100,
                        pointers: <GaugePointer>[
                          NeedlePointer(value: 2,
                              enableAnimation: true)
                        ],
                        ranges: <GaugeRange>[
                          GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                          GaugeRange(startValue: 50, endValue: 100, color: Colors.orange),
                          GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(widget: Text('Percent'),
                              positionFactor: 0.8,
                              angle: 90
                          ),
                        ]
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SfRadialGauge(
                  title: GaugeTitle(
                      text: 'Light Value'
                  ),
                  enableLoadingAnimation: true,
                  animationDuration: 4500,
                  axes: <RadialAxis>[
                    RadialAxis(minimum: 0, maximum: 500,
                        pointers: <GaugePointer>[
                          NeedlePointer(value: light,
                              enableAnimation: true)
                        ],
                        ranges: <GaugeRange>[
                          GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                          GaugeRange(startValue: 50, endValue: 100, color: Colors.orange),
                          GaugeRange(startValue: 100, endValue: 150, color: Colors.red),
                        ],
                        annotations: <GaugeAnnotation>[
                          GaugeAnnotation(widget: Text('Unit'),
                              positionFactor: 0.8,
                              angle: 90
                          ),
                        ]
                    ),
                  ],
                ),
              ),
             /* Column(
              children: <Widget>[
                Text('HUMIDITY',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
                ),
                CustomPaint(
                foregroundPainter:
                //CircleProgress(humid, true),
                CircleProgress1(humidityAnimation.value, false),
                child: Container(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Text('Humidity'),
                        Text(
                          '${humidityAnimation.value.toInt()}',
                          style: TextStyle(
                              fontSize: 45,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        Text(
                          '%',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),]),
              Column(
              children: <Widget> [
                Text('LIGHT VALUE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                ),
                CustomPaint(
                foregroundPainter:
                //CircleProgress(humid, true),
                CircleProgress2(lightAnimation.value, true),
                child: Container(
                  width: 150,
                  height: 150,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        //Text('Light'),
                        Text(
                          '${lightAnimation.value.toInt()}',
                          style: TextStyle(
                              fontSize: 45,
                              fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )])*/
            ],
          )
              : Text(
            'Loading...',
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          );
    }
}

