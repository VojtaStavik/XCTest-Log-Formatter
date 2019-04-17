#!/usr/bin/env xcrun -sdk macosx swift

import Foundation

// MARK: - -------====================== Patterns ======================--------

extension String {
  /// Tries to match the provided regex pattern.
  ///
  /// - Parameter regex: The regex pattern to match.
  /// - Returns: The array of matches. The resulting
  ///     array is empty when no matches were found.
  func getMatches(regex: String) -> [String] {
    let nsrange = NSRange(self.startIndex..<self.endIndex, in: self)
    let regex = try! NSRegularExpression(pattern: regex, options: [])

    var result: [String] = []

    regex.enumerateMatches(in: self, options: [], range: nsrange) { (match, _, _) in
      for i in 0..<match!.numberOfRanges {
        let match = String(self[Range(match!.range(at: i), in: self)!])
        result.append(match)
      }
    }

    return result
  }
}

/// The matcher for the Test Suite started line.
///
/// Matches:
///   "Test Suite 'xxx' started at 2019-04-15 16:54:46.160"
///
/// - Parameters:
///   - line: The string to be searched.
///   - action: The callback called when the match is successful.
///   - name: The name of the suite 'xxx'.
func suiteStarted(_ line: String, action: (_ name: String) -> Void) {
  let pattern = #"Test Suite '(.*)' started"#
  let matches = line.getMatches(regex: pattern)
  guard matches.isEmpty == false else { return }

  let name = matches[1]
  action(name)
}

/// The matcher for the Test case started line.
///
/// Matches:
///   "Test Case '-[xxx yyy]' started."
///
/// - Parameters:
///   - line: The string to be searched.
///   - action: The callback called when the match is successful.
///   - name: The name of the case 'yyy'.
///
func caseStarted(_ line: String, action: (_ name: String) -> Void) {
  let pattern = #"Test Case '-\[(.*) (.*)\]' started"#
  let matches = line.getMatches(regex: pattern)
  guard matches.isEmpty == false else { return }

  let name = matches[2]
  action(name)
}

/// The matcher for the Test case passed line.
///
/// Matches:
///   "Test Case '-[xxx yyy]' passed (zzz seconds)."
///
/// - Parameters:
///   - line: The string to be searched.
///   - action: The callback called when the match is successful.
///   - suite: The name of the suite 'xxx'.
///   - name: The name of the case 'yyy'.
///   - duration: The duration of the case 'zzz'.
func casePassed(_ line: String, action: (_ suite: String, _ name: String, _ duration: String) -> Void) {
  let pattern = #"(?:Test Case) '-\[(.*) (.*)\]' passed \((\w+.\w+) seconds\)"#
  let matches = line.getMatches(regex: pattern)
  guard matches.isEmpty == false else { return }

  let suite = matches[1]
  let name = matches[2]
  let duration = matches[3]

  action(suite, name, duration)
}

/// The matcher for the Test case failed line.
///
/// Matches:
///   "Test Case '-[xxx yyy]' failed (zzz seconds)."
///
/// - Parameters:
///   - line: The string to be searched.
///   - action: The callback called when the match is successful.
///   - suite: The name of the suite 'xxx'.
///   - name: The name of the case 'yyy'.
///   - duration: The duration of the case 'zzz'.
func caseFailed(_ line: String, action: (_ suite: String, _ name: String, _ duration: String) -> Void) {
  let pattern = #"(?:Test Case) '-\[(.*) (.*)\]' failed \((\w+.\w+) seconds\)"#
  let matches = line.getMatches(regex: pattern)
  guard matches.isEmpty == false else { return }

  let suite = matches[1]
  let name = matches[2]
  let duration = matches[3]

  action(suite, name, duration)
}

// MARK: - -------====================== Terminal output formatting ======================--------

func print(_ string: String) {
  if let data = (string + "\n").data(using: .utf8) {
    FileHandle.standardOutput.write(data)
  }
}

func bold(_ string: String) -> String { return "\u{001B}[1m\(string)\u{001B}[22m" }
func italic(_ string: String) -> String { return "\u{001B}[3m\(string)\u{001B}[23m" }

func green(_ string: String) -> String { return "\u{001B}[32m\(string)\u{001B}[0m" }
func red(_ string: String) -> String { return "\u{001B}[31m\(string)\u{001B}[0m" }
func darkGrayBackground(_ string: String) -> String { return "\u{001B}[100m\(string)\u{001B}[0m" }

let passed = green("✓")
let failed = bold(red("✗"))

// MARK: - -------====================== Main Loop ======================--------

var totalNumberOfTests = 0
var failingTests: [String] = []

var currentCaseRawLog: [String] = []

while let line = readLine() {

   // Save the line to the current raw log
  currentCaseRawLog.append(line)

  suiteStarted(line) { name in
    print("\n  \(bold(name))")
  }

  caseStarted(line) { _ in
    // Clear the raw log
    currentCaseRawLog = [line]
    totalNumberOfTests += 1
  }

  casePassed(line) { _, caseName, durationString in
    let duration = italic("(\(durationString) sec)")
    print("    \(passed) \(caseName) \(duration)")
  }

  caseFailed(line) { suiteName, caseName, durationString in
    failingTests.append("\(suiteName) \(caseName)")

    // print the raw log for the failing test
    let log = "\n" + currentCaseRawLog.joined(separator: "\n")
    print(bold(darkGrayBackground(log)))

    print("    \(failed) \(red("\(caseName) \(italic("(\(durationString) sec)"))"))")
  }
}

// MARK: - -------====================== Summary ======================--------

print("\n══════════════════════════════════════════════════════════════════════════════")
switch true {
case _ where totalNumberOfTests == 0:
  print("  ❌ No tests executed.")

case _ where failingTests.isEmpty:
  print("  ✅ \(totalNumberOfTests) tests passed.")

default:
  print("  ❌ \(totalNumberOfTests) tests passed, \(failingTests.count) failed:")
  failingTests.forEach { print("\t\(red($0))") }
}
print("══════════════════════════════════════════════════════════════════════════════")
