import 'package:flutter/material.dart';
import 'package:erzmobil/model/BusPosition.dart';

class BusPositionsListView extends StatelessWidget {
  const BusPositionsListView({Key? key, @required this.busPositions})
      : super(key: key);

  final List<BusPosition>? busPositions;

  @override
  Widget build(BuildContext context) {
    return busPositions != null
        ? ListView.builder(
            padding: const EdgeInsets.all(10),
            itemExtent: 120,
            itemCount: busPositions!.length,
            itemBuilder: (BuildContext context, int index) {
              return Container(
                child: Text(busPositions![index].id.toString()),
              );
            })
        : Center(
            child: Text(
                'Die Bus-Positionen konnten leider nicht abgerufen werden'),
          );
  }
}
