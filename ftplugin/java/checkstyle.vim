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

function! s:RunCheckstyle()
  let old_errorformat = &errorformat
  try
    let checkstyle_cmd = printf('java -cp %s %s -c %s %s',
	\  shellescape(g:Checkstyle_Classpath),
	\  "com.puppycrawl.tools.checkstyle.Main",
	\  shellescape(g:Checkstyle_XML),
	\  shellescape(expand("%:p")))
    let output = system(checkstyle_cmd)
    if v:shell_error != 0
      echohl ErrorMsg | echo iconv(output, 'default', &encoding) | echohl None
      return
    endif
    set errorformat=%f:%l:%c:\ %m,%f:%l:\ %m,%-G%.%#
    cexpr output
    if len(getqflist()) > 0
      copen | cc
    else
      cclose
    endif
  finally
    let &errorformat = old_errorformat
  endtry
endfunction

command! -nargs=* Checkstyle call s:RunCheckstyle()

