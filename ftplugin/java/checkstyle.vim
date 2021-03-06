" This is based on http://www.vim.org/scripts/script.php?script_id=448

if exists("loaded_java_checkstyle") || &cp
  finish
endif
let loaded_java_checkstyle = 1

if !exists("Checkstyle_Classpath")
  let Checkstyle_Classpath = globpath(&rtp, 'lib/checkstyle*.jar')
endif

if !exists("Checkstyle_XML")
  let Checkstyle_XML = globpath(&rtp, 'lib/sun_checks.xml')
endif

function! s:shellescape(x)
  let quote = &shellxquote == '"' ?  "'" : '"'
  return quote . fnameescape(a:x) . quote
endfunction

function! s:RunCheckstyle()
  let old_errorformat = &errorformat
  try
    let checkstyle_cmd = printf('java -cp %s %s -c %s %s',
	\  s:shellescape(g:Checkstyle_Classpath),
	\  "com.puppycrawl.tools.checkstyle.Main",
	\  s:shellescape(g:Checkstyle_XML),
	\  s:shellescape(expand("%:p")))
    let output = system(checkstyle_cmd)
    set errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,%-G%.%#
    cexpr output
    if len(getqflist()) > 0
      copen | cc
    elseif v:shell_error != 0
      echohl ErrorMsg | echo output | echohl None
    else
      cclose
    endif
  finally
    let &errorformat = old_errorformat
  endtry
endfunction

command! -nargs=* Checkstyle call s:RunCheckstyle()

