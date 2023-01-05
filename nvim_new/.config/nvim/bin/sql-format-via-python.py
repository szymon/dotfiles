#!/usr/bin/env python3.11

import sys

import sqlparse

contents = sys.stdin.read()

result = sqlparse.format(
    contents,
    indent_columns=True,
    reindent=True,
    keyword_case="lower",
    identifier_case="lower",
)

print(result.strip())
