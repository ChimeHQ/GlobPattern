#if canImport(Darwin.C)
import Darwin.C
#elseif canImport(Glibc)
import Glibc
#else
#error("unsupported platform")
#endif

public enum Glob {
	/// Control how glob patterns are intrepreted.
	public enum Mode {
		/// Strictly follow glob patterns only
		case strict

		/// Glob patterns with brace choice expansions
		case grouping

		/// Glob patterns as defined by the editorconfig spec
		case editorconfig
	}

	/// Represents a glob pattern
	public struct Pattern {
		private let patternString: String
		private let nodes: [Parser.Node]
		private let mode: Glob.Mode

		public init(_ string: String, mode: Glob.Mode = .strict) throws {
			self.patternString = string
			self.mode = mode

			if case .strict = mode {
				self.nodes = []
			} else {
				self.nodes = try Parser().parse(string)
			}
		}

		public func match(_ string: String) -> Bool {
			return (try? fnMatchResult(string)) ?? false
		}

		private func fnMatchResult(_ string: String) throws -> Bool {
			let value = string.withCString { nameCStr in
				patternString.withCString { patternCStr in
					fnmatch(patternCStr, nameCStr, 0)
				}
			}

			if value == 0 {
				return true
			}

			if value == FNM_NOMATCH {
				return false
			}

			// something else is wrong

			return false
		}
	}
}
