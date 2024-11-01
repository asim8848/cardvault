import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/card_provider.dart';
import '../routes.dart';
import '../utils/size_config.dart';
import '../utils/snackbar_util.dart';

class CustomCreditCard extends StatefulWidget {
  final String cardId;
  final String cardType;
  final String validThru;
  final String cardNumber;
  final String cardHolderName;
  final Color startColor;
  final Color endColor;
  final String? logoAssetName;
  final bool showButtons;
  final VoidCallback onDropdownToggle;
  final bool alwaysShowFullInfo;

  const CustomCreditCard({
    super.key,
    required this.cardId,
    required this.cardType,
    required this.validThru,
    required this.cardNumber,
    required this.cardHolderName,
    required this.startColor,
    required this.endColor,
    this.logoAssetName,
    this.showButtons = true,
    required this.onDropdownToggle,
    this.alwaysShowFullInfo = false,
  });

  @override
  _CustomCreditCardState createState() => _CustomCreditCardState();
}

class _CustomCreditCardState extends State<CustomCreditCard> {
  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Consumer<CardProvider>(
      builder: (context, cardProvider, child) {
        bool isRevealed = widget.alwaysShowFullInfo ||
            cardProvider.isCardRevealed(widget.cardId);
        bool isDropdownOpen = cardProvider.isDropdownOpen(widget.cardId);

        return GestureDetector(
          onTap: () {
            if (isDropdownOpen) {
              cardProvider.resetDropdownTimer();
            }
            if (isRevealed) {
              cardProvider.resetRevealTimer(widget.cardId);
            }
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: SizeConfig.safeBlockVertical * 25,
                margin: EdgeInsets.only(
                  bottom: SizeConfig.safeBlockVertical * 2,
                  right: SizeConfig.safeBlockHorizontal * 4,
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.safeBlockHorizontal * 5),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [widget.startColor, widget.endColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.startColor.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              widget.cardType,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: SizeConfig.safeBlockHorizontal * 4.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (widget.logoAssetName != null &&
                              widget.logoAssetName !=
                                  'Assets/images/no_logo_logo.png')
                            Image.asset(
                              widget.logoAssetName!,
                              height: SizeConfig.safeBlockVertical * 5,
                              width: SizeConfig.safeBlockHorizontal * 15,
                              fit: BoxFit.contain,
                            ),
                        ],
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Text(
                            'Valid Thru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                            ),
                          ),
                          SizedBox(width: SizeConfig.safeBlockHorizontal),
                          Icon(Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: SizeConfig.safeBlockHorizontal * 3),
                          SizedBox(width: SizeConfig.safeBlockHorizontal),
                          Text(
                            widget.validThru,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: SizeConfig.safeBlockHorizontal * 3.5,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: SizeConfig.safeBlockVertical),
                      Text(
                        isRevealed
                            ? widget.cardNumber
                            : '**** **** **** ${widget.cardNumber.substring(widget.cardNumber.length - 4)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockHorizontal * 5,
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(height: SizeConfig.safeBlockVertical),
                      Text(
                        widget.cardHolderName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: SizeConfig.safeBlockHorizontal * 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.showButtons) ...[
                Positioned(
                  top: SizeConfig.safeBlockVertical * 8,
                  right: -SizeConfig.safeBlockHorizontal * 2,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.cardView,
                        arguments: widget.cardId,
                      );
                    },
                    child: _buildCircleButton(
                      Icons.arrow_forward,
                      true,
                      SizeConfig.safeBlockHorizontal * 12,
                      SizeConfig.safeBlockVertical * 7.5,
                    ),
                  ),
                ),
                Positioned(
                  bottom: SizeConfig.safeBlockVertical * 4,
                  right: SizeConfig.safeBlockHorizontal * 5,
                  child: GestureDetector(
                    onTap: () {
                      cardProvider.toggleDropdown(widget.cardId);
                      widget.onDropdownToggle();
                    },
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildCircleButton(
                        isDropdownOpen ? Icons.close : Icons.more_vert,
                        false,
                        SizeConfig.safeBlockHorizontal * 12,
                        SizeConfig.safeBlockVertical * 5,
                        key: ValueKey<bool>(isDropdownOpen),
                      ),
                    ),
                  ),
                ),
              ],
              if (!widget.alwaysShowFullInfo)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  top: isDropdownOpen
                      ? SizeConfig.safeBlockVertical * 19
                      : SizeConfig.safeBlockVertical * 21,
                  right: isDropdownOpen
                      ? SizeConfig.safeBlockHorizontal * 18
                      : SizeConfig.safeBlockHorizontal * 15,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDropdownOpen ? 1.0 : 0.0,
                    child: IgnorePointer(
                      ignoring: !isDropdownOpen,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.safeBlockHorizontal * 3,
                          vertical: SizeConfig.safeBlockVertical * 0.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(
                              SizeConfig.safeBlockHorizontal * 5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildOverlayButton(
                              isRevealed
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              () {
                                cardProvider.toggleReveal(widget.cardId);
                                cardProvider.resetDropdownTimer();
                              },
                            ),
                            SizedBox(width: SizeConfig.safeBlockHorizontal * 3),
                            _buildOverlayButton(
                              Icons.content_copy,
                              () {
                                Clipboard.setData(
                                    ClipboardData(text: widget.cardNumber));
                                SnackBarUtil.showSnackBar(
                                    context, 'Card number copied to clipboard');
                                cardProvider.resetDropdownTimer();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCircleButton(
      IconData icon, bool isOverflow, double width, double height,
      {Key? key}) {
    return Container(
      key: key,
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.3),
        boxShadow: isOverflow
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Icon(icon,
          color: Colors.white, size: SizeConfig.safeBlockHorizontal * 5),
    );
  }

  Widget _buildOverlayButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(SizeConfig.safeBlockHorizontal * 2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.2),
        ),
        child: Icon(
          icon,
          size: SizeConfig.safeBlockHorizontal * 5,
        ),
      ),
    );
  }
}
