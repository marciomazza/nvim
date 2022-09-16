import vim
from jedi import Script, get_default_project


def get_jedi_completions():
    row, column = vim.current.window.cursor
    current_line = vim.current.buffer[row - 1]
    lines = vim.current.buffer[: row - 1] + [current_line[:column]]
    source = "\n".join(lines)
    path = vim.current.buffer.name
    project = get_default_project(path)
    script = Script(source, path=path, project=project)
    completions = script.complete(row, column)
    result = [dict(name=c.name, type=c.type) for c in completions]
    return result
