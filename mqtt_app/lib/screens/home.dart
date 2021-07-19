import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';
import 'dart:convert';
import 'package:tung_mqtt_monitor_app/dialogs/send_messages.dart';
import 'package:tung_mqtt_monitor_app/models/messages.dart';
import 'package:tung_mqtt_monitor_app/components/rounded_button.dart';
import 'package:tung_mqtt_monitor_app/components/rounded_input_field.dart';
import 'package:tung_mqtt_monitor_app/constants.dart';
import 'package:tung_mqtt_monitor_app/screens/profile.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class User {
  String light;
  String temperature;
  String humidity;
  User(this.light, this.temperature, this.humidity);
  User.fromJson(Map<String, dynamic> json)
      : light = json['light'],
        temperature = json['temperature'],
        humidity = json['humidity'];
  Map<String, dynamic> toJson() => {
    'light': light,
    'temperature': temperature,
    'humidity': humidity,
  };
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  PageController _pageController;
  int _page = 0;
  String titleBar = 'MQTT Monitor';
  String broker = 'm14.cloudmqtt.com';
  int port = 12321;
  String username = 'bxpalvco';
  String passwd = 'UUILhS73phGV';
  String clientIdentifier = 'tung';
  /*String broker;
  int port;
  String username;
  String passwd;
  String clientIdentifier;*/

  MqttServerClient client;
  MqttConnectionState connectionState;
  //StreamController<double> dataController = new StreamController.broadcast();
  StreamSubscription subscription;

  String light = '2';
  String humid = '3';
  String temp = '4';

  TextEditingController brokerController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwdController = TextEditingController();
  TextEditingController identifierController = TextEditingController();
  TextEditingController topicController = TextEditingController();

  Set<String> topics = Set<String>();
  List<Message> messages = <Message>[];
  ScrollController messageController = ScrollController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //xác lập trạng thái icon kết nối
    IconData connectionStateIcon;
    switch (client?.connectionState) {
      case MqttConnectionState.connected:
        connectionStateIcon = Icons.cloud_done;
        break;
      case MqttConnectionState.disconnected:
        connectionStateIcon = Icons.cloud_off;
        break;
      case MqttConnectionState.connecting:
        connectionStateIcon = Icons.cloud_upload;
        break;
      case MqttConnectionState.disconnecting:
        connectionStateIcon = Icons.cloud_download;
        break;
      case MqttConnectionState.faulted:
        connectionStateIcon = Icons.error;
        break;
      default:
        connectionStateIcon = Icons.cloud_off;
    }
    //Tạo hoạt họa chuyển trang
    void navigationTapped(int page) {
      _pageController.animateToPage(page,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }

    //set trạng thái cho trang
    void onPageChanged(int page) {
      setState(() {
        this._page = page;
      });
    }

    return MaterialApp(
      home: Scaffold(
        drawer: Drawer(
            child: ListView(
              //mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                UserAccountsDrawerHeader(
                  accountName: Text('Tran Phuong Tung'),
                  accountEmail: Text('tung.tran0801@hcmut.edu.vn'),
                  currentAccountPicture: CircleAvatar(
                    foregroundImage: AssetImage('images/tung.png'),
                  ),
                  ),
                ListTile(
                  leading: Icon(Icons.assignment, color: kPrimaryColor),
                  title: Text('Project Detail',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: drawerInforTextColor,
                      fontSize: 18,
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_sharp, color: kPrimaryColor),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileScreen(),
                    ),
                  ),
                ),
              ],

            ),
        ),
        appBar: AppBar(
          backgroundColor: Colors.indigo,
          title: Row(
            //Hiển thị icon trạng thái kết nối
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(titleBar),
              SizedBox(
                width: 8.0,
              ),
              Icon(connectionStateIcon),
            ],
          ),
        ),
        floatingActionButton: _page == 2
            ? Builder(builder: (BuildContext context) {
          return FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<String>(
                    builder: (BuildContext context) =>
                        SendMessageDialog(client: client),
                    fullscreenDialog: true,
                  ));
            },
          );
        })
            : null,
        bottomNavigationBar: BottomNavigationBar(
          onTap: navigationTapped,
          currentIndex: _page,
          items: [
            BottomNavigationBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(Icons.cloud),
              title: Text('Broker'),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(Icons.playlist_add),
              title: Text('Subscriptions'),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(Icons.message),
              title: Text('Messages'),
            ),
            BottomNavigationBarItem(
              backgroundColor: Colors.indigo,
              icon: Icon(Icons.pie_chart),
              title: Text('Dashboard'),
            )
          ],
        ),
        body: PageView(
          controller: _pageController,
          onPageChanged: onPageChanged,
          children: <Widget>[
            _buildBrokerPage(connectionStateIcon),
            _buildSubscriptionsPage(),
            _buildMessagesPage(),
            //MonitorData(0, 0, double.tryParse(light)),
            _buildMonitorPage(),
            //MonitorData(double.tryParse(light)),
          ],
        ),
      ),
    );
  }

  ///page broker
  LayoutBuilder _buildBrokerPage(IconData connectionStateIcon) {
    Size size = MediaQuery.of(context).size;
    print('check broker');
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: viewportConstraints.maxHeight,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  RoundedInputField(
                    icon: Icons.add_moderator,
                    controller: brokerController,
                    hintText: "Your Broker",
                    onChanged: (value) => broker = value,
                  ),
                  SizedBox(height: 8.0,),
                  RoundedInputField(
                    icon: Icons.swap_horizontal_circle,
                    controller: portController,
                    hintText: "Your Port",
                    onChanged: (value) => port = int.tryParse(value),
                  ),
                  SizedBox(height: 8.0),
                  RoundedInputField(
                    icon: Icons.person,
                    controller: usernameController,
                    hintText: "Your User name",
                    onChanged: (value) => username = value,
                  ),
                  SizedBox(height: 8.0),
                  RoundedInputField(
                    icon: Icons.vpn_key,
                    controller: passwdController,
                    hintText: "Your Password",
                    onChanged: (value) => passwd = value,
                  ),
                  SizedBox(height: 8.0),
                  RoundedInputField(
                    icon: Icons.person_pin,
                    controller: identifierController,
                    hintText: "Your Client Identifier",
                    onChanged: (value) => clientIdentifier = value,
                  ),
                  SizedBox(height: 45.0),
                  RoundedButton(
                    width: size.width * 0.8,
                    fontSize: 16,
                    text:
                    client?.connectionState == MqttConnectionState.connected
                        ? 'Disconnect'
                        : 'Connect',
                    press: () {
                      if (brokerController.value.text.isNotEmpty) {
                        broker = brokerController.value.text;
                      }

                      port = int.tryParse(portController.value.text);
                      if (port == null) {
                        port = 12321;
                      }
                      if (usernameController.value.text.isNotEmpty) {
                        username = usernameController.value.text;
                      }
                      if (passwdController.value.text.isNotEmpty) {
                        passwd = passwdController.value.text;
                      }

                      clientIdentifier = identifierController.value.text;
                      if (clientIdentifier.isEmpty) {
                        var random = new Random();
                        clientIdentifier = 'tung_' + random.nextInt(100).toString();
                      }

                      if (client?.connectionState == MqttConnectionState.connected) {
                        _disconnect();
                      } else {
                        _connect();
                      }
                    },
                  ),
                ],
              ),
            ),
          );}
    );
  }

  /// page gửi message
  Column _buildMessagesPage() {
    Size size = MediaQuery.of(context).size;
    return Column(
      children: <Widget>[
        Expanded(
          child: ListView(
            controller: messageController,
            children: _buildMessageList(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: RoundedButton(
            text: 'CLEAR',
            fontSize: 16,
            width: size.width * 0.5,
            press: () {
              setState(() {
                messages.clear();
              });
            },
          ),
        )
      ],
    );
  }

  /// page tạo topic, phải tạo topic ở page này thì mới gửi message được
  Column _buildSubscriptionsPage() {
    print('check topic');
    Size size = MediaQuery.of(context).size;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /*SizedBox(
              width: 200.0,
              child: TextField(
                controller: topicController,
                decoration: InputDecoration(hintText: 'Please enter a topic'),
              ),
            ),*/
            RoundedInputField(
              controller: topicController,
              hintText: "Please enter a topic",
              //onChanged: (value) => passwd = value,
            ),
            //SizedBox(width: 8.0),
            RoundedButton(
              width: size.width * 0.8,
              text: 'ADD TOPIC',
              fontSize: 16,
              press: () {
                _subscribeToTopic(topicController.value.text);
              },
            ),
          ],
        ),
        SizedBox(height: 30.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.start,
          children: _buildTopicList(),
        )
      ],
    );
  }

  /// monitor page
  Column _buildMonitorPage(){
    print('check update monitor');
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Expanded(
          child: SfRadialGauge(
            title: GaugeTitle(
                text: 'Temperature',
                textStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red
                )
            ),
            enableLoadingAnimation: true,
            animationDuration: 4500,
            axes: <RadialAxis>[
              RadialAxis(minimum: 0, maximum: 50,
                  pointers: <GaugePointer>[
                    NeedlePointer(value: double.tryParse(temp),
                        enableAnimation: true)
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 20, color: Colors.blue),
                    GaugeRange(startValue: 20, endValue: 30, color: Colors.green),
                    GaugeRange(startValue: 30, endValue: 50, color: Colors.orange),
                  ],
                  annotations: <GaugeAnnotation>[
                    GaugeAnnotation(widget: Text('Celsius'),
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
                text: 'Humidity',
                textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green
                )
            ),
            enableLoadingAnimation: true,
            animationDuration: 4500,
            axes: <RadialAxis>[
              RadialAxis(minimum: 0, maximum: 100,
                  pointers: <GaugePointer>[
                    NeedlePointer(value: double.tryParse(humid),
                        enableAnimation: true)
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 30, color: Colors.orange),
                    GaugeRange(startValue: 30, endValue: 70, color: Colors.green),
                    GaugeRange(startValue: 70, endValue: 100, color: Colors.blue),
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
                text: 'Light Value',
                textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800]
                )
            ),
            enableLoadingAnimation: true,
            animationDuration: 4500,
            axes: <RadialAxis>[
              RadialAxis(minimum: 0, maximum: 900,
                  pointers: <GaugePointer>[
                    NeedlePointer(value: double.tryParse(light),
                        enableAnimation: true)
                  ],
                  ranges: <GaugeRange>[
                    GaugeRange(startValue: 0, endValue: 300, color: Colors.green),
                    GaugeRange(startValue: 300, endValue: 600, color: Colors.orange),
                    GaugeRange(startValue: 600, endValue: 900, color: Colors.red),
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
      ],
    );
  }
  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    _pageController = PageController();
    super.initState();
  }

  List<Widget> _buildMessageList() {
    return messages
        .map((Message message) => Card(
      color: backgroundColor,
      child: ListTile(
        trailing: CircleAvatar(
            radius: 14.0,
            backgroundColor: Theme.of(context).accentColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'QoS',
                  style: TextStyle(fontSize: 8.0),
                ),
                /*Text(
                  message.qos.index.toString(),
                  style: TextStyle(fontSize: 8.0),
                ),*/
              ],
            )),
        title: Text(message.topic),
        subtitle: Text(message.message,
        style: TextStyle(color: kPrimaryColor),
        ),
        dense: true,
      ),
    ))
        .toList()
        .reversed
        .toList();
  }

  List<Widget> _buildTopicList() {
    // Sort topics
    final List<String> sortedTopics = topics.toList()
      ..sort((String a, String b) {
        return compareNatural(a, b);
      });
    return sortedTopics
        .map((String topic) => Chip(
      backgroundColor: Colors.blueGrey,
      label: Text(topic,
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onDeleted: () {
        _unsubscribeFromTopic(topic);
      },
    ))
        .toList();
  }

  void _connect() async {
    /// First create a client, the client is constructed with a broker name, client identifier
    /// and port if needed. The client identifier (short ClientId) is an identifier of each MQTT
    /// client connecting to a MQTT broker. As the word identifier already suggests, it should be unique per broker.
    /// The broker uses it for identifying the client and the current state of the client. If you don’t need a state
    /// to be hold by the broker, in MQTT 3.1.1 you can set an empty ClientId, which results in a connection without any state.
    /// A condition is that clean session connect flag is true, otherwise the connection will be rejected.
    /// The client identifier can be a maximum length of 23 characters. If a port is not specified the standard port
    /// of 1883 is used.
    /// If you want to use websockets rather than TCP see below.
    ///
    client = MqttServerClient(broker, '');
    client.port = port;

    /// A websocket URL must start with ws:// or wss:// or Dart will throw an exception, consult your websocket MQTT broker
    /// for details.
    /// To use websockets add the following lines -:
    /// client.useWebSocket = true;
    /// client.port = 80;  ( or whatever your WS port is)
    /// Note do not set the secure flag if you are using wss, the secure flags is for TCP sockets only.

    /// Set logging on if needed, defaults to off
    client.logging(on: true);

    /// If you intend to use a keep alive value in your connect message that is not the default(60s)
    /// you must set it here
    client.keepAlivePeriod = 30;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Create a connection message to use or use the default one. The default one sets the
    /// client identifier, any supplied username/password, the default keepalive interval(60s)
    /// and clean session, an example of a specific one below.
    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
    // Must agree with the keep alive set above or not set
        .startClean() // Non persistent session for testing
        .keepAliveFor(30)
    // If you set this you must set a will message
        .withWillTopic('test/test')
        .withWillMessage('tung message test')
        .withWillQos(MqttQos.atMostOnce);
    print('MQTT client connecting....');
    client.connectionMessage = connMess;

    /// Connect the client, any errors here are communicated by raising of the appropriate exception. Note
    /// in some circumstances the broker will just disconnect us, see the spec about this, we however will
    /// never send malformed messages.

    try {
      await client.connect(username, passwd);
    } catch (e) {
      print(e);
      _disconnect();
    }

    /// Check if we are connected
    if (client.connectionState == MqttConnectionState.connected) {
      print('MQTT client connected');
      setState(() {
        connectionState = client.connectionState;
      });
    } else {
      print('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client.connectionState}');
      _disconnect();
    }

    /// The client has a change notifier object(see the Observable class) which we then listen to to get
    /// notifications of published updates to each subscribed topic.
    subscription = client.updates.listen(_onMessage);
  }

  void _disconnect() {
    client.disconnect();
    _onDisconnected();
  }

  void _onDisconnected() {
    setState(() {
      topics.clear();
      connectionState = client.connectionState;
      client = null;
      subscription.cancel();
      subscription = null;
    });
    print('MQTT client disconnected');
  }

  void _onMessage(List<MqttReceivedMessage> event) {
    //print("do dai cua event: ${event.length}");
    final MqttPublishMessage recMess = event[0].payload as MqttPublishMessage;
    String message =
    MqttPublishPayload.bytesToStringAsString(recMess.payload.message) ?? " ";
    /// The above may seem a little convoluted for users only interested in the
    /// payload,some users however may be interested in the received publish message,
    /// lets not constrain ourselves yet until the package has been in the wild
    /// for a while.
    /// The payload is a byte buffer, this will be specific to the topic
    print('MQTT message: topic is <${event[0].topic}>, '
        'payload is <-- ${message} -->');
    print(client.connectionState);
    setState(() {
      messages.add(Message(
        topic: event[0].topic,
        message: message,
        qos: recMess.payload.header.qos,
      ));
      //_light = double.parse(message);
      Map<String, dynamic> userMap = jsonDecode(message);
      User user = User.fromJson(userMap);

      /*if(user.light == "")
        {
          humid = user.humidity;
          temp = user.temperature;
        }
      else light = user.light;*/

      light = user.light ?? light;
      humid = user.humidity ?? humid;
      temp = user.temperature ?? temp;

      print('Stream nay luu ${subscription}');
      print('client  nay la $client');
      //print('Stream trong class nay la ${a.dataStream}');
      //print(Value(double.tryParse(light)));
      /*try {
        messageController.animateTo(
          0.0,
          duration: Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      } catch (_) {
        // ScrollController not attached to any scroll views.
      }*/
    });
  }

  void _subscribeToTopic(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      setState(() {
        if (topics.add(topic.trim())) {
          print('Subscribing to ${topic.trim()}');
          client.subscribe(topic, MqttQos.exactlyOnce);
        }
      });
    }
  }

  void _unsubscribeFromTopic(String topic) {
    if (connectionState == MqttConnectionState.connected) {
      setState(() {
        if (topics.remove(topic.trim())) {
          print('Unsubscribing from ${topic.trim()}');
          client.unsubscribe(topic);
        }
      });
    }
  }
}
