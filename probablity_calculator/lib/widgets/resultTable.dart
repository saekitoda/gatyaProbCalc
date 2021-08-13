import 'package:flutter/material.dart';

class ResultTable extends StatelessWidget {
  final double prob;
  final int tryNum;
  final Function calcProb;

  ResultTable(this.prob, this.tryNum, this.calcProb);

  @override
  Widget build(BuildContext context) {
    List<List<DataCell>> data = [];

    double maxProb = 0;
    double resultSum = 0;
    int maxAppear = 0;
    for (int appear = 0; appear <= tryNum; appear++) {
      double result = calcProb(prob, tryNum, appear);
      if (maxProb <= result) {
        maxProb = result;
        maxAppear = appear;
      }

      if (result < maxProb * 0.001 && maxAppear + 1 >= prob * tryNum) {
        if (data.length - maxAppear <= data.length / 2) {
          int dataRange = 2 * (data.length - maxAppear);
          data = data.sublist(data.length - dataRange);
        }
        break;
      }

      final List<DataCell> dataRow = [
        DataCell(Text(appear.toString())),
        DataCell(Text((result * 100).toStringAsFixed(2) + '%')),
        DataCell(Text(((1 - resultSum) * 100).toStringAsFixed(2) + '%'))
      ];

      resultSum += result;

      data.add(dataRow);
    }

    return DataTable(
      columns: const <DataColumn>[
        DataColumn(
          label: Text(
            '出現回数(n)',
          ),
        ),
        DataColumn(
          label: Text(
            '確率',
          ),
        ),
        DataColumn(
          label: Text(
            '確率(n回以上)',
          ),
        ),
      ],
      rows: <DataRow>[
        for (int i = 0; i < data.length; i++) DataRow(cells: data[i])
      ],
    );
  }
}
