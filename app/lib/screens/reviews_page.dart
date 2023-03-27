import 'package:flutter/material.dart';
import 'package:my_app/model/review.dart';
import 'dart:math';
import 'package:my_app/model/company.dart';

class ReviewsPage extends StatefulWidget {
  Company company;

  ReviewsPage({required this.company});

  @override
  _ReviewsPageState createState() => _ReviewsPageState();
}

class _ReviewsPageState extends State<ReviewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews - ${widget.company.name} (${widget.company.averageRating.toStringAsFixed(2)})'),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: ListView.builder(
          itemCount: widget.company.reviews.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.cyan,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.company.reviews[index].title}',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'By ${widget.company.reviews[index].author}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Rating: ${widget.company.reviews[index].rating}',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.company.reviews[index].upvote();
                          });
                        },
                        icon: Icon(Icons.thumb_up),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            widget.company.reviews[index].downvote();
                          });
                        },
                        icon: Icon(Icons.thumb_down),
                      ),
                      Text(
                        '${widget.company.reviews[index].votes ?? 0}',
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.company.reviews[index].review}',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}