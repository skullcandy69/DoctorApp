import 'package:flutter/cupertino.dart';
import 'package:getcure_doctor/Database/TokenTable.dart';
import 'package:getcure_doctor/Helpers/Network/Requesthttp.dart';
import 'package:getcure_doctor/Models/DoctorLogin.dart';
import 'package:intl/intl.dart';

class GeneratedTokens {
  final int doctorid;
  final int clinicId;
  final DateTime date;
  final DateTime starttime;
  final DateTime endtime;
  final DateTime startbreaktime;
  final DateTime endbreaktime;
  final int nfp;
  final List<Slots> slots;
  final int fees;
  GeneratedTokens(
      {this.fees,
      this.doctorid,
      this.clinicId,
      this.date,
      this.slots,
      this.starttime,
      this.endtime,
      this.startbreaktime,
      this.endbreaktime,
      this.nfp});
}

class GenerateTokens {
  GeneratedTokens tokens;
  dynamic hours;

  generateToken(BuildContext context, TokenDB database) {
    // if(database.tokens.shift!=null){
    //   hours=(tokens.startbreaktime.hour - tokens.starttime.hour).abs();
    // }else{
    //   hours=(tokens.endbreaktime.hour - tokens.endtime.hour).abs();
    // }
    // hours = (tokens.startbreaktime.hour - tokens.starttime.hour).abs() +
    //     (tokens.endbreaktime.hour - tokens.endtime.hour).abs();
    // dynamic interval = int.parse((60 / tokens.nfp).ceil().toString());
    // print("Hours of time = " + hours.toString());
    // print(interval);

    DateTime st;
    DateTime et;
    int tno = 1;
    for (var i in tokens.slots) {
      st = DateTime.parse(
          DateFormat('yyyy-MM-dd').format(tokens.date).toString() +
              " " +
              i.startTime);
      et = DateTime.parse(
          DateFormat('yyyy-MM-dd').format(tokens.date).toString() +
              " " +
              i.endTime);
      int hours = et.hour - st.hour;
      dynamic interval =
          int.parse(((hours * 60) / i.noOfPatients).ceil().toString());
      for (int j = 0; j < i.noOfPatients; j++) {
        final token = Token(
          fees: tokens.fees,
          clinicid: tokens.clinicId,
          tokenno: tno,
          doctorid: tokens.doctorid,
          tokentime: st.add(Duration(minutes: interval)),
        );
        st = st.add(Duration(minutes: interval));
        database.insertTask(token);
        tno++;
      }
    }
    // for (int i = 1; i <= tokens.nfp * hours; i++) {
    //   final token = Token(
    //     fees: tokens.fees,
    //     tokenno: i,
    //     doctorid: tokens.doctorid,
    //     tokentime: st.add(Duration(minutes: interval)),
    //   );
    //   st = st.add(Duration(minutes: interval));
    //   database.insertTask(token);
    // }
    // getTokens(tokens.date, database);
  }
}
