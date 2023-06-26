[![Build Status][build status badge]][build status]
[![License][license badge]][license]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

# GlobPattern

Swift package to parse and evaluate glob patterns

## Why does this exist?

Glob patterns can be matched with the C function `fnmatch`, and files can be located with `glob` so why make this at all?

Well, it turns out that a bunch of systems use "glob" patterns that do not follow the actual syntax rules of glob. The most common one is grouping, which is all handled by the shell. I've encountered this in a number of places, notably [Language Server Protocol][lsp]. I'm not sure if this is just an oversight, but these patterns won't actually work right with the C library functions.

This provides both parsing and evaluation, making it much more efficient than relying on `glob` + shell expansion. It's also just more convenient.

Supported Modes:

- `strict`: provides identical results to `fnmatch`
- `grouping`: patterns with `{}` grouping (used by LSP)
- `editorconfig`: patterns with `{}` grouping and `{}` ranges (see the [editorconfig spec][editorconfig])

## Usage

```swift
let pattern = Glob.pattern("file.{js,py}", mode: .grouping)

let result = pattern.match("file.js")
```

## Contributing and Collaboration

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

## Suggestions and Feedback

I'd love to hear from you! Get in touch via an issue or pull request.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[lsp]: https://microsoft.github.io/language-server-protocol/
[editorconfig]: https://spec.editorconfig.org
[build status]: https://github.com/ChimeHQ/GlobPattern/actions
[build status badge]: https://github.com/ChimeHQ/GlobPattern/workflows/CI/badge.svg
[license]: https://opensource.org/licenses/BSD-3-Clause
[license badge]: https://img.shields.io/github/license/ChimeHQ/GlobPattern
[platforms]: https://swiftpackageindex.com/ChimeHQ/GlobPattern
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FChimeHQ%2FGlobPattern%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/ChimeHQ/GlobPattern/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
