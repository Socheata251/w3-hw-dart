import '../model/student.dart';
import '../model/course.dart';
import '../model/course_result.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<CourseResult> courseResults = [];
  int nextResultId = 1;
  static const int minScore = 0;
  static const int maxScore = 100;
 
  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $student already exists');
    }

    students.add(Student(id: studentId, name: studentName));
  }
 
 
  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    // 1- Remove student from the students list
    students.removeWhere((student) => student.id == studentId);
    for (final course in courses) {
      course.studentIds.remove(studentId);
    }
    courseResults.removeWhere((result) => result.studentId == studentId);
 
  }

  void addCourse({required String courseId, required String courseName}) {
    Course? course = _findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $courseId already exists');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  void removeCourse({required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (course.studentIds.isNotEmpty) {
      throw Exception('Course $courseId still has enrolled students');
    }
    courseResults.removeWhere((result) => result.courseId == courseId);
    courses.remove(course);
  }

  void enrollStudent({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    Course? course = _findCourseOrNull(courseId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId already enrolled in $courseId');
    }
    course.studentIds.add(studentId);
  }

  void discardStudentFromCourse({
    required String studentId,
    required String courseId,
  }) {
    Student? student = _findStudentOrNull(studentId);
    Course? course = _findCourseOrNull(courseId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in $courseId');
    }
    course.studentIds.remove(studentId);
    courseResults.removeWhere(
      (result) => result.studentId == studentId && result.courseId == courseId,
    );
  }

  String addResult({
    required String studentId,
    required String courseId,
    required int score,
  }) {
    Student? student = _findStudentOrNull(studentId);
    Course? course = _findCourseOrNull(courseId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    if (course == null) {
      throw Exception('Course $courseId not found');
    }
    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }
    if (score < minScore || score > maxScore) {
      throw Exception('Score must be between $minScore and $maxScore');
    }
    final alreadyHasResult = courseResults.any(
      (r) => r.studentId == studentId && r.courseId == courseId,
    );
    if (alreadyHasResult) {
      throw Exception(
        'Student $studentId already has a result for course $courseId',
      );
    }

    final result = CourseResult(
      id: 'R${nextResultId++}',
      studentId: studentId,
      courseId: courseId,
      score: score,
    );
    courseResults.add(result);
    return result.id;
  }

  void removeResult({required String resultId}) {
    final resultIndex = courseResults.indexWhere(
      (result) => result.id == resultId,
    );
    if (resultIndex == -1) {
      throw Exception('Result $resultId not found');
    }
    courseResults.removeAt(resultIndex);
  }

  Student? getStudentById(String studentId) => _findStudentOrNull(studentId);

  Course? getCourseById(String courseId) => _findCourseOrNull(courseId);

  List<CourseResult> getResultsForStudent(String studentId) {
    return courseResults
        .where((result) => result.studentId == studentId)
        .toList();
  }

  CourseResult? getResultById(String resultId) {
    for (final result in courseResults) {
      if (result.id == resultId) {
        return result;
      }
    }
    return null;
  }

  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  } 

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) {
        return c;
      }
    }
    return null;
  }
}