import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';

class AllPosts extends StatefulWidget {
  late List limitedPostList;
  late bool isVisible;
  late bool hasMore;
  late bool isHide;
  late ScrollController listScrollController;

  AllPosts(
      {super.key,
      required this.limitedPostList,
      required this.isVisible,
      required this.hasMore,
      required this.isHide,
      required this.listScrollController});

  @override
  State<AllPosts> createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<UserScrollNotification>(
          onNotification: (notification) {
            final ScrollDirection direction = notification.direction;
            setState(() {
              if (direction == ScrollDirection.reverse) {
                widget.isVisible = false;

                print("visible: ${widget.isVisible}");
              } else if (direction == ScrollDirection.forward) {
                widget.isVisible = true;
                print("visible: ${widget.isVisible}");
              }
            });
            return true;
          },
          child: InViewNotifierList(
            controller: widget.listScrollController,
            scrollDirection: Axis.vertical,
            initialInViewIds: ['0'],
            isInViewPortCondition: (double deltaTop, double deltaBottom,
                double viewPortDimension) {
              return deltaTop < (0.5 * viewPortDimension) &&
                  deltaBottom > (0.4 * viewPortDimension);
            },
            itemCount: widget.hasMore
                ? widget.limitedPostList.length + 1
                : widget.limitedPostList.length,
            builder: (BuildContext context, int index) {
              if (index >= widget.limitedPostList.length) {
                // Don't trigger if one async loading is already under way

                return Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 3, top: 3),
                    child: SizedBox(
                      height: 100,
                      width: 120,
                      child: Column(
                        children: [
                          SpinKitThreeBounce(
                            size: 14,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                final user = Provider.of<User>(context, listen: false);
                String url = widget.limitedPostList[index]['url'];
                int timestamp = widget.limitedPostList[index]['timestamp'];
                String postId = widget.limitedPostList[index]['postId'];
                String ownerId = widget.limitedPostList[index]['ownerId'];
                String description =
                    widget.limitedPostList[index]['description'];
                String type = widget.limitedPostList[index]['type'];
                String postTheme = widget.limitedPostList[index]['statusTheme'];
                String time = formatTime(timestamp);
                return Column(
                  children: [
                    widget.isHide
                        ? Container(
                            height: index == 0 ? 80 : 0,
                          )
                        : Container(
                            height: 0,
                          ),

                    GestureDetector(
                      onTap: () {
                        _getUserDetail(ownerId);
                      },
                      child: _showProfilePicAndName(
                          ownerId,
                          time,
                          postId,
                          postTheme == "" ? "photo" : postTheme,
                          type,
                          description,
                          url,
                          index),
                    ),

                    type == "thoughts"
                        ? TextStatus(description: description)
                        : type == "videoMeme" || type == "videoMemeT"
                            ? _videoPosts(index)
                            : imagePosts(index),

                    type == "thoughts"
                        ? Container(
                            height: 10.0,
                          )
                        : Container(
                            height: 5,
                          ),
                    _postFooter(
                        user, postId, ownerId, url, postTheme, index, type),
                    Container(
                      height: 10,
                    ),

                    type != "thoughts"
                        ? _description(description)
                        : Container(
                            height: 0,
                            width: 0,
                          ),
                    // creatPostFooter(),

                    Container(
                      height: 20,
                    ),
                  ],
                );
              }
            },
          ),
        ),
        widget.isVisible
            ? DelayedDisplay(
                delay: Duration(milliseconds: 200),
                slidingBeginOffset: Offset(0.0, 1),
                child: GestureDetector(
                  onTap: () {
                    if (widget.listScrollController.hasClients) {
                      final position =
                          widget.listScrollController.position.minScrollExtent;
                      widget.listScrollController.animateTo(
                        position,
                        duration: Duration(seconds: 1),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                  child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 33, right: 15),
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(13)),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                                child: Icon(
                              Icons.arrow_upward_sharp,
                              size: 15,
                            )),
                          ),
                        ),
                      )),
                ),
              )
            : Container(
                height: 0.0,
                width: 0.0,
              ),
      ],
    );
  }
}
