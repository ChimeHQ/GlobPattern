class StringLexer {
	let string: String
	var index: String.Index

	init(_ string: String) {
		self.string = string
		self.index = string.startIndex
	}

	func peek() -> Character? {
		if index >= string.endIndex {
			return nil
		}

		return string[index]
	}

	func peekLoop(escaping: Bool = true, _ block: (Character, Bool) throws -> Bool) throws {
		var escaped = false

		for _ in 0..<1000 {
			guard let char = peek() else {
				return
			}

			if char == "\\" && escaped == false && escaping {
				escaped = true
				next()
				continue
			}

			let current = index

			if try block(char, escaped) == false {
				break
			}

			if escaped {
				escaped = false
			}

			if index <= current {
				throw Parser.Failure.parseStuck
			}

			if index == string.endIndex {
				return
			}
		}
	}

	@discardableResult
	func next() -> Character? {
		let char = peek()

		if index < string.endIndex {
			index = string.index(after: index)
		}

		return char
	}

	func expectNext(_ character: Character) throws {
		let char = try expectNext()

		guard char == character else { throw Parser.Failure.unexpected(char) }
	}

	func expectNext() throws -> Character {
		guard let char = next() else { throw Parser.Failure.endOfString }

		return char
	}
}
