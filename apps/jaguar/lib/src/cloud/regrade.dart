import 'package:jaguar_core/jaguar_core.dart';

import 'cloud_backend.dart';

/// A submission as the teacher's app checks it again.
///
/// What a student sends says how many tests passed, but the student writes
/// that number, so it proves nothing. The teacher's app runs the student's
/// program against every test of the assignment, the hidden ones included
/// (which only the teacher has), and shows that result.
class GradedSubmission {
  const GradedSubmission({required this.submission, required this.passed, required this.total, this.syntaxError});

  final Submission submission;

  /// What the teacher's check found.
  final int passed;
  final int total;

  /// Set when the program does not even parse.
  final JaguarError? syntaxError;

  bool get complete => total > 0 && passed == total;

  /// The student said more than the check found.
  bool get overstated => submission.passed > passed || submission.total != total;
}

/// Runs [submission] against every test of [assignment].
Future<GradedSubmission> regrade(Assignment assignment, Submission submission) async {
  final result = await checkSolution(submission.source, assignment.exercise);
  return GradedSubmission(
    submission: submission,
    passed: result.passedCount,
    total: assignment.exercise.cases.length,
    syntaxError: result.syntaxError,
  );
}

/// [regrade] for all the submissions of an assignment, keyed like [submissions].
Future<Map<String, GradedSubmission>> regradeAll(Assignment assignment, Map<String, Submission> submissions) async => {
  for (final entry in submissions.entries) entry.key: await regrade(assignment, entry.value),
};
