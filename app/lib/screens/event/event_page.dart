import 'package:flutter/material.dart';
import 'package:rate_it/screens/event/rating_page_event.dart';
import 'package:rate_it/screens/event/reviews_page_event.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../firestore/database.dart';
import '../../model/event.dart';
import '../../model/review.dart';

class EventScreen extends StatefulWidget {
  final Event event;
  Review? userReviewOnEvent;

  EventScreen({required this.event});

  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    Review? r = await Database.alreadyReviewedEvent(widget.event);
    setState(() {
      widget.userReviewOnEvent = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
      ),
      body: FutureBuilder<List<Review>>(
        future: widget.event.reviews,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Review> renderedReviews = snapshot.data!;
            return SingleChildScrollView( // Adicionado o SingleChildScrollView
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 16.0),
                    Text(
                      widget.event.title,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      children: [
                        SizedBox(width: 8.0),
                        if (widget.event.description != null &&
                            widget.event.description.isNotEmpty)
                          Container(
                            child: AnimatedCrossFade(
                              duration: Duration(milliseconds: 300),
                              firstChild: Flexible(
                                child: Text(
                                  widget.event.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                              secondChild: Text(
                                widget.event.description,
                                style: TextStyle(fontSize: 16.0),
                              ),
                              crossFadeState: isExpanded
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstCurve: Curves.easeIn,
                            ),
                          ),
                        if (widget.event.description != null &&
                            widget.event.description.isNotEmpty)
                          Align(
                            alignment: Alignment.bottomLeft,
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Text(
                                isExpanded ? 'Show Less' : 'Show More',
                                style: TextStyle(
                                    color: Colors.blue, fontSize: 16.0),
                              ),
                            ),
                          ),
                        if (widget.event.description == null ||
                            widget.event.description.isEmpty)
                          Container(
                            child: Text(
                              'No description available',
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_sharp,
                            color: Colors.blue[600]),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${widget.event.dateStart}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 20.0,
                                color: Colors.blueAccent,
                              ),
                              Text(
                                '${widget.event.dateEnd}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Colors.green[600]),
                        SizedBox(width: 8.0),
                        Text(
                          widget.event.isPaid ? 'Paid' : 'Free',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Visibility(
                      visible: widget.event.place != null && widget.event.place.isNotEmpty,
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8.0),
                          Flexible(
                            child: Text(
                              widget.event.place,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.event.email != null && widget.event.email.isNotEmpty) ...[
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Icon(Icons.mail, color: Colors.redAccent),
                          SizedBox(width: 8.0),
                          Text(
                            widget.event.email,
                            style: TextStyle(fontSize: 16.0),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.yellow[700],
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          widget.event.averageRating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          '(${renderedReviews.length} reviews)',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (widget.userReviewOnEvent != null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventRatingPageEvent(
                                    event: widget.event,
                                    review: widget.userReviewOnEvent,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  widget.event.reviews = Database.fetchReviews(
                                      widget.event.id,
                                      widget.event.entityOrigin,
                                      2);
                                  widget.event.setAverageRating();
                                });
                                _fetchReview();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Edit your review',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(width: 8.0),
                                Icon(Icons.edit, color: Colors.white),
                              ],
                            ),
                          ),
                        if (widget.userReviewOnEvent == null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventRatingPageEvent(
                                    event: widget.event,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  widget.event.reviews = Database.fetchReviews(
                                      widget.event.id,
                                      widget.event.entityOrigin,
                                      2);
                                  widget.event.setAverageRating();
                                });
                                _fetchReview();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Rate this event',
                                    style: TextStyle(color: Colors.white)),
                                SizedBox(width: 8.0),
                                Icon(Icons.star, color: Colors.white),
                              ],
                            ),
                          ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewsPageEvent(
                                  event: widget.event,
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Check Reviews',
                                  style: TextStyle(color: Colors.white)),
                              SizedBox(width: 8.0),
                              Icon(Icons.remove_red_eye, color: Colors.white),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.event.url != null && widget.event.url.isNotEmpty) ...[
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(0),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              ),
                              onPressed: () {
                                launchUrl(Uri.parse(widget.event.url));
                              },
                              child: const Icon(Icons.language, color: Colors.blue, size: 50.0),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            print('You have an error! ${snapshot.error.toString()}');
            return Text('Something went wrong!');
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
