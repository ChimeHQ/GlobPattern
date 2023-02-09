public final class Parser {
	enum Failure: Error {
		case endOfString
		case unexpected(Character)
		case parseStuck
		case invalidEscape(Character)
	}

	public enum GroupItem: Hashable, CustomStringConvertible {
		case choice([GroupItem])
		case string(String)

		public var description: String {
			switch self {
			case .choice(let items):
				let inner = items.map({ $0.description }).joined(separator: ", ")

				return "{" + inner + "}"
			case .string(let value):
				return value
			}
		}
	}

	public enum Node: Hashable {
		case string(String)
		case runMatch(Bool)
		case characterMatch
		case characterClass(Bool, Set<Character>)
		case group(GroupItem)
		case range(Int, Int)
	}

	static let numberSet = Set<Character>(["-", "0", "1", "2"])

	private var lexer: StringLexer

	public init() {
		self.lexer = StringLexer("")
	}

	public func parse(_ pattern: String) throws -> [Node] {
		self.lexer = StringLexer(pattern)

		var nodes = [Node]()

		try lexer.peekLoop(escaping: false) { char, escaped in
			switch char {
			case "{":
				nodes.append(try parseGroup())
			case "[":
				nodes.append(try parseCharacterClass())
			case "*":
				nodes.append(try parseRunMatch())
			case "?":
				lexer.next()
				nodes.append(.characterMatch)
			default:
				let str = try parseString()

				nodes.append(.string(str))
			}

			return true
		}

		return nodes
	}

	func parseRunMatch() throws -> Node {
		try lexer.expectNext("*")

		if lexer.peek() != "*" {
			return .runMatch(false)
		}

		lexer.next()

		return .runMatch(true)
	}

	func parseString(inGroup: Bool = false) throws -> String {
		var string = ""

		try lexer.peekLoop { char, escaped in
			switch char {
			case "\\":
				lexer.next()

				if escaped {
					string.append(char)
				}
			case "*", "?", "{", "[":
				if escaped == false {
					return false
				}

				lexer.next()
				string.append(char)
			case "}", ",":
				if inGroup && escaped == false {
					return false
				}

				lexer.next()
				string.append(char)
			default:
				lexer.next()

				string.append(char)
			}

			return true
		}

		return string
	}

	func parseCharacterClass() throws -> Node {
		try lexer.expectNext("[")

		var set = Set<Character>()
		let negated = lexer.peek() == "!"

		if negated {
			lexer.next()
		}

		try lexer.peekLoop { char, escaped in
			switch (char, escaped) {
			case ("]", true), ("!", true):
				break
			case ("]", false):
				return false
			case (_, true):
				throw Failure.invalidEscape(char)
			default:
				break
			}

			set.insert(try lexer.expectNext())

			return true
		}

		try lexer.expectNext("]")

		return .characterClass(negated, set)
	}

	func parseGroup() throws -> Node {
		let item = try parseGroupItem()

		guard let range = tryToParseRange(from: item) else {
			return .group(item)
		}

		return .range(range.0, range.1)
	}

	func tryToParseRange(from item: GroupItem) -> (Int, Int)? {
		guard case .choice(let array) = item else { return nil }
		guard let first = array.first, array.count == 1 else { return nil }
		guard case .string(let value) = first else { return nil }

		let components = value.split(separator: ".", maxSplits: 3, omittingEmptySubsequences: false)

		guard components.count == 3 else { return nil }
		guard components[1] == "" else { return nil }
		guard let intA = Int(components[0]) else { return nil }
		guard let intB = Int(components[2]) else { return nil }

		return (intA, intB)
	}

	func parseGroupItem() throws -> GroupItem {
		var items = [GroupItem]()
		var string = ""
		var insertEmpty = true

		try lexer.expectNext("{")

		try lexer.peekLoop() { char, escaped in
			switch (char, escaped) {
			case ("{", false):
				insertEmpty = false
				items.append(try parseGroupItem())
			case ("}", false):
				if insertEmpty {
					items.append(.string(string))
					insertEmpty = false
				}

				return false
			case (",", false):
				if insertEmpty {
					items.append(.string(string))
					string.removeAll()
				}

				insertEmpty = true
				lexer.next()
			default:
				lexer.next()

				string.append(char)
			}

			return true
		}

		try lexer.expectNext("}")

		return .choice(items)
	}
}
