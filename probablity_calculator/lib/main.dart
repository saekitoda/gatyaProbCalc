import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/resultGraph.dart';
import 'widgets/resultTable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Probability Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: '確率計算'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _probText = '';
  String _tryText = '';
  bool _showTable = false;
  Widget resultData = Text('No data');

  double calcProb(double prob, int tryNum, int appearNum) {
    final devidePowNum = appearNum == 0 ? 0 : (tryNum - appearNum) ~/ appearNum;
    final remPowNum =
        appearNum == 0 ? tryNum : (tryNum - appearNum) % appearNum;

    double resultProb = 1;
    for (int i = 0; i < appearNum; i++) {
      resultProb *=
          prob * pow((1 - prob), devidePowNum) * (tryNum - i) / (appearNum - i);
    }
    resultProb *= pow(1 - prob, remPowNum);

    return resultProb;
  }

  bool inputValidate() {
    if (_probText != '' && _tryText != '') {
      return true;
    }
    return false;
  }

  void updateResult() {
    if (inputValidate()) {
      resultData = _showTable
          ? ResultTable(
              double.parse(_probText) / 100, int.parse(_tryText), calcProb)
          : ResultGraph.withSampleData(
              double.parse(_probText) / 100, int.parse(_tryText), calcProb);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('グラフ',
                      style: _showTable
                          ? TextStyle(color: Colors.black.withOpacity(0.3))
                          : TextStyle(fontWeight: FontWeight.bold)),
                  Text(':'),
                  Text(
                    '表',
                    style: _showTable
                        ? TextStyle(fontWeight: FontWeight.bold)
                        : TextStyle(color: Colors.black.withOpacity(0.3)),
                  ),
                  Switch(
                      value: _showTable,
                      onChanged: (value) {
                        setState(() {
                          _showTable = value;
                          updateResult();
                        });
                      })
                ],
              ),
              //表のみをスクロールするためにContanerで包む
              Container(
                  height: 300,
                  child: _showTable
                      ? SingleChildScrollView(child: resultData)
                      : resultData),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Flexible(
                    child: TextField(
                  decoration: InputDecoration(
                    labelText: '出現確率(%)',
                    suffixText: '％',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    TextInputFormatter.withFunction((oldValue,
                            newValue) => //1桁目、あるいはすでに小数点がある場合、小数点の入力を無効
                        (oldValue.text.length < newValue.text.length) &&
                                (oldValue.text.length == 0 ||
                                    oldValue.text.contains('.')) &&
                                (newValue.text[newValue.text.length - 1] == '.')
                            ? oldValue
                            : newValue),
                    TextInputFormatter.withFunction((oldValue,
                            newValue) => //2桁入力したら小数点を自動挿入
                        (newValue.text.length == 2 &&
                                oldValue.text.length == 1 &&
                                newValue.text[newValue.text.length - 1] != '.')
                            ? TextEditingValue(
                                text: newValue.text + '.',
                                selection: TextSelection.collapsed(offset: 3))
                            : newValue),
                    TextInputFormatter.withFunction((oldValue,
                            newValue) => //1桁目が0だったら小数点を自動挿入
                        (newValue.text.length == 1 &&
                                newValue.text[0] == '0' &&
                                oldValue.text.length != 2)
                            ? TextEditingValue(
                                text: newValue.text + '.',
                                selection: TextSelection.collapsed(offset: 2))
                            : newValue),
                    TextInputFormatter.withFunction((oldValue,
                            newValue) => //小数点を消す際、自動的に整数部分の1桁目も消去
                        (newValue.text.length < oldValue.text.length &&
                                    oldValue.text[oldValue.text.length - 1] ==
                                        '.') &&
                                (oldValue.text.length != 1)
                            ? TextEditingValue(
                                text: newValue.text
                                    .substring(0, newValue.text.length - 1),
                                selection: TextSelection.collapsed(
                                    offset: newValue.text.length - 1))
                            : newValue),
                    LengthLimitingTextInputFormatter(5)
                  ],
                  onChanged: (text) {
                    setState(() {
                      _probText = text;
                      updateResult();
                    });
                  },
                )),
                SizedBox(
                  width: 10,
                ),
                Flexible(
                    child: TextField(
                  decoration: InputDecoration(
                      labelText: '試行回数', suffixText: '回', hintText: '1~999'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3)
                  ],
                  onChanged: (text) {
                    setState(() {
                      _tryText = text;
                      updateResult();
                    });
                  },
                )),
              ])
            ],
          ),
        ),
      ),
    );
  }
}
