import 'package:erzmobil/Constants.dart';
import 'package:erzmobil/model/BusStop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FavoriteStopView extends StatelessWidget {
  const FavoriteStopView({Key? key, required this.busStop}) : super(key: key);

  final BusStop busStop;

  @override
  Widget build(BuildContext context) {
    return _buildRow(
        context,
        Icon(
          Icons.place,
          color: CustomColors.black,
          size: 30,
        ),
        busStop.name!,
        null,
        () => null);
  }

  Widget _buildRow(BuildContext context, Widget iconPlaceholder, String title,
      String? information, Function()? onPressed,
      {TextStyle textStyle = CustomTextStyles.bodyBlackBold}) {
    return Container(
      margin: EdgeInsets.fromLTRB(10, 5, 15, 0),
      child: (information != null)
          ? Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  alignment: Alignment.topLeft,
                  width: 30,
                  child: iconPlaceholder,
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      style: textStyle,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Container(
                      alignment: Alignment.topRight,
                      child: Text(
                        information,
                        style: CustomTextStyles.bodyBlack,
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 20, 0),
                  alignment: Alignment.topLeft,
                  width: 20,
                  child: iconPlaceholder,
                ),
                Flexible(
                  child: Container(
                    alignment: Alignment.topLeft,
                    child: Text(
                      title,
                      style: textStyle,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
