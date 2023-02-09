# GlobPattern
Swift package to parse and evaluate glob patterns

## Why does this exist?

Glob patterns can be matched with the C function `fnmatch`, and files can be located with `glob` so why make this at all?

Well, it turns out that a bunch of systems use glob patterns with extensions. The most common one is grouping, which is all handled by the shell. I'm not sure if this is just an oversight, but these "glob" patterns won't actually work right with the C library functions.

- Language Server Protocol: uses "{}" grouping
- editorconfig: uses "{}" grouping AND a custom range notation

This library offers three modes - `fnmatch-compatible`, `grouping`, and `grouping-with-ranges`. It provides both parsing and evaluation, making it much more efficient than relying on `glob` + shell expansion. It's also just more convenient.

## Contributing and Collaboration

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

## Suggestions and Feedback

I'd love to hear from you! Get in touch via [mastodon](https://mastodon.social/@mattiem), an issue, or a pull request.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).
