
((string_content) @injection.content
  (#match? injection.content "# lang=yaml")
  (#set! injection.language "yaml"))
