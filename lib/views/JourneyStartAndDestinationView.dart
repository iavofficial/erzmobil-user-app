import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/model/Journey.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class JourneyStartAndDestinationView extends StatelessWidget {
  const JourneyStartAndDestinationView(
      {Key? key,
      required this.journey,
      required this.showArrow,
      this.useWhiteTextStyle = true})
      : super(key: key);

  final Journey journey;
  final bool showArrow;
  final bool useWhiteTextStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          width: 40,
                          child: Text(
                            AppLocalizations.of(context)!.selectRouteFromLabel,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhite
                                : CustomTextStyles.bodyBlack,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                            child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            journey.startAddress!.label!,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhiteBold
                                : CustomTextStyles.bodyBlackBold,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                    child: Row(
                      children: [
                        Container(
                          alignment: Alignment.topLeft,
                          width: 40,
                          child: Text(
                            AppLocalizations.of(context)!.selectRouteToLabel,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhite
                                : CustomTextStyles.bodyBlack,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Flexible(
                            child: Container(
                          alignment: Alignment.topLeft,
                          child: Text(
                            journey.destinationAddress!.label!,
                            style: useWhiteTextStyle
                                ? CustomTextStyles.bodyWhiteBold
                                : CustomTextStyles.bodyBlackBold,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              showArrow
                  ? Icon(
                      Icons.chevron_right,
                      color: useWhiteTextStyle
                          ? CustomColors.white
                          : CustomColors.black,
                    )
                  : Text(''),
            ],
          ),
        ),
      ],
    );
  }
}
