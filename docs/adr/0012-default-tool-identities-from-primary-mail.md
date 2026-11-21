# Default tool identities from primary mail

Status: accepted. Supersedes [ADR 0009](0009-keep-tool-identities-independent-of-mail.md).

When an existing primary mail account supplies a name and address, use them by default for Git authorship, and use its address for rbw. Explicit native tool settings override these defaults. Without a primary account, no tool identity is inferred; a mail account is not required to use Git or to configure rbw explicitly.

This reduces repeated configuration for consumers who use the same identity across tools. It also means a primary mail change changes any inherited tool identity. Consumers with a separate work author or vault account should pin those native settings. The default never enables mail, Git or rbw by itself.
