; extends
;
; JavaScript injections for Python files.
; Enables JS syntax highlighting inside Python strings that contain JavaScript,
; covering four patterns used in this codebase:
;   1. Strings assigned to a variable named `js`
;   2. String literals passed directly to .eval() or .eval_async()
;   3. Strings returned from functions whose name ends in `js`
;   4. pytest.mark.parametrize lists where a fixture name ends in `js`

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

; Inject into strings returned from functions whose name ends in js
(function_definition
  name: (identifier) @_fn
  (#match? @_fn "js$")
  body: (block
    (return_statement
      (string
        (string_content) @injection.content))
    (#set! injection.language "javascript")))

; --------------------------------------------------------------------------------
; pytest.mark.parametrize
; --------------------------------------------------------------------------------

; Inject into parametrize list strings when the fixture name ends in js
; Single fixture: direct strings in the list
(decorator
  (call
    arguments: (argument_list
      (string (string_content) @_name (#match? @_name "^[^,]*js\\s*$"))
      (list
        (string
          (string_content) @injection.content))))
  (#set! injection.language "javascript"))

; Multiple fixtures, js is first: capture first string in each tuple/list
(decorator
  (call
    arguments: (argument_list
      (string (string_content) @_name (#match? @_name "^[^,]*js\\s*,"))
      (list
        (_
          . (string (string_content) @injection.content)
          (_)))))
  (#set! injection.language "javascript"))

; Multiple fixtures, js is middle: capture middle string in each tuple/list
(decorator
  (call
    arguments: (argument_list
      (string (string_content) @_name (#match? @_name ",\\s*[^,]*js\\s*,"))
      (list
        (_
          (_)
          (string (string_content) @injection.content)
          (_)))))
  (#set! injection.language "javascript"))

; Multiple fixtures, js is last: capture last string in each tuple/list
(decorator
  (call
    arguments: (argument_list
      (string (string_content) @_name (#match? @_name ",\\s*[^,]*js\\s*$"))
      (list
        (_
          (_)
          (string (string_content) @injection.content) .))))
  (#set! injection.language "javascript"))
