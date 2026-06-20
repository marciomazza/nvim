; extends
;
; JavaScript injections for Python files.
; Enables JS syntax highlighting inside Python strings that contain JavaScript,
; covering three patterns used in this codebase:
;   1. Strings assigned to a variable named `js`
;   2. String literals passed directly to .eval() or .eval_async()
;   3. Strings returned from functions whose name ends in `_js`

; Inject JavaScript into strings assigned to a variable named `js`
(assignment
  left: (identifier) @_var
  (#eq? @_var "js")
  right: (string
    (string_content) @injection.content)
  (#set! injection.language "javascript"))

; Inject into direct string arguments to .eval() and .eval_async()
(call
  function: (attribute
    attribute: (identifier) @_method
    (#match? @_method "^eval(_async)?$"))
  arguments: (argument_list
    (string
      (string_content) @injection.content))
  (#set! injection.language "javascript"))

; Inject into strings returned from functions whose name ends in _js
(return_statement
  (string
    (string_content) @injection.content)
  (#set! injection.language "javascript"))
