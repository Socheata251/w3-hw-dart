import 'package:test/test.dart';

import '../lib/service/lms_system.dart';

void main() {
  test('creates a student', () {
    final lms = LmsSystem();

    // Create a student
    lms.addStudent(studentId: 'S1', studentName: "ronan");

    expect(lms.students.first.name, 'ronan');

    // Remove the student
    lms.removeStudent(studentId: 'S1');
    expect(lms.students.length, 0);
  });

  test('adds and removes a course', () {
    final lms = LmsSystem();
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    expect(lms.courses.length, 1);
    lms.removeCourse(courseId: 'C1');
    expect(lms.courses.length, 0);
  });

  test('rejects a duplicate course id', () {
    final lms = LmsSystem();
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    expect(
      () => lms.addCourse(courseId: 'C1', courseName: 'Other'),
      throwsException,
    );
  });

  test('rejects removal of a nonexistent course', () {
    final lms = LmsSystem();
    expect(() => lms.removeCourse(courseId: 'C9'), throwsException);
  });

  test('rejects removal of a course with enrolled students', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    expect(() => lms.removeCourse(courseId: 'C1'), throwsException);
    expect(lms.courses.length, 1);
  });

  test('enrolls a student in a course', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    expect(lms.getCourseById('C1')!.studentIds, ['S1']);
  });

  test('rejects enrollment of a nonexistent student', () {
    final lms = LmsSystem();
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    expect(
      () => lms.enrollStudent(studentId: 'S9', courseId: 'C1'),
      throwsException,
    );
  });

  test('rejects enrollment in a nonexistent course', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    expect(
      () => lms.enrollStudent(studentId: 'S1', courseId: 'C9'),
      throwsException,
    );
  });

  test('rejects duplicate enrollment', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    expect(
      () => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
      throwsException,
    );
    expect(lms.getCourseById('C1')!.studentIds.length, 1);
  });

  test('removes a student from a course and keeps both', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');
    expect(lms.getCourseById('C1')!.studentIds, isEmpty);
    expect(lms.getStudentById('S1'), isNotNull);
    expect(lms.getCourseById('C1'), isNotNull);
  });

  test('rejects removal of a nonexistent enrollment', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    expect(
      () => lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1'),
      throwsException,
    );
  });

  test('deletes the results of the course when the student is discarded', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.addCourse(courseId: 'C2', courseName: 'Web');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S1', courseId: 'C2');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
    lms.addResult(studentId: 'S1', courseId: 'C2', score: 70);
    lms.discardStudentFromCourse(studentId: 'S1', courseId: 'C1');
    expect(lms.courseResults.length, 1);
    expect(lms.courseResults.first.courseId, 'C2');
  });

  test('removes a student enrolled in multiple courses', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.addCourse(courseId: 'C2', courseName: 'Web');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S1', courseId: 'C2');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 80);
    lms.addResult(studentId: 'S1', courseId: 'C2', score: 70);
    lms.removeStudent(studentId: 'S1');
    expect(lms.getStudentById('S1'), isNull);
    expect(lms.getCourseById('C1')!.studentIds, isEmpty);
    expect(lms.getCourseById('C2')!.studentIds, isEmpty);
    expect(lms.courseResults, isEmpty);
  });

  test('adds a valid result', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    final id = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
    expect(lms.courseResults.length, 1);
    expect(lms.getResultById(id)!.score, 85);
  });

  test('rejects a result for a nonexistent student or course', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    expect(
      () => lms.addResult(studentId: 'S9', courseId: 'C1', score: 50),
      throwsException,
    );
    expect(
      () => lms.addResult(studentId: 'S1', courseId: 'C9', score: 50),
      throwsException,
    );
  });

  test('rejects a result for a student who is not enrolled', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    expect(
      () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 50),
      throwsException,
    );
  });

  test('rejects an invalid score', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    expect(
      () => lms.addResult(studentId: 'S1', courseId: 'C1', score: -1),
      throwsException,
    );
    expect(
      () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 101),
      throwsException,
    );
    expect(lms.courseResults, isEmpty);
  });

  test('rejects a second result for the same student and course', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 50);
    expect(
      () => lms.addResult(studentId: 'S1', courseId: 'C1', score: 60),
      throwsException,
    );
    expect(lms.courseResults.length, 1);
  });

  test('removes a result and keeps student, course and other results', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addStudent(studentId: 'S2', studentName: 'alice');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S2', courseId: 'C1');
    final r1 = lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
    lms.addResult(studentId: 'S2', courseId: 'C1', score: 90);
    lms.removeResult(resultId: r1);
    expect(lms.getResultById(r1), isNull);
    expect(lms.getStudentById('S1'), isNotNull);
    expect(lms.getCourseById('C1')!.studentIds, ['S1', 'S2']);
    expect(lms.courseResults.length, 1);
    expect(lms.courseResults.first.studentId, 'S2');
  });

  test('rejects removal of a nonexistent result', () {
    final lms = LmsSystem();
    expect(() => lms.removeResult(resultId: 'R999'), throwsException);
  });

  test('removing one student leaves the other unchanged', () {
    final lms = LmsSystem();
    lms.addStudent(studentId: 'S1', studentName: 'ronan');
    lms.addStudent(studentId: 'S2', studentName: 'alice');
    lms.addCourse(courseId: 'C1', courseName: 'Mobile Development');
    lms.enrollStudent(studentId: 'S1', courseId: 'C1');
    lms.enrollStudent(studentId: 'S2', courseId: 'C1');
    lms.addResult(studentId: 'S1', courseId: 'C1', score: 85);
    lms.addResult(studentId: 'S2', courseId: 'C1', score: 70);
    lms.removeStudent(studentId: 'S1');
    expect(lms.getStudentById('S1'), isNull);
    expect(lms.getCourseById('C1')!.studentIds, ['S2']);
    expect(lms.getResultsForStudent('S1'), isEmpty);
    expect(lms.getStudentById('S2'), isNotNull);
    expect(lms.getResultsForStudent('S2').single.score, 70);
  });
 }