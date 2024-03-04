; extends

((call
  function: [
             (identifier) @_iden
             (attribute (identifier) @_iden)
             ]
  arguments: (argument_list
               (_)
               (string (string_content) @injection.content)
    )
  (#eq? @_iden "ReplaceableObject")
  (#set! injection.language "sql"))
  )

