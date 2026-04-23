; extends

((string_scalar) @injection.content
  (#match? @injection.content "^--treesitter:lua")
  (#set! injection.language "lua"))

((block_scalar) @injection.content
    (#match? @injection.content "--treesitter:lua")
    (#set! injection.language "lua")
)

