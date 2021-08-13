/// Example of a simple line chart.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ResultGraph extends StatelessWidget {
  final List<charts.Series<dynamic, num>> seriesList;
  final bool? animate;

  ResultGraph(this.seriesList, {this.animate});

  /// Creates a [LineChart] with sample data and no transition.
  factory ResultGraph.withSampleData(
      double prob, int tryNum, Function calcProb) {
    return new ResultGraph(
      _createSampleData(prob, tryNum, calcProb),
      // Disable animations for image tests.
      animate: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return new charts.LineChart(
      seriesList,
      animate: animate,
      primaryMeasureAxis: new charts.NumericAxisSpec(
          tickProviderSpec: new charts.BasicNumericTickProviderSpec(
              dataIsInWholeNumbers: false)),
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<LinearSales, double>> _createSampleData(
      double prob, int tryNum, Function calcProb) {
    List<LinearSales> data = [];
    double maxProb = 0;
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

      LinearSales calcData = new LinearSales(appear, result);
      data.add(calcData);
    }

    return [
      new charts.Series<LinearSales, double>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (LinearSales sales, _) => sales.year.toDouble(),
        measureFn: (LinearSales sales, _) => sales.sales,
        data: data,
      )
    ];
  }
}

/// Sample linear data type.
class LinearSales {
  final int year;
  final double sales;

  LinearSales(this.year, this.sales);
}
