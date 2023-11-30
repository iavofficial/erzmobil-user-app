import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:flutter/material.dart';

class FavoriteJourneyItemView extends StatelessWidget {
  const FavoriteJourneyItemView({Key? key, required this.journey})
      : super(key: key);

  final Journey journey;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 15, 10),
      child: Row(
        children: [
          Image.asset(
            Strings.assetPathRoute,
            scale: 1.2,
          ),
          Flexible(
            child: (journey.favoriteName != null &&
                    journey.favoriteName!.isNotEmpty)
                ? Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                    alignment: Alignment.topLeft,
                    child: Text(
                      journey.favoriteName!,
                      style: CustomTextStyles.bodyBlackBold,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Column(children: [
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 5),
                      alignment: Alignment.topLeft,
                      child: Text(
                        journey.startAddress!.label!,
                        style: CustomTextStyles.bodyBlackBold,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      alignment: Alignment.topLeft,
                      child: Text(
                        journey.destinationAddress!.label!,
                        style: CustomTextStyles.bodyBlackBold,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
          ),
          Icon(Icons.chevron_right, color: CustomColors.black)
        ],
      ),
    );
  }
}
