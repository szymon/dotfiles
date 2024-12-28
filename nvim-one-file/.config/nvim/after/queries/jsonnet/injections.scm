[(string_content) @injection.content @data
                  (#contains? @data "tf=python")
                  (#set! injection.language "python")]


[(string_content) @injection.content @data
                  (#contains? @data "tf=yaml")
                  (#set! injection.language "yaml")]
