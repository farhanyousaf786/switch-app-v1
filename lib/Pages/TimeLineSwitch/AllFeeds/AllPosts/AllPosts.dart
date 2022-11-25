import 'package:delayed_display/delayed_display.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:provider/provider.dart';
import 'package:time_formatter/time_formatter.dart';
import '../../../../Models/Marquee.dart';
import '../../../../Models/postModel/CommentsPage.dart';
import '../../../../Models/postModel/PostsReactCounters.dart';
import '../../../../Models/postModel/TextStatus.dart';
import '../../../../Universal/Constans.dart';
import '../../../../Universal/DataBaseRefrences.dart';
import '../../../../learning/video_widget.dart';
import '../../../Profile/Panelandbody.dart';
import '../../../ReportAndComplaints/postReportPage.dart';
import '../../../ReportAndComplaints/reportId.dart';
import '../CacheImageTemplate.dart';

class AllPosts extends StatefulWidget {
  late List limitedPostList;
  late bool isVisible;
  late bool hasMore;
  late bool isHide;
  late ScrollController listScrollController;
  late User user;

  AllPosts({
    super.key,
    required this.limitedPostList,
    required this.isVisible,
    required this.hasMore,
    required this.isHide,
    required this.listScrollController,
    required this.user,
  });

  @override
  State<AllPosts> createState() => _AllPostsState();
}

class _AllPostsState extends State<AllPosts> {
  late Map data;
  List posts = [];

  _postFooter(User user, String postId, String ownerId, String url,
      String postTheme, int index, String type) {
    return Container(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 17,
                  ),
                  PostReactCounter(
                    postId: postId,
                    ownerId: ownerId,
                    type: type,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                            useRootNavigator: true,
                            isScrollControlled: true,
                            barrierColor: Colors.red.withOpacity(0.2),
                            elevation: 0,
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            context: context,
                            builder: (context) {
                              return Provider<User>.value(
                                value: widget.user,
                                child: CommentsPage(
                                    postId: postId,
                                    ownerId: ownerId,
                                    photoUrl: url),
                              );
                            });
                      },
                      child: Container(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Icon(
                                Icons.messenger_outline_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              StreamBuilder(
                                stream: commentRtDatabaseReference
                                    .child(postId)
                                    .onValue,
                                builder: (context, AsyncSnapshot dataSnapShot) {
                                  if (!dataSnapShot.hasData) {
                                    return Text(
                                      "0",
                                      style: TextStyle(
                                          fontFamily: 'cutes',
                                          color: Colors.grey.shade600,
                                          fontSize: 10),
                                    );
                                  } else {
                                    DataSnapshot snapshot =
                                        dataSnapShot.data.snapshot;
                                    Map data = snapshot.value;
                                    List item = [];
                                    if (data == null) {
                                      return Text(
                                        "0",
                                        style: TextStyle(
                                            fontFamily: 'cutes',
                                            color: Colors.grey.shade600,
                                            fontSize: 10),
                                      );
                                    } else {
                                      data.forEach((index, data) =>
                                          item.add({"key": index, ...data}));
                                    }

                                    return dataSnapShot.data.snapshot.value ==
                                            null
                                        ? SizedBox()
                                        : Text(
                                            data.length.toString(),
                                            style: TextStyle(
                                                fontFamily: 'cutes',
                                                color: Colors.grey.shade600,
                                                fontSize: 10),
                                          );
                                  }
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
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 8),
                child: TextButton(
                    onPressed: () => {
                          // reactorList.clear(),
                          // getPostDetail(postId),
                        },
                    child: Row(
                      children: [
                        Text(
                          "Details ",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'cutes',
                              fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        ),
                        Container(
                          height: 18,
                          width: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(width: 1, color: Colors.grey),
                            image: DecorationImage(
                              image: AssetImage('images/logoPro.png'),
                              fit: BoxFit.fill,
                            ),
                          ),
                        ),
                      ],
                    )),
              )
            ],
          ),
          // loadingRecentPosts
          //     ? Padding(
          //         padding: const EdgeInsets.all(8.0),
          //         child: LinearProgressIndicator(
          //           color: Colors.blue,
          //         ),
          //       )
          //     : Container(
          //         height: 0,
          //         width: 0,
          //       ),
        ],
      ),
    );
  }

  _videoPosts(int index) {
    return Container(
      height: 360.0,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return InViewNotifierWidget(
              id: '$index',
              builder: (BuildContext context, bool isInView, Widget? child) {
                return VideoWidget(
                    play: isInView, url: widget.limitedPostList[index]['url']);
              },
            );
          },
        ),
      ),
    );
  }

  _getUserDetail(String ownerId) {
    User user = Provider.of<User>(context, listen: false);

    userRefRTD.child(ownerId).once().then((DataSnapshot dataSnapshot) {
      Map data = dataSnapshot.value;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Provider<User>.value(
            value: widget.user,
            child: SwitchProfile(
              mainProfileUrl: data['url'],
              profileOwner: data['ownerId'],
              mainFirstName: data['firstName'],
              mainAbout: data['about'],
              mainCountry: data['country'],
              mainSecondName: data['secondName'],
              mainEmail: data['email'],
              mainGender: data['gender'],
              currentUserId: Constants.myId,
              user: user,
              action: "fromTimeLine",
              username: data['username'],
              isVerified: data['isVerified'],
              mainDateOfBirth: data['dob'],
            ),
          ),
          //     Provider<User>.value(
          //   value: user,
          //   child: MainSearchPage(
          //     user: user,
          //     userId: user.uid,
          //   ),
          // ),
        ),
      );
    });
  }

  ///
  _showProfilePicAndName(
      String ownerId,
      String timeStamp,
      String postId,
      String postTheme,
      String type,
      String description,
      String url,
      int index) {
    return StreamBuilder(
        stream: userRefRTD.child(ownerId).onValue,
        builder: (context, AsyncSnapshot dataSnapShot) {
          if (dataSnapShot.hasData) {
            DataSnapshot snapshot = dataSnapShot.data.snapshot;
            Map data = snapshot.value;
            return Container(
              width: MediaQuery.of(context).size.width,
              child: ListTile(
                trailing: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                        useRootNavigator: true,
                        isScrollControlled: true,
                        barrierColor: Colors.red.withOpacity(0.2),
                        elevation: 0,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        context: context,
                        builder: (context) {
                          return Container(
                            height: MediaQuery.of(context).size.height / 3,
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Container(
                                    color: Colors.blue,
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.linear_scale_sharp,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  type == 'meme' || type == "memeT"
                                      ? Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: GestureDetector(
                                            onTap: () {
                                              switchShowCaseRTD
                                                  .child(widget.user.uid)
                                                  .child(postId)
                                                  .once()
                                                  .then((DataSnapshot
                                                          dataSnapshot) =>
                                                      {
                                                        if (dataSnapshot
                                                                .value !=
                                                            null)
                                                          {
                                                            switchShowCaseRTD
                                                                .child(widget
                                                                    .user.uid)
                                                                .child(postId)
                                                                .remove(),
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  "Remove From Your Meme Showcase",
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                              gravity:
                                                                  ToastGravity
                                                                      .TOP,
                                                              timeInSecForIosWeb:
                                                                  3,
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              textColor:
                                                                  Colors.white,
                                                              fontSize: 16.0,
                                                            ),
                                                          }
                                                        else
                                                          {
                                                            switchShowCaseRTD
                                                                .child(widget
                                                                    .user.uid)
                                                                .child(postId)
                                                                .set({
                                                              "memeUrl": url,
                                                              "ownerId":
                                                                  ownerId,
                                                              'timestamp': DateTime
                                                                      .now()
                                                                  .millisecondsSinceEpoch,
                                                              'postId': postId,
                                                            }),
                                                            Fluttertoast
                                                                .showToast(
                                                              msg:
                                                                  "Added to your Meme Showcase",
                                                              toastLength: Toast
                                                                  .LENGTH_LONG,
                                                              gravity:
                                                                  ToastGravity
                                                                      .TOP,
                                                              timeInSecForIosWeb:
                                                                  3,
                                                              backgroundColor:
                                                                  Colors.blue,
                                                              textColor:
                                                                  Colors.white,
                                                              fontSize: 16.0,
                                                            ),
                                                          }
                                                      });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, left: 20),
                                              child: Row(
                                                children: [
                                                  Text(
                                                    "Add/Remove from Meme ShowCase ",
                                                    style: TextStyle(
                                                        fontFamily: 'cutes',
                                                        fontSize: 14,
                                                        color:
                                                            Constants.isDark ==
                                                                    "true"
                                                                ? Colors.white
                                                                : Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Icon(
                                                      Icons.apps,
                                                      color: Constants.isDark ==
                                                              "true"
                                                          ? Colors.white
                                                          : Colors.blue,
                                                      size: 17,
                                                      // color: selectedIndex == index
                                                      //     ? Colors.pink
                                                      //     : selectedIndex == 121212
                                                      //         ? Colors.grey
                                                      //         : Colors.teal,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      : SizedBox(
                                          height: 0,
                                          width: 0,
                                        ),
                                  ownerId == Constants.myId ||
                                          widget.user.uid == Constants.switchId
                                      ? Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, left: 20),
                                          child: TextButton(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    'Delete Post',
                                                    style: TextStyle(
                                                        fontFamily: 'cutes',
                                                        fontSize: 14,
                                                        color:
                                                            Constants.isDark ==
                                                                    "true"
                                                                ? Colors.white
                                                                : Colors.blue,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Icon(
                                                    Icons.delete_outline,
                                                    size: 20,
                                                    color: Constants.isDark ==
                                                            "true"
                                                        ? Colors.white
                                                        : Colors.blue,
                                                  ),
                                                ],
                                              ),
                                              onPressed: () => {
                                                    // deleteFunc(postId, ownerId,
                                                    //     type, index),
                                                  }),
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, left: 10),
                                          child: ElevatedButton(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Report Post ',
                                                  style: TextStyle(
                                                    fontFamily: 'cutes',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Constants.isDark ==
                                                            "true"
                                                        ? Colors.white
                                                        : Colors.blue,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.error_outline,
                                                  size: 20,
                                                  color:
                                                      Constants.isDark == "true"
                                                          ? Colors.white
                                                          : Colors.blue,
                                                ),
                                              ],
                                            ),
                                            onPressed: () => {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PostReport(
                                                            reportById:
                                                                widget.user.uid,
                                                            reportedId: ownerId,
                                                            postId: postId,
                                                            type: "reportPost",
                                                          )))
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              primary: Colors.transparent,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                  ownerId == Constants.myId
                                      ? Container(
                                          height: 0,
                                          width: 0,
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, left: 10),
                                          child: ElevatedButton(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Report User ',
                                                  style: TextStyle(
                                                    fontFamily: 'cutes',
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Constants.isDark ==
                                                            "true"
                                                        ? Colors.white
                                                        : Colors.blue,
                                                  ),
                                                ),
                                                Icon(
                                                  Icons.account_circle_outlined,
                                                  size: 20,
                                                  color:
                                                      Constants.isDark == "true"
                                                          ? Colors.white
                                                          : Colors.blue,
                                                ),
                                              ],
                                            ),
                                            onPressed: () => {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        ReportId(
                                                            profileId:
                                                                ownerId)),
                                              )
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              primary: Colors.transparent,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                  ownerId == Constants.myId
                                      ? Container(
                                          height: 0,
                                          width: 0,
                                        )
                                      : Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0, left: 10),
                                          child: ElevatedButton(
                                            child: Row(
                                              children: [
                                                Text(
                                                  'Block User ',
                                                  style: TextStyle(
                                                      fontFamily: 'cutes',
                                                      fontSize: 14,
                                                      color: Constants.isDark ==
                                                              "true"
                                                          ? Colors.white
                                                          : Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Icon(
                                                  Icons.block,
                                                  size: 20,
                                                  color:
                                                      Constants.isDark == "true"
                                                          ? Colors.white
                                                          : Colors.blue,
                                                ),
                                              ],
                                            ),
                                            onPressed: () => {
                                              // blockUser(
                                              //     ownerId, Constants.myId),
                                            },
                                            style: ElevatedButton.styleFrom(
                                              elevation: 0.0,
                                              primary: Colors.transparent,
                                              textStyle: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                ],
                              ),
                            ),
                          );
                        });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 0),
                    child: Icon(
                      Icons.more_horiz,
                      // color: selectedIndex == index
                      //     ? Colors.pink
                      //     : selectedIndex == 121212
                      //         ? Colors.grey
                      //         : Colors.teal,
                      color: Colors.grey,
                    ),
                  ),
                ),

                title: Transform(
                  transform: Matrix4.translationValues(-1, 5.0, 0.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1),
                            image: DecorationImage(
                              image: NetworkImage(data['url'] == null
                                  ? "https://switchappimages.nyc3.digitaloceanspaces.com/StaticUse/1646080905939.jpg"
                                  : data['url']),
                            ),
                          ),
                        ),
                        // CircleAvatar(
                        //   child: CircleAvatar(
                        //     radius: 22,
                        //     backgroundColor: Colors.grey,
                        //     backgroundImage:
                        //         CachedNetworkImageProvider(snapShot.data['url']),
                        //   ),
                        //   radius: 23.5,
                        //   backgroundColor: Colors.grey,
                        // ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "  " +
                                        data['firstName'] +
                                        " " +
                                        data['secondName'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  data['isVerified'] == "true"
                                      ? Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Container(
                                              height: 15,
                                              width: 15,
                                              child: Image.asset(
                                                  "images/blueTick.png")),
                                        )
                                      : SizedBox(
                                          height: 0,
                                          width: 0,
                                        ),
                                  Text(
                                    type == "meme"
                                        ? " share meme"
                                        : " share $postTheme",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, top: 0),
                                child: MarqueeWidget(
                                  animationDuration: const Duration(seconds: 1),
                                  backDuration: const Duration(seconds: 3),
                                  pauseDuration:
                                      const Duration(milliseconds: 100),
                                  child: Text(
                                    timeStamp,
                                    style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.grey,
                                        fontFamily: 'cutes'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

//                    subtitle: Text(description),
              ),
            );
          } else {
            return Container(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ));
          }
        });
  }

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

  imagePosts(int index) {
    return Container(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 15, bottom: 10, left: 10, right: 10),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CacheImageTemplate(
              list: widget.limitedPostList,
              index: index,
            )),
      ),
    );
  }

  _description(String description) {
    return description.length == 0
        ? Container(
            height: 0,
            width: 0,
          )
        : Container(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 15,
                          ),
                          if (description.length > 34)
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 3),
                                  child: Text(
                                    "Caption:  ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontFamily: 'cute'),
                                  ),
                                ),
                                textControl(description.substring(0, 20)),
                                TextButton(
                                  onPressed: () {
                                    showModalBottomSheet(
                                        useRootNavigator: true,
                                        isScrollControlled: true,
                                        barrierColor:
                                            Colors.red.withOpacity(0.2),
                                        elevation: 0,
                                        clipBehavior:
                                            Clip.antiAliasWithSaveLayer,
                                        context: context,
                                        builder: (context) {
                                          return Container(
                                            color: Colors.white,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height /
                                                3.5,
                                            child: SingleChildScrollView(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Center(
                                                      child: Text(
                                                        'Caption',
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontFamily: 'cute',
                                                          fontSize: 18,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: textControl(
                                                          description),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Text(
                                    "Read More...",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 12,
                                        fontFamily: 'cute'),
                                  ),
                                ),
                              ],
                            )
                          // GestureDetector(
                          //   onTap: () => {
                          //     showModalBottomSheet(
                          //         useRootNavigator: true,
                          //         isScrollControlled: true,
                          //         barrierColor: Colors.red.withOpacity(0.2),
                          //         elevation: 0,
                          //         clipBehavior: Clip.antiAliasWithSaveLayer,
                          //         context: context,
                          //         builder: (context) {
                          //           return Container(
                          //             height:
                          //                 MediaQuery.of(context).size.height /
                          //                     2,
                          //             child: SingleChildScrollView(
                          //               child: Column(
                          //                 children: [
                          //                   Padding(
                          //                     padding:
                          //                         const EdgeInsets.all(8.0),
                          //                     child: Row(
                          //                       crossAxisAlignment:
                          //                           CrossAxisAlignment.center,
                          //                       mainAxisAlignment:
                          //                           MainAxisAlignment.center,
                          //                       children: [
                          //                         Icon(Icons
                          //                             .linear_scale_sharp),
                          //                       ],
                          //                     ),
                          //                   ),
                          //                   Padding(
                          //                     padding:
                          //                         const EdgeInsets.all(8.0),
                          //                     child: LinkifyText(
                          //                       description,
                          //                       textAlign: TextAlign.left,
                          //                       linkTypes: [
                          //                         LinkType.email,
                          //                         LinkType.url,
                          //                         LinkType.hashTag,
                          //                         LinkType.userTag,
                          //                       ],
                          //                       linkStyle: TextStyle(
                          //                           fontSize: 13,
                          //                           fontFamily: "cutes",
                          //                           fontWeight:
                          //                               FontWeight.bold,
                          //                           color: Colors.blue),
                          //                       onTap: (link) => {
                          //                         // url = link.value.toString(),
                          //                         // _launchURL('http://$url'),
                          //                       },
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //             ),
                          //           );
                          //         }),
                          //   },
                          //   child: LinkifyText(
                          //     "@Caption: " +
                          //         description.substring(0, 30) +
                          //         " ...(readMore)",
                          //     textAlign: TextAlign.left,
                          //     linkTypes: [
                          //       LinkType.email,
                          //       LinkType.url,
                          //       LinkType.hashTag,
                          //       LinkType.userTag,
                          //     ],
                          //     linkStyle: TextStyle(
                          //         fontSize: 13,
                          //         fontFamily: "cutes",
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.blue),
                          //     onTap: (link) => {
                          //       // url = link.value.toString(),
                          //       // _launchURL('http://$url'),
                          //     },
                          //   ),
                          // )
                          else
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2.5),
                                  child: Text(
                                    "Caption:  ",
                                    style: TextStyle(
                                        color: Colors.blue,
                                        fontSize: 15,
                                        fontFamily: 'cute'),
                                  ),
                                ),
                                textControl(description),
                              ],
                            )
                          // GestureDetector(
                          //   onTap: () => {
                          //     bottomSheetForCommentSection(description),
                          //   },
                          //   child: LinkifyText(
                          //     "@Caption: " + description,
                          //     textAlign: TextAlign.left,
                          //     linkTypes: [
                          //       LinkType.email,
                          //       LinkType.url,
                          //       LinkType.hashTag,
                          //       LinkType.userTag,
                          //     ],
                          //     linkStyle: TextStyle(
                          //         fontSize: 13,
                          //         fontFamily: "cutes",
                          //         fontWeight: FontWeight.bold,
                          //         color: Colors.blue),
                          //     onTap: (link) => {
                          //       // url = link.value.toString(),
                          //       // _launchURL('http://$url'),
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget textControl(String description) {
    return GestureDetector(
      onLongPress: () => {
        Clipboard.setData(ClipboardData(text: description)),
        Fluttertoast.showToast(
          msg: "Copy",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.blue.withOpacity(0.8),
          textColor: Colors.white,
          fontSize: 16.0,
        ),
      },
      child: Linkify(
        onOpen: (link) async {
          showModalBottomSheet(
              useRootNavigator: true,
              isScrollControlled: true,
              barrierColor: Colors.red.withOpacity(0.2),
              elevation: 0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              context: context,
              builder: (context) {
                return Container(
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "This link (${link.url}) will lead you out of the Switch App.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: "cutes",
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: () async {
                                // if (await canLaunch(link.url)) {
                                //   await launch(link.url);
                                // } else {
                                //   throw 'Could not launch $link';
                                // }
                              },
                              child: Text(
                                "Ok Continue",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: "cutes",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ))
                        ],
                      ),
                    ),
                  ),
                );
              });
        },
        text: description,
        linkStyle: TextStyle(color: Colors.blue, fontWeight: FontWeight.w700),
      ),
    );

    // return LinkifyText(
    // widget.description,
    // textAlign: TextAlign.left,
    // linkTypes: [
    // LinkType.url,
    // LinkType.hashTag,
    // ],
    // linkStyle: TextStyle(
    // fontSize: 13,
    // fontFamily: "cutes",
    // fontWeight: FontWeight.bold,
    // color: Colors.blue),
    // onTap: (link) => {
    // url = link.value.toString(),
    // },
    // );
  }
}
