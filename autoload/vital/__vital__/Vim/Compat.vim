let s:save_cpo = &cpo
set cpo&vim

" Vim.Compat: Vim compatibility wrapper functions for different
" versions/patchlevels of Vim.
"
" This module is not for multiple OS compatibilities but for versions of Vim
" itself.

" e.g.)
" echo s:has_version('7.3.629')
" echo s:has_version('7.3')
if has('patch-7.4.237')
  function! s:has_version(version) abort
    let versions = split(a:version, '\.')
    if len(versions) == 2
      let vim_version = versions[0] * 100 + versions[1]
      return v:version >= vim_version
    endif
    return has('patch-' . a:version)
  endfunction
else
  function! s:has_version(version) abort
    let versions = split(a:version, '\.')
    if len(versions) == 2
      let versions += [0]
    elseif len(versions) != 3
      return 0
    endif
    let vim_version = versions[0] * 100 + versions[1]
    let patch_level = versions[2]
    return v:version > vim_version ||
    \     (v:version == vim_version &&
    \       (patch_level == 0 || has('patch' . patch_level)))
  endfunction
endif

" Patch 7.3.694
if exists('*shiftwidth')
  function! s:shiftwidth() abort
    return shiftwidth()
  endfunction
elseif s:has_version('7.3.629')
  " 7.3.629: When 'shiftwidth' is zero use the value of 'tabstop'.
  function! s:shiftwidth() abort
    return &shiftwidth == 0 ? &tabstop : &shiftwidth
  endfunction
else
  function! s:shiftwidth() abort
    return &shiftwidth
  endfunction
endif

" Patch 7.4.503
if has('patch-7.4.503')
  function! s:writefile(...) abort
    return call('writefile', a:000)
  endfunction
else
  function! s:writefile(list, fname, ...) abort
    let flags = get(a:000, 0, '')
    if flags !~# 'a'
      return writefile(a:list, a:fname, flags)
    endif
    let f = tempname()
    let r = writefile(a:list, f, substitute(flags, 'a', '', 'g'))
    if r
      return r
    endif
    if has('win32') || has('win64')
      silent! execute '!type ' . shellescape(f) '>>' . shellescape(a:fname)
    else
      silent! execute '!cat ' . shellescape(f) '>>' . shellescape(a:fname)
    endif
    if v:shell_error
      throw printf(
            \ 'vital: Vim.Compat: writefile() failed to append to "%s".',
            \ a:fname,
            \)
    endif
    return delete(f)
  endfunction
endif

" doautocmd User with <nomodeline>
if s:has_version('7.3.438')
  function! s:doautocmd(expr, ...) abort
    if get(a:000, 0, 0)
      execute 'doautocmd <nomodeline> ' . a:expr
    else
      execute 'doautocmd ' . a:expr
    endif
  endfunction
else
  function! s:doautocmd(expr, ...) abort
    execute 'doautocmd ' . a:expr
  endfunction
endif

if s:has_version('7.3.831')
  function! s:getbufvar(...) abort
    return call('getbufvar', a:000)
  endfunction
else
  function! s:getbufvar(expr, varname, ...) abort
    let v = getbufvar(a:expr, a:varname)
    return empty(v) ? get(a:000, 0, '') : v
  endfunction
endif

if s:has_version('7.3.831')
  function! s:getwinvar(...) abort
    return call('getwinvar', a:000)
  endfunction
else
  function! s:getwinvar(expr, varname, ...) abort
    let v = getwinvar(a:expr, a:varname)
    return empty(v) ? get(a:000, 0, '') : v
  endfunction
endif

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2 tw=0:
