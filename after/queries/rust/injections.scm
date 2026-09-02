; extends
;
; JavaScript injections for Rust files.
; Enables JS syntax highlighting inside Rust string literals (plain or raw)
; that contain JavaScript, covering:
;   1. Strings assigned to a variable ending in `js` or `JS`
;   2. Strings returned from functions whose name ends in `js`
;   3. `for <name>js in [ ... ]` loops over a list of JS strings
;   4. `for (<name>js, ...) in &[ ("...", ...), ... ]` — first field of each tuple
;   5. String arguments to `.eval()` / `.eval_async()` / `.try_eval()` /
;      `.try_eval_async()` / `.run()` / `.run_async()`
;
; Inside `format!(r#"..."#)` the upstream macro->rust injection also paints the
; raw string, so lua/js_embedded.lua re-stamps the JS token highlights on top
; at a higher priority.

; let <var>js = "..." / r#"..."# / format!(r#"..."#)
(let_declaration
  pattern: (identifier) @_var
  (#match? @_var "(js|JS)$")
  value: [
    (string_literal (string_content) @injection.content)
    (raw_string_literal (string_content) @injection.content)
    (macro_invocation
      (token_tree [
        (string_literal (string_content) @injection.content)
        (raw_string_literal (string_content) @injection.content)
      ]))
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

; rt.eval("...") / rt.try_eval_async(r#"..."#) / rt.run(&format!(r#"..."#)) etc.
(call_expression
  function: (field_expression
    field: (field_identifier) @_method
    (#match? @_method "^(try_eval|eval|run)(_async)?$"))
  arguments: (arguments [
    (string_literal (string_content) @injection.content)
    (raw_string_literal (string_content) @injection.content)
    (macro_invocation (token_tree [
      (string_literal (string_content) @injection.content)
      (raw_string_literal (string_content) @injection.content)
    ]))
    (reference_expression (macro_invocation (token_tree [
      (string_literal (string_content) @injection.content)
      (raw_string_literal (string_content) @injection.content)
    ])))
  ])
  (#set! injection.language "javascript"))

; for (<name>js, ...) in &[ ("...", ...), ... ] { ... }
; ponytail: assumes the JS string is the first field of each tuple; add
; positional variants (see python parametrize) if a middle/last field needs it.
(for_expression
  pattern: (tuple_pattern (identifier) @_var (#match? @_var "(js|JS)$"))
  value: [
    (reference_expression
      (array_expression
        (tuple_expression . [
          (string_literal (string_content) @injection.content)
          (raw_string_literal (string_content) @injection.content)
        ])))
    (array_expression
      (tuple_expression . [
        (string_literal (string_content) @injection.content)
        (raw_string_literal (string_content) @injection.content)
      ]))
  ]
  (#set! injection.language "javascript"))
