import 'package:flutter/material.dart';
import 'package:rate_it/screens/course/rating_page_course.dart';
import 'package:rate_it/screens/course/reviews_page_course.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../model/course.dart';
import '../../firestore/database.dart';
import '../../model/review.dart';

class CourseScreen extends StatefulWidget {
  final Course course;
  Review? userReviewOnCourse;

  CourseScreen({required this.course});

  @override
  _CourseScreenState createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchReview();
  }

  Future<void> _fetchReview() async {
    Review? r = await Database.alreadyReviewedCourse(widget.course);
    setState(() {
      widget.userReviewOnCourse = r;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.title),
      ),
      body: FutureBuilder<List<Review>>(
        future: widget.course.reviews,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Review> renderedReviews = snapshot.data!;
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    Text(
                      widget.course.title,
                      style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Column(
                      children: [
                        if (widget.course.company.description != null && widget.course.company.description.isNotEmpty)
                          AnimatedCrossFade(
                            duration: Duration(milliseconds: 300),
                            firstChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.course.company.description,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 16.0),
                                ),
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
                                      style: TextStyle(color: Colors.blue, fontSize: 16.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.course.company.description,
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                Align(
                                  alignment: Alignment.bottomLeft,
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isExpanded = !isExpanded;
                                      });
                                    },
                                    child: Text(
                                      'Show Less',
                                      style: TextStyle(color: Colors.blue, fontSize: 16.0),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            firstCurve: Curves.easeIn,
                          ),
                        if (widget.course.company.description == null || widget.course.company.description.isEmpty)
                          Text(
                            'No description available',
                            style: TextStyle(fontSize: 16.0),
                          ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Text(
                      widget.course.body,
                      style: TextStyle(fontSize: 16.0),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.calendar_month_sharp, color: Colors.blue[600]),
                        SizedBox(width: 8.0),
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                '${widget.course.dateStart}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 20.0,
                                color: Colors.blueAccent,
                              ),
                              Text(
                                '${widget.course.dateEnd}',
                                style: TextStyle(fontSize: 16.0),
                              ),
                              Text(
                                ' (Time: ${widget.course.hours} hours)',
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
                          widget.course.price == 0 ? 'Paid' : 'Free',
                          style: TextStyle(fontSize: 16.0),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Visibility(
                      visible: widget.course.place != null && widget.course.place.isNotEmpty,
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red),
                          SizedBox(width: 8.0),
                          Flexible(
                            child: Text(
                              widget.course.place,
                              style: TextStyle(fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.yellow[700]),
                        SizedBox(width: 8.0),
                        Text(
                          widget.course.averageRating.toStringAsFixed(1),
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
                        if (widget.userReviewOnCourse != null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventRatingPageCourse(course: widget.course, review: widget.userReviewOnCourse),
                                ),
                              ).then((_) {
                                setState(() {
                                  widget.course.reviews = Database.fetchReviews(widget.course.id, widget.course.entityOrigin, 1);
                                  widget.course.setAverageRating();
                                });
                                _fetchReview();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Edit your review', style: TextStyle(color: Colors.white)),
                                SizedBox(width: 8.0),
                                Icon(Icons.edit, color: Colors.white),
                              ],
                            ),
                          ),
                        if (widget.userReviewOnCourse == null)
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EventRatingPageCourse(course: widget.course),
                                ),
                              ).then((_) {
                                setState(() {
                                  widget.course.reviews = Database.fetchReviews(widget.course.id, widget.course.entityOrigin, 1);
                                  widget.course.setAverageRating();
                                });
                                _fetchReview();
                              });
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Rate this course', style: TextStyle(color: Colors.white)),
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
                                builder: (context) => ReviewsPageCourse(course: widget.course),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Check Reviews', style: TextStyle(color: Colors.white)),
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
                        if (widget.course.url != null && widget.course.url.isNotEmpty) ...[
                          Expanded(
                            child: ElevatedButton(
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all<double>(0),
                                backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                              ),
                              onPressed: () {
                                launchUrl(Uri.parse(widget.course.url));
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
