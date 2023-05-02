import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

import '../../auth/Authentication.dart';
import '../../firebase/database.dart';
import '../../model/company.dart';
import '../../model/review.dart';
import '../home_page.dart';

class EventRatingPageCompany extends StatefulWidget {

  Company company;

  EventRatingPageCompany({Key? key, required this.company}) : super(key: key);


  int _rating = 0;
  String _review = "";


  @override
  _EventRatingPageCompanyState createState() => _EventRatingPageCompanyState();

  void setReview(String value) {
    _review = value;
  }
}

class _EventRatingPageCompanyState extends State<EventRatingPageCompany> {
  int rating = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rate this Company'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How many stars would you give this company?',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStarButton(1),
                _buildStarButton(2),
                _buildStarButton(3),
                _buildStarButton(4),
                _buildStarButton(5),
              ],
            ),
            SizedBox(height: 32),
            Text(
              'Write a review:',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                hintText: 'Enter your review here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: widget.setReview,
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                String author = Authentication.auth.currentUser!.uid;
                Review review = Review(
                  title: 'Review',
                  rating: widget._rating,
                  review: widget._review,
                  authorId: author,
                  anonymous: false, //TODO MAKE A SWITCH TO CHANGE THIS STATE BEFORE SUBMIT
                  categoryIndex: 0,
                  idEntity: widget.company.id,
                  entityOrigin: widget.company.entityOrigin,
                  votes: 0,
                 );

                if(widget._rating > 0){
                  Database.addReview(review);
                  Navigator.pop(context);
                }
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStarButton(int value) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          widget._rating = value;
        });

      },
      child: Icon(
        Icons.star,
        color: value <= widget._rating ? Colors.amber : Colors.grey[400],
      ),
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        primary: Colors.white,
        onPrimary: Colors.black,
      ),
    );
  }

}
