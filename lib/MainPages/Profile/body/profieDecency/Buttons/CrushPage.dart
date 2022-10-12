import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cluster/Universal/Constans.dart';
import 'package:cluster/Universal/DataBaseRefrences.dart';


class CrushOfPage extends StatefulWidget {
  final String profileOwner;
  final String currentUserId;

  const CrushOfPage({required this.profileOwner,required this.currentUserId})
      ;

  @override
  _CrushOfPageState createState() => _CrushOfPageState();
}

class _CrushOfPageState extends State<CrushOfPage> {
  bool isLoading = true;
  bool isError = false;
  bool isListReady = false;
  List followersList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getFollowerList();
  }

  _getFollowerList() {
    crushOfRTD
        .child(widget.profileOwner)
        .child("crushOfReference")
        .once()
        .then((DataSnapshot dataSnapshot) {



      if (dataSnapshot.value != null) {

        Map followerList = dataSnapshot.value;
        List followersList = [];

        setState(() {
          followerList.forEach(
                  (index, data) => followersList.add({"user": index, ...data}));
        });

        setState(() {
          this.followersList = followersList;
        });

        isLoading = false;

      } else {
        setState(() {
          isError = true;
        });
      }
    });
  }

  _returnValue(List userList, int index) {
    return StreamBuilder(
      stream: userRefRTD.child(userList[index]['crushOfId']).onValue,
      builder: (context, AsyncSnapshot dataSnapShot) {
        if (dataSnapShot.hasData) {

          DataSnapshot snapshot = dataSnapShot.data!.snapshot;
          Map followersDetail = snapshot.value;

          return _finalList(followersDetail);
        }
        return Container();
      },
    );
  }

  _finalList(Map followersDetail) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, top: 8, right: 12),
      child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: 35,
                      height: 35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.black, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(followersDetail['url']),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      followersDetail['firstName'],
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    followersDetail['secondName'],
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              // Container(
              //   width: 90,
              //   height: 35,
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.circular(20),
              //       color: Colors.blue.shade400),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         "Decency: ",
              //         style: TextStyle(
              //             color: Colors.white, fontSize: 9, fontFamily: 'cute'),
              //       ),
              //       Text(
              //         " 100%",
              //         style: TextStyle(
              //             color: Colors.white, fontSize: 10, fontFamily: 'cute'),
              //       )
              //     ],
              //   ),
              // ),
            ],
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back_ios_rounded,
              color: Colors.blue,
            ),
          ),
          backgroundColor: Colors.white,
          title: Text(
            "Crush Of"
                "",
            style: TextStyle(
                color: Colors.blue, fontSize: 18, fontFamily: 'cute'),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(
            color: Colors.blue,
            semanticsLabel: "No Followers",
          ),
        )
            : ListView.builder(
            itemCount: followersList.length,
            itemBuilder: (context, index) {
              return _returnValue(followersList, index);
            }));
  }
}
