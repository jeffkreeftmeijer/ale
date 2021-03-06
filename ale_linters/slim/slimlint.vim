" Author: Markus Doits - https://github.com/doits
" Description: slim-lint for Slim files

function! ale_linters#slim#slimlint#GetCommand(buffer) abort
    let l:command = 'slim-lint %t'

    let l:rubocop_config = ale#path#FindNearestFile(a:buffer, '.rubocop.yml')

    " Set SLIM_LINT_RUBOCOP_CONF variable as it is needed for slim-lint to
    " pick up the rubocop config.
    "
    " See https://github.com/sds/slim-lint/blob/master/lib/slim_lint/linter/README.md#rubocop
    if !empty(l:rubocop_config)
      if ale#Has('win32')
        let l:command = 'set SLIM_LINT_RUBOCOP_CONF=' . ale#Escape(l:rubocop_config) . ' && ' . l:command
      else
        let l:command = 'SLIM_LINT_RUBOCOP_CONF=' . ale#Escape(l:rubocop_config) . ' ' . l:command
      endif
    endif

    return l:command
endfunction

function! ale_linters#slim#slimlint#Handle(buffer, lines) abort
    " Matches patterns like the following:
    " <path>:5 [W] LineLength: Line is too long. [150/120]
    let l:pattern = '\v^.*:(\d+) \[([EW])\] (.+)$'
    let l:output = []

    for l:match in ale#util#GetMatches(a:lines, l:pattern)
        call add(l:output, {
        \   'lnum': l:match[1] + 0,
        \   'type': l:match[2],
        \   'text': l:match[3]
        \})
    endfor

    return l:output
endfunction

call ale#linter#Define('slim', {
\   'name': 'slimlint',
\   'executable': 'slim-lint',
\   'command_callback': 'ale_linters#slim#slimlint#GetCommand',
\   'callback': 'ale_linters#slim#slimlint#Handle'
\})
