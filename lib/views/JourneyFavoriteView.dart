import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:flutter/material.dart';

class JourneyFavoriteView extends StatelessWidget {
  const JourneyFavoriteView(
      {Key? key, required this.journey, required this.showArrow})
      : super(key: key);

  final Journey journey;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(
          child: Container(
            margin: EdgeInsets.only(left: 40),
            alignment: Alignment.bottomLeft,
            child: Text(
              journey.favoriteName!,
              style: CustomTextStyles.bodyBlackBold,
              maxLines: 2,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: CustomColors.black,
        ),
      ],
    );
  }
}
