import 'package:flutter/material.dart';
import 'package:rate_it/model/review.dart';
import 'dart:math';
import 'package:rate_it/model/company.dart';
import 'package:rate_it/widgets/review_card.dart';

import '../../firestore/database.dart';
import '../../model/event.dart';

class ReviewsPageEvent extends StatefulWidget {
  Event event;

  ReviewsPageEvent({required this.event});

  @override
  _ReviewsPageEventState createState() => _ReviewsPageEventState();
}

class _ReviewsPageEventState extends State<ReviewsPageEvent> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews - ${widget.event.title} (${widget.event.averageRating.toStringAsFixed(2)})'),
      ),
      body: FutureBuilder<List<Review>>(
        future: widget.event.reviews,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          final reviews = snapshot.data!;
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewCard(review: reviews[index]);
              },
            ),
          );
        },
      ),
    );
  }
}