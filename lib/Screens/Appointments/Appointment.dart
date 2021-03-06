import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
// import 'package:flutter_holo_date_picker/flutter_holo_date_picker.dart';
import 'package:getcure_doctor/Database/PatientsTable.dart';
// import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:getcure_doctor/Helpers/Network/Requesthttp.dart';
import 'package:getcure_doctor/Helpers/AppConfig/colors.dart';
import 'package:getcure_doctor/Logic/GenerateTokens.dart';
// import 'package:getcure_doctor/Models/ClinicDoctorModel.dart';
import 'package:getcure_doctor/Models/DoctorLogin.dart';
// import 'package:getcure_doctor/Models/ClinicDoctorModel.dart' as cdm;
import 'package:getcure_doctor/Widgets/Drawer.dart';
import 'package:getcure_doctor/Widgets/dataTable.dart';
import 'package:getcure_doctor/Widgets/slots.dart';
// import 'package:getcure_doctor/Widgets/slots.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:getcure_doctor/Database/TokenTable.dart';

class Appointments extends StatefulWidget {
  final TokenDB database;
  final PatientsDB patientDatabase;
  const Appointments({this.database, this.patientDatabase});
  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  List<ClinicDoctor> doc = [ClinicDoctor(clinic: Clinic(name: ""))];
  DoctorLogin docUser;
  Token tokens;
  String query = '';

  Timer T;
  List<ClinicDoctor> dropdown = [];
  getdoctors() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String doctors = pref.getString('dresponse');
    docUser = DoctorLogin.fromJson(json.decode(doctors));
    for (var i in docUser.data.clinicDoctor) {
      setState(() {
        dropdown.add(i);
      });
    }
    print(dropdown);
    // dropdownvalue = frontDeskUser.data.clinicDoctors[0];
    // for (int i = 0; i < docUser.data.length; i++) {
    //   setState(() {
    //     doc.add(docUser.data[i]);
    //   });
    // }
  }

  GenerateTokens token = GenerateTokens();

  generate(TokenDB database) {
    BuildContext context;
    token.tokens = GeneratedTokens(
        fees: 100,
        doctorid: docUser.data.id,
        date: datePicked,
        clinicId: _selecteddoc.clinicId,
        // starttime: DateTime.parse("10:00:00"), //timee(datePicked, 'startTime'),
        // startbreaktime:
        //     DateTime.parse("13:00:00"), // timee(datePicked, 'breakStart'),
        // endbreaktime:
        //     DateTime.parse("14:00:00"), //timee(datePicked, 'breakEnd'),
        // endtime: DateTime.parse("20:00:00"), //timee(datePicked, 'endTime'),
        slots: timee(datePicked).slots,
        nfp: 15);
    token.generateToken(context, database);
  }

  DoctorTimings timee(DateTime selecteddate) {
    dynamic s = DateFormat('EEEE').format(selecteddate);
    DateTime p;
    s = s.toString().toUpperCase();
    // return _selecteddoc.doctorTimings.where((element) => element.day.toUpperCase().compareTo(s)==0);
    for (var i in _selecteddoc.doctorTimings) {
      // print(i.day);
      if (i.day.toUpperCase().compareTo(s) == 0) {
        // print(i.day+"hello how are you");
        return i;
      }
    }
    // return _selecteddoc.doctorTimings[0];
    // for (var i in _selecteddoc.doctorTimings) {
    //   var o;
    //   if (s.toString().compareTo(i.day.toUpperCase()) == 0) {
    //     switch (t) {
    //       case "startTime":
    //         o = i.startTime;
    //         break;
    //       case "endTime":
    //         o = i.endTime;
    //         break;
    //       case "breakStart":
    //         o = i.breakStart;
    //         break;
    //       default:
    //         o = i.breakEnd;
    //     }
    //     String e = DateFormat("yyyy-MM-dd").format(selecteddate) + " " + o;
    //     p = DateTime.parse(e);
    //   }
    // }
    // return p;
  }

  var countRows;
  var countoncall;
  var countonfront;
  var countOnline;
  var countPresent;

  @override
  void initState() {
    // clinicDoctors();
    getdoctors();
    // const oneSec = const Duration(seconds: 5);
    // new Timer.periodic(oneSec, (Timer t) => tokenfetch());
    // counting(widget.database);
    super.initState();
    // docId = tokens.doctorid;
  }

  int docId = 0;
  @override
  void dispose() {
    T.cancel();
    super.dispose();
  }

  // tokenfetch() async {
  //   // print(dropdownvalue.id);
  //   dynamic li = await widget.database.getAllTasks(datePicked);
  //   if (li.length != 0) {
  //     getTokens(datePicked, widget.database);
  //   } else {
  //     generate(widget.database);
  //   }
  // }

  void counting(TokenDB x) async {
    countRows = await x.getcount();
    print("counting booked= " + countRows.toString());
    countoncall = await x.getcountoncall();
    print("counting on call booked= " + countoncall.toString());
    countonfront = await x.getcountonfront();
    countOnline = await x.getcountOnline();
    print("count online= " + countOnline.toString());
    countPresent = await x.getcountPresent();
    setState(() {
      countRows = countRows;
      countoncall = countoncall;
      countonfront = countonfront;
      countOnline = countOnline;
      countPresent = countPresent;
    });
  }

  ClinicDoctor _selecteddoc;
  //ClinicDoctor dropdownvalue = ClinicDoctor(doctorName: '');
  var datePicked = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(
          name: " dsjn",
          // clinicid: _selecteddoc.doctorId.toString(),
          docId: docId),
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: orangep,
        ),
        backgroundColor: white,
        title: Center(
          child: DropdownButton(
            //   value: dropdownvalue == null ? null : dropdownvalue.doctorName,
            value: _selecteddoc,
            hint: Text('Select Clinic'),
            // iconSize: 24,
            elevation: 16,
            style: TextStyle(color: black),
            // underline: Container(
            //   height: 2,
            //   color: grey,
            // ),
            onChanged: (newValue) {
              setState(() {
                _selecteddoc = newValue;
              });
            },
            items:
                //     doc.map<DropdownMenuItem<String>>((ClinicDoctor value) {
                //   return DropdownMenuItem<String>(
                //     value: value.doctorName,
                //     child: Text(value.doctorName),
                //   );
                // }
                dropdown.map((ClinicDoctor val) {
              return DropdownMenuItem(
                child: Text(val.clinic.name),
                value: val,
              );
            }).toList(),
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.chat,
              color: pcolor,
              size: 30,
            ),
            onPressed: () async {
              var res = await widget.patientDatabase.deleteallTask();
            },
          ),
        ],
      ),
      body: Builder(builder: (BuildContext context) {
        return ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 80.0,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                      top: 17.0,
                      left: 77.0,
                      child: Container(
                        height: 30,
                        width: 200,
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: orangep, width: 2.0)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 5.0, right: 5),
                          child: Center(
                              child: Text(
                            'Dr.' +
                                (_selecteddoc == null
                                    ? " "
                                    : _selecteddoc.doctorName),
                            style: TextStyle(color: black, fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                          )),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 38.0,
                      child: Container(
                        height: 75,
                        width: 75,
                        decoration: BoxDecoration(
                            color: white,
                            borderRadius: BorderRadius.circular(50),
                            border: Border.all(color: orangep)),
                        child: Center(
                            child: Icon(
                          Icons.account_circle,
                          size: 70,
                        )),
                      ),
                    ),
                    Positioned(
                      top: 5.0,
                      left: MediaQuery.of(context).size.width - 120,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(9.0),
                            child: GestureDetector(
                              onTap: () async {
                                var selected =
                                    await DatePicker.showSimpleDatePicker(
                                  context,
                                  initialDate: datePicked,
                                  firstDate: DateTime.now(),
                                  dateFormat: "dd-MMMM-yyyy",
                                  locale: DateTimePickerLocale.en_us,
                                  looping: true,
                                );
                                selected != null
                                    ? setState(() {
                                        datePicked = selected;
                                      })
                                    : setState(() {
                                        datePicked = datePicked;
                                      });
                              },
                              child: Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                      color: white,
                                      borderRadius: BorderRadius.circular(20)),
                                  child: Icon(
                                    Icons.calendar_today,
                                    color: pcolor,
                                  )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (widget.database != null) {
                                widget.database.updateData(
                                    tokens.copyWith(shift: false), " ");
                                // generate(widget.database);
                              }
                            },
                            child: Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                    color: white,
                                    borderRadius: BorderRadius.circular(20)),
                                child: Icon(
                                  Icons.watch_later,
                                  color: pcolor,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 7,
                      left: 7,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                              '${DateFormat.yMMMd().format(datePicked).toString()}'),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 280,
              child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          // IconBuilder(
                          //   EvilIcons.calendar,
                          //   countRows,
                          //   'Booked',
                          // ),
                          // IconBuilder(
                          //   EvilIcons.check,
                          //   500,
                          //   'Completed',
                          // ),
                          // IconBuilder(
                          //   MaterialCommunityIcons.web,
                          //   countOnline,
                          //   'Online',
                          // ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          // IconBuilder(
                          //   MaterialCommunityIcons.deskphone,
                          //   countonfront,
                          //   'Fornt Desk',
                          // ),
                          // IconBuilder(
                          //   SimpleLineIcons.call_end,
                          //   countoncall,
                          //   'On Call',
                          // ),
                          // IconBuilder(
                          //   SimpleLineIcons.user,
                          //   countPresent,
                          //   'Present',
                          // ),
                        ],
                      ),
                    ],
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text('Available Tokens',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                IconButton(
                    icon: Icon(Icons.file_download),
                    onPressed: () async {
                      print(datePicked);
                      dynamic li = await widget.database
                          .getAllTasks(datePicked, _selecteddoc.clinicId);
                      if (li.length == 0) {
                        print("no token generated");
                        generate(widget.database);
                      } else {
                        getTokens(datePicked, widget.database);
                      }
                    }),
                IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => widget.database.deleteallTask()),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                  height: 80,
                  color: orangep,
                  child: _buildTaskList(
                      context,
                      datePicked,
                      counting,
                      widget.patientDatabase,
                      _selecteddoc == null
                          ? 0
                          : _selecteddoc.clinicId)),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width * .9,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'search record',
                      border: OutlineInputBorder(),
                      icon: Icon(Icons.search)),
                  onChanged: (val) {
                    setState(() {
                      query = val;
                    });
                  },
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TokenTable(count: counting, query: query),
              ),
            )
          ],
        );
      }),
    );
  }
}

StreamBuilder<List<Token>> _buildTaskList(
    BuildContext context,
    DateTime datePicked,
    Function counting,
    PatientsDB patientDatabase,
    int clinicId) {
  final database = Provider.of<TokenDB>(context);
  return StreamBuilder(
    stream: database.watchondate(datePicked, clinicId),
    builder: (context, AsyncSnapshot<List<Token>> snapshot) {
      final tasks = snapshot.data ?? List();
      return ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tasks.length,
        itemBuilder: (_, index) {
          final itemTask = tasks[index];
          return SlotsWidget(
            itemTask: itemTask,
            database: database,
            count: counting,
            patientDatabase: patientDatabase,
          );
        },
      );
    },
  );
}
