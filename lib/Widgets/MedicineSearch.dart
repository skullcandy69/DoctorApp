import 'package:flutter/material.dart';
import 'package:getcure_doctor/Database/MedicinesTable.dart';
import 'package:getcure_doctor/Database/PatientsVisitTable.dart';
import 'package:getcure_doctor/Helpers/AppConfig/colors.dart';
import 'package:getcure_doctor/Models/PatientsVisitTableModels.dart';
import 'package:getcure_doctor/Widgets/AddMedicine.dart';
import 'package:provider/provider.dart';

class MedicineSearch extends StatefulWidget {
  final String pId;
  final int docId;
  final VoidCallback fun;
  final String disease;
  MedicineSearch({Key key, this.pId, this.docId, this.disease, this.fun})
      : super(key: key);

  @override
  _MedicineSearchState createState() => _MedicineSearchState();
}

class _MedicineSearchState extends State<MedicineSearch>
    with SingleTickerProviderStateMixin {
  String query = '';
  TabController tabController;

  @override
  void initState() {
    super.initState();
    setState(() {
      tabController = TabController(length: 2, vsync: this);
    });
  }

  @override
  Widget build(BuildContext context) {
    final med = Provider.of<MedicinesDB>(context);
    final patientsVisit = Provider.of<PatientsVisitDB>(context);
    return SingleChildScrollView(
      child: AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Search Medicine"),
            InkWell(
                child: Icon(Icons.cancel), onTap: () => Navigator.pop(context))
          ],
        ),
        actions: <Widget>[
          Stack(
            // fit: StackFit.expand,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      color: Colors.green[50],
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: TextField(
                        decoration: InputDecoration(
                            fillColor: Colors.green[100],
                            labelText: 'search',
                            labelStyle: TextStyle(color: blue),
                            border: InputBorder.none),
                        onChanged: (val) {
                          setState(() {
                            query = val;
                          });
                        },
                      ),
                    ),
                    TabBar(
                      controller: tabController,
                      tabs: <Tab>[
                        Tab(
                          text: 'Most Prescribed',
                        ),
                        Tab(
                          text: 'Category View',
                        ),
                      ],
                      labelColor: black,
                      isScrollable: true,
                    ),
                    DefaultTabController(
                        length: 2,
                        // initialIndex: 0,
                        child: Flexible(
                          fit: FlexFit.loose,
                          child:
                              TabBarView(controller: tabController, children: [
                            _buildTaskList(
                                context, query, med, patientsVisit, widget.pId),
                            Container()
                          ]),
                        )),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddMedicine(
                          docId: widget.docId,
                          pId: widget.pId,
                        );
                      },
                    );
                  },
                  child: Icon(
                    Icons.add,
                    color: white,
                    size: 30,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  StreamBuilder<List<Medicine>> _buildTaskList(BuildContext context,
      String query, MedicinesDB database, PatientsVisitDB pv, String pId) {
    return StreamBuilder(
      stream: database.watchAllTask(query),
      builder: (context, AsyncSnapshot<List<Medicine>> snapshot) {
        print(query);
        final tasks = snapshot.data ?? List();
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          width: MediaQuery.of(context).size.width * 0.6,
          child: ListView.separated(
            separatorBuilder: (_, index) {
              return Divider();
            },
            scrollDirection: Axis.vertical,
            itemCount: tasks.length,
            shrinkWrap: true,
            itemBuilder: (_, index) {
              final itemTask = tasks[index];
              return GestureDetector(
                onTap: () async {
                  // List<BriefHistoryData> bhd = [
                  //   BriefHistoryData(
                  //       date: DateTime.now().toString(),
                  //       title: itemTask.title,
                  //       visibleTill: itemTask.visibilityPeriod.toString())
                  // ];
                  // BriefHistorygenerated bh = BriefHistorygenerated(data: bhd);
                  PrescribedMedicines pm = PrescribedMedicines(
                      title: itemTask.title,
                      direction: itemTask.defaultDirection,
                      dose: itemTask.defaultDose,
                      duration: itemTask.defaultDuration,
                      frequency: itemTask.defaultFrequency,
                      medicineId: itemTask.id,
                      route: itemTask.defaultRoute,
                      unit: itemTask.defaultUnit);
                  var p = await pv.checkPatient(pId);
                  pv.updateMedication(p[0], widget.disease, pm);
                  Navigator.pop(context);
                    widget.fun();
                },
                child: ListTile(
                  // contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(itemTask.title),
                  trailing: Text(itemTask.salt),
                  subtitle: Text(itemTask.interactionDrugs +
                      " " +
                      itemTask.defaultFrequency),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
