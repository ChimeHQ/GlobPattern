import XCTest
import GlobPattern

final class ParserTests: XCTestCase {
	func testSimpleString() throws {
		let nodes = try Parser().parse("abc")

		let expected: [Parser.Node] = [
			.string("abc")
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEscapedString() throws {
		let nodes = try Parser().parse("a\\*b\\?c\\[d\\{e\\\\")

		let expected: [Parser.Node] = [
			.string("a*b?c[d{e\\")
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEscapedFirstElementString() throws {
		let nodes = try Parser().parse("\\*")

		let expected: [Parser.Node] = [
			.string("*")
		]

		XCTAssertEqual(nodes, expected)
	}

	func testRunMatch() throws {
		let nodes = try Parser().parse("* **")

		let expected: [Parser.Node] = [
			.runMatch(false),
			.string(" "),
			.runMatch(true),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testCharacterMatch() throws {
		let nodes = try Parser().parse("?")

		let expected: [Parser.Node] = [
			.characterMatch
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEmptyCharacterClass() throws {
		let nodes = try Parser().parse("[]")

		let expected: [Parser.Node] = [
			.characterClass(false, []),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testNegatedEmptyCharacterClass() throws {
		let nodes = try Parser().parse("[!]")

		let expected: [Parser.Node] = [
			.characterClass(true, []),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testSingleCharacterClass() throws {
		let nodes = try Parser().parse("[a]")

		let expected: [Parser.Node] = [
			.characterClass(false, ["a"]),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testMultipleCharacterClass() throws {
		let nodes = try Parser().parse("[abc]")

		let expected: [Parser.Node] = [
			.characterClass(false, ["a", "b", "c"]),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testNegatedCharacterClass() throws {
		let nodes = try Parser().parse("[!abc]")

		let expected: [Parser.Node] = [
			.characterClass(true, ["a", "b", "c"]),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEscapedNegatedCharacterClass() throws {
		let nodes = try Parser().parse("[\\!]")

		let expected: [Parser.Node] = [
			.characterClass(false, ["!"]),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEmptyGroup() throws {
		let nodes = try Parser().parse("{}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testSingleElementGroup() throws {
		let nodes = try Parser().parse("{a}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEscapedCommaGroup() throws {
		let nodes = try Parser().parse("{a\\,}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a,")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEscapedCloseBraceGroup() throws {
		let nodes = try Parser().parse("{a\\}}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a}")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testEscapedOpenBraceGroup() throws {
		let nodes = try Parser().parse("{a\\{}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a{")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testTwoChoicesGroup() throws {
		let nodes = try Parser().parse("{a,b}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a"), .string("b")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testFirstChoiceEmptyGroup() throws {
		let nodes = try Parser().parse("{,b}")

		let expected: [Parser.Node] = [
			.group(.choice([.string(""), .string("b")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testSecondChoiceEmptyGroup() throws {
		let nodes = try Parser().parse("{a,}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a"), .string("")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testAllChoiceEmptyGroup() throws {
		let nodes = try Parser().parse("{,}")

		let expected: [Parser.Node] = [
			.group(.choice([.string(""), .string("")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testTreeChoiceGroup() throws {
		let nodes = try Parser().parse("{a,b,c}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a"),
							.string("b"),
							.string("c")]))
		]

		XCTAssertEqual(nodes, expected)
	}

	func testFirstNestedGroup() throws {
		let nodes = try Parser().parse("{{a,b},c}")

		let expected: [Parser.Node] = [
			.group(
				.choice([
					.choice([
						.string("a"),
						.string("b"),
					]),
					.string("c"),
				])
			),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testSecondNestedGroup() throws {
		let nodes = try Parser().parse("{a,{b,c}}")

		let expected: [Parser.Node] = [
			.group(.choice([.string("a"),
							.choice([
								.string("b"),
								.string("c")])])),
		]

		XCTAssertEqual(nodes, expected)
	}

	func testRange() throws {
		let nodes = try Parser().parse("{1..10}")

		let expected: [Parser.Node] = [
			.range(1, 10)
		]

		XCTAssertEqual(nodes, expected)
	}

	func testFirstNegativeRange() throws {
		let nodes = try Parser().parse("{-1..10}")

		let expected: [Parser.Node] = [
			.range(-1, 10)
		]

		XCTAssertEqual(nodes, expected)
	}

	func testBothNegativeRange() throws {
		let nodes = try Parser().parse("{-10..-1}")

		let expected: [Parser.Node] = [
			.range(-10, -1)
		]

		XCTAssertEqual(nodes, expected)
	}
}

