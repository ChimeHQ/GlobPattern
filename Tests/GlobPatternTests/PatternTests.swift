import XCTest
import GlobPattern

final class PatternTests: XCTestCase {
	func testStrictMode() throws {
		let pattern = try Glob.Pattern("ab*", mode: .strict)

		XCTAssertTrue(pattern.match("abc"))
		XCTAssertTrue(pattern.match("abd"))
	}

	func testStrictModeWithGrouping() throws {
		let pattern = try Glob.Pattern("ab{c,d}", mode: .strict)

		XCTAssertFalse(pattern.match("abc"))
		XCTAssertFalse(pattern.match("abd"))

		XCTAssertTrue(pattern.match("ab{c,d}"))
	}
}
