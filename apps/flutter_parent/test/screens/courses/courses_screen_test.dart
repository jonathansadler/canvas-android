// Copyright (C) 2019 - present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:built_collection/built_collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_parent/l10n/app_localizations.dart';
import 'package:flutter_parent/models/course.dart';
import 'package:flutter_parent/models/enrollment.dart';
import 'package:flutter_parent/models/user.dart';
import 'package:flutter_parent/network/api/assignment_api.dart';
import 'package:flutter_parent/screens/courses/courses_interactor.dart';
import 'package:flutter_parent/screens/courses/courses_screen.dart';
import 'package:flutter_parent/screens/courses/details/course_details_interactor.dart';
import 'package:flutter_parent/screens/courses/details/course_details_screen.dart';
import 'package:flutter_parent/utils/quick_nav.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import '../../utils/accessibility_utils.dart';
import '../../utils/test_app.dart';

void main() {
  _setupLocator(_MockCoursesInteractor mockInteractor) {
    final _locator = GetIt.instance;
    _locator.reset();
    _locator.registerFactory<CoursesInteractor>(() => mockInteractor);
    _locator.registerFactory<CourseDetailsInteractor>(() => _MockCourseDetailsInteractor());
    _locator.registerFactory<AssignmentApi>(() => _MockAssignmentApi());
    _locator.registerFactory<QuickNav>(() => QuickNav());
  }

  Widget _testableMaterialWidget([Widget widget]) =>
      TestApp(Scaffold(body: widget ?? CoursesScreen(_mockStudent('0'))));

  testWidgetsWithAccessibilityChecks('shows loading indicator when retrieving courses', (tester) async {
    _setupLocator(_MockCoursesInteractor());

    await tester.pumpWidget(TestApp(CoursesScreen(_mockStudent('0'))));
    await tester.pump();

    final loadingWidget = find.byType(CircularProgressIndicator);
    expect(loadingWidget, findsOneWidget);
  });

  testWidgetsWithAccessibilityChecks('does not show loading when courses are loaded', (tester) async {
    _setupLocator(_MockCoursesInteractor());
    await tester.pumpWidget(_testableMaterialWidget());
    await tester.pump();
    await tester.pump();

    final loadingWidget = find.byType(CircularProgressIndicator);
    expect(loadingWidget, findsNothing);
  });

  testWidgetsWithAccessibilityChecks('shows courses after load', (tester) async {
    var student = _mockStudent('1');
    var courses = generateCoursesForStudent(student.id);

    _setupLocator(_MockCoursesInteractor(courses: courses));

    await tester.pumpWidget(_testableMaterialWidget(CoursesScreen(student)));
    await tester.pumpAndSettle();

    final listTileWidget = find.byType(ListTile);
    expect(listTileWidget, findsNWidgets(courses.length));
  });

  testWidgetsWithAccessibilityChecks('shows empty message after load', (tester) async {
    var student = _mockStudent('1');

    _setupLocator(_MockCoursesInteractor(courses: []));

    await tester.pumpWidget(_testableMaterialWidget(CoursesScreen(student)));
    await tester.pumpAndSettle();

    expect(find.text(AppLocalizations().noCoursesTitle), findsOneWidget);
    expect(find.text(AppLocalizations().noCoursesMessage), findsOneWidget);
  });

  testWidgetsWithAccessibilityChecks('shows no grade if there is no current grade', (tester) async {
    var student = _mockStudent('1');
    var courses = generateCoursesForStudent(student.id);

    _setupLocator(_MockCoursesInteractor(courses: courses));

    await tester.pumpWidget(_testableMaterialWidget(CoursesScreen(student)));
    await tester.pumpAndSettle();

    final gradeWidget = find.text(AppLocalizations().noGrade);
    expect(gradeWidget, findsNWidgets(courses.length));
  });

  testWidgetsWithAccessibilityChecks('shows grade if there is a current grade', (tester) async {
    var student = _mockStudent('1');
    var courses = List.generate(
      1,
      (idx) => _mockCourse(
        idx.toString(),
        enrollments: ListBuilder<Enrollment>(
          [_mockEnrollment(idx.toString(), userId: student.id, computedCurrentGrade: "A")],
        ),
      ),
    );

    _setupLocator(_MockCoursesInteractor(courses: courses));

    await tester.pumpWidget(_testableMaterialWidget(CoursesScreen(student)));
    await tester.pumpAndSettle();

    final gradeWidget = find.text('A');
    expect(gradeWidget, findsNWidgets(courses.length));
  });

  testWidgetsWithAccessibilityChecks('shows score if there is a grade but no grade string', (tester) async {
    var student = _mockStudent('1');
    var courses = List.generate(
      1,
      (idx) => _mockCourse(
        idx.toString(),
        enrollments: ListBuilder<Enrollment>(
          [_mockEnrollment(idx.toString(), userId: student.id, computedCurrentScore: 90)],
        ),
      ),
    );

    _setupLocator(_MockCoursesInteractor(courses: courses));

    await tester.pumpWidget(_testableMaterialWidget(CoursesScreen(student)));
    await tester.pumpAndSettle();

    final gradeWidget = find.text('90%');
    expect(gradeWidget, findsNWidgets(courses.length));
  });

  testWidgetsWithAccessibilityChecks('launches course detail screen when tapping on a course', (tester) async {
    var student = _mockStudent('1');
    var courses = List.generate(
      1,
      (idx) => _mockCourse(
        idx.toString(),
        enrollments: ListBuilder<Enrollment>(
          [_mockEnrollment(idx.toString(), userId: student.id, computedCurrentScore: 90)],
        ),
      ),
    );

    _setupLocator(_MockCoursesInteractor(courses: courses));

    await tester.pumpWidget(_testableMaterialWidget(CoursesScreen(student)));
    await tester.pumpAndSettle();

    final matchedWidget = find.text(courses.first.name);
    expect(matchedWidget, findsOneWidget);
    await tester.tap(matchedWidget);
    await tester.pumpAndSettle();

    expect(find.byType(CourseDetailsScreen), findsOneWidget);
  });
}

class _MockCoursesInteractor extends CoursesInteractor {
  List<Course> courses;

  _MockCoursesInteractor({this.courses});

  @override
  Future<List<Course>> getCourses() async => courses ?? ListBuilder<Course>([_mockCourse('1')]).build().toList();
}

class _MockCourseDetailsInteractor extends CourseDetailsInteractor {}

class _MockAssignmentApi extends Mock implements AssignmentApi {}

List<Course> generateCoursesForStudent([String userId]) {
  var student = _mockStudent(userId ?? '1');
  return List.generate(
    3,
    (idx) => _mockCourse(
      idx.toString(),
      enrollments: ListBuilder<Enrollment>([_mockEnrollment(idx.toString(), userId: student.id)]),
    ),
  );
}

Enrollment _mockEnrollment(
  String courseId, {
  String userId = '0',
  String computedCurrentGrade,
  double computedCurrentScore,
}) =>
    Enrollment((b) => b
      ..courseId = courseId
      ..userId = userId
      ..courseSectionId = '0'
      ..enrollmentState = ''
      ..computedCurrentGrade = computedCurrentGrade
      ..computedCurrentScore = computedCurrentScore
      ..build());

Course _mockCourse(String courseId,
        {ListBuilder<Enrollment> enrollments, bool hasActiveGradingPeriod, double currentScore, String currentGrade}) =>
    Course((b) => b
      ..id = courseId
      ..name = "CourseName"
      ..imageDownloadUrl = ''
      ..enrollments = enrollments ?? ListBuilder<Enrollment>([_mockEnrollment('0')])
      ..hasGradingPeriods = hasActiveGradingPeriod ?? false
      ..currentScore = currentScore
      ..currentGrade = currentGrade
      ..build());

User _mockStudent(String userId) => User((b) => b
  ..id = userId
  ..name = "UserName"
  ..sortableName = "Sortable Name"
  ..build());
