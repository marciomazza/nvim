; extends
;
; JavaScript injections for Rust files.
; Enables JS syntax highlighting inside Rust string literals (plain or raw)
; that contain JavaScript, covering three patterns used in this codebase:
;   1. Strings assigned to a variable ending in `js` or `JS`
;   2. Strings returned from functions whose name ends in `js`
;   3. `for <name>js in [ ... ]` loops over a list of JS strings

; let <var>js = "..." / r#"..."#
(let_declaration
  pattern: (identifier) @_var
  (#match? @_var "(js|JS)$")
  value: [
    (string_literal (string_content) @injection.content)
    (raw_string_literal (string_content) @injection.content)
  ]
  (#set! injection.language "javascript"))

; fn <name>js(...) { ... "..." } — any string literal in the body
(function_item
  name: (identifier) @_fn
  (#match? @_fn "js$")
  body: (block [
    (string_literal (string_content) @injection.content)
    (raw_string_literal (string_content) @injection.content)
    (return_expression [
      (string_literal (string_content) @injection.content)
      (raw_string_literal (string_content) @injection.content)
    ])
  ])
  (#set! injection.language "javascript"))

; for <name>js in ["...", "..."] { ... }
(for_expression
  pattern: (identifier) @_var
  (#match? @_var "(js|JS)$")
  value: (array_expression [
    (string_literal (string_content) @injection.content)
    (raw_string_literal (string_content) @injection.content)
  ])
  (#set! injection.language "javascript"))
