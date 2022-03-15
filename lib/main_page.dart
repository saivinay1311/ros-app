import 'package:controller/map_viewer.dart';
import 'package:controller/navigationDrawer.dart';
import 'package:controller/pose_publisher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:roslib/roslib.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Ros ros = Ros(url: 'ws://10.0.2.2:9090');
  late Topic chatter;
  @override
  void initState() {
    ros;
    chatter = Topic(
        ros: ros,
        name: '/robot_0/pose',
        type: "geometry_msgs/PoseWithCovarianceStamped",
        reconnectOnClose: true,
        queueLength: 10,
        queueSize: 10);
    super.initState();
  }

  void initConnection() async {
    ros.connect();
    await chatter.subscribe();
    setState(() {});
  }

  void destroyConnection() async {
    await chatter.unsubscribe();
    await ros.close();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        drawer: NavigationDrawer(),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Colors.black, Colors.grey])),
            child: StreamBuilder<Object>(
              stream: ros.statusStream,
              builder: (context, snapshot) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(0),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 25,
                        ),
                        StreamBuilder(
                            stream: chatter.subscription,
                            builder: (context, snapshot2) {
                              if (snapshot2.hasData) {
                                if (snapshot2.data != null) {
                                  var pose = (((snapshot2.data as Map)['msg']
                                      as Map)['pose'] as Map)['pose'];
                                  var x_cor =
                                      ((pose as Map)['position'] as Map)['x'];
                                  var y_cor =
                                      ((pose as Map)['position'] as Map)['y'];
                                  // return Text(
                                  //     '${((pose as Map)['position'] as Map)['x']}');
                                  return Expanded(
                                      child: Center(
                                          child: MapViewer(y_cor, x_cor)));
                                } else {
                                  return const Text("Data not there");
                                }
                              }
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 100,
                                    ),
                                    SizedBox(
                                      height:
                                          MediaQuery.of(context).size.height *
                                              .3,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.blueGrey[200],
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Container(
                                          padding: EdgeInsets.all(20),
                                          child: Column(
                                            children: [
                                              Text(
                                                "Master Node URL",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Form(
                                                  child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                style: const TextStyle(
                                                    color: Colors.white),
                                                cursorColor: Colors.white,
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.white),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)),
                                                  labelStyle: const TextStyle(
                                                      color: Colors.black),
                                                  focusedBorder:
                                                      const OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide(
                                                                  color: Colors
                                                                      .white)),
                                                  fillColor: Colors.white,
                                                  labelText: "Master IP",
                                                ),
                                              )),
                                              const SizedBox(
                                                height: 6,
                                              ),
                                              Form(
                                                  child: TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                style: const TextStyle(
                                                    color: Colors.black),
                                                cursorColor: Colors.white,
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .white),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10)),
                                                    labelStyle: const TextStyle(
                                                        color: Colors.black),
                                                    focusedBorder:
                                                        const OutlineInputBorder(
                                                            borderSide:
                                                                BorderSide(
                                                                    color: Colors
                                                                        .white)),
                                                    fillColor: Colors.white,
                                                    labelText: "Port"),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    )
                                  ],
                                ),
                              );
                            }),
                        ActionChip(
                            backgroundColor: snapshot.data == Status.CONNECTED
                                ? Colors.green[300]
                                : Colors.red,
                            label: Icon(Icons.power_settings_new_rounded),
                            onPressed: () {
                              if (snapshot.data != Status.CONNECTED) {
                                this.initConnection();
                              } else {
                                this.destroyConnection();
                              }
                            }),
                        // Container(
                        //   decoration: BoxDecoration(
                        //       borderRadius: BorderRadius.circular(20),
                        //       gradient: const LinearGradient(
                        //           begin: Alignment.topLeft,
                        //           end: Alignment.bottomRight,
                        //           colors: [Colors.redAccent, Colors.red])),
                        //   child: snapshot.data == Status.CONNECTED
                        //       ? IconButton(
                        //           onPressed: () {
                        //             if (snapshot.data == Status.CONNECTED) {
                        //               this.destroyConnection();
                        //             }
                        //             print("powering on");
                        //           },
                        //           icon: const Icon(
                        //               Icons.power_settings_new_sharp),
                        //           color: Colors.green,
                        //         )
                        //       : TextButton(
                        //           onPressed: () {
                        //             if (snapshot.data != Status.CONNECTED) {
                        //               this.initConnection();
                        //               print("powering off");
                        //             }
                        //           },
                        //           child: Container(
                        //               child: Text(
                        //             "Connect",
                        //             style: TextStyle(color: Colors.black),
                        //           )),
                        //         ),
                        // ),
                        const SizedBox(
                          height: 6,
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ));
  }
}
