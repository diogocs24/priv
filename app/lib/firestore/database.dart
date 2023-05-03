import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rate_it/auth/Authentication.dart';

import '../model/company.dart';
import '../model/course.dart';
import '../model/event.dart';
import '../model/review.dart';
import '../model/user.dart';

class Database{
  static final FirebaseFirestore db = FirebaseFirestore.instance;

  static Future<List<Review>> fetchReviews(int idEntity, int entityOrigin, int categoryIndex) async {
    Query query = db.collection("reviews");
    query = query.where("idEntity", isEqualTo: idEntity);
    query = query.where("entityOrigin", isEqualTo: entityOrigin);
    query = query.where("categoryIndex", isEqualTo: categoryIndex);
    List<Review> reviews = [];

    QuerySnapshot querySnapshot = await query.get();
    for (var doc in querySnapshot.docs){
      Map<String, dynamic> reviewData = doc.data() as Map<String, dynamic>;
      Review review = reviewFromMap(reviewData, doc.id);
      reviews.add(review);
    }
    return reviews;
  }

  static void addReview(Review review) {
      db.collection('reviews').add({
        'title': review.title,
        'rating': review.rating,
        'review': review.review,
        'authorId': review.authorId,
        'idEntity': review.idEntity, // Add the companyId field
        'categoryIndex': review.categoryIndex,
        'entityOrigin': review.entityOrigin,
        'votes': review.votes,
        'anonymous': review.anonymous,
      });
  }

  static void updateVoteReview(Review review, int vote) {
    try {
      db.collection("reviews").doc(review.reviewRef).update(
          {"votes": FieldValue.increment(vote)}
      );
    } catch(e){
      print("Error in updateVoteReview: $e");
    }
  }

  static Future<User> getUser(String uid) async {
    var val = await db.collection("users").doc(uid).get();
    Map<String,dynamic> map = val.data()!;
    User user = userFromMap(map);
    return user;
  }

  static void addUser(User user) {
    String uid = Authentication.auth.currentUser!.uid;
    db.collection('users').doc(uid).set({
      'username': user.username,
      'firstName': user.firstName,
      'lastName': user.lastName,
      'email': user.email,
      'photoURL': user.photoURL,
      'description': user.description,
      'phone': user.phone,
      'nReviews': user.nReviews
    });
  }

  static Future<bool> isUsernameInUse(String username) async {
    Query query = db.collection("users");
    query = query.where("username", isEqualTo: username);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.isNotEmpty;
  }

  static Future<bool> alreadyReviewedCompany(Company company) async {
    Query query = db.collection("reviews");
    query = query.where("idEntity", isEqualTo: company.id);
    query = query.where("entityOrigin", isEqualTo: company.entityOrigin);
    query = query.where("categoryIndex", isEqualTo: 0);
    query = query.where("authorId", isEqualTo: Authentication.auth.currentUser!.uid);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.isNotEmpty;
  }

  static Future<bool> alreadyReviewedCourse(Course course) async {
    Query query = db.collection("reviews");
    query = query.where("idEntity", isEqualTo: course.id);
    query = query.where("entityOrigin", isEqualTo: course.entityOrigin);
    query = query.where("categoryIndex", isEqualTo: 1);
    query = query.where("authorId", isEqualTo: Authentication.auth.currentUser!.uid);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.isNotEmpty;
  }

  static Future<bool> alreadyReviewedEvent(Event event) async {
    Query query = db.collection("reviews");
    query = query.where("idEntity", isEqualTo: event.id);
    query = query.where("entityOrigin", isEqualTo: event.entityOrigin);
    query = query.where("categoryIndex", isEqualTo: 2);
    query = query.where("authorId", isEqualTo: Authentication.auth.currentUser!.uid);
    QuerySnapshot querySnapshot = await query.get();
    return querySnapshot.docs.isNotEmpty;
  }

  static void updateUserPhotoURL(String uid, String url){
    db.collection("users").doc(uid).update(
        {"photoURL": url}
    );
  }
}