set completefunc=cxxd#services#source_code_model#auto_completion#completefunc
let s:completions = []

function! cxxd#services#source_code_model#auto_completion#completefunc(findstart, base)
    if a:findstart
        return col('.')
    endif
    return s:completions
endfunction

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#services#source_code_model#auto_completion#run()
" Description:  Triggers the source code auto_completion in (line, column) for given filename.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#services#source_code_model#auto_completion#run_i(filename, line, column)
    if g:cxxd_src_code_model['services']['auto_completion']['enabled']
        let l:contents_filename = '/tmp/tmp_' . fnamemodify(a:filename, ':p:t')
        call cxxd#utils#serialize_current_buffer_contents(l:contents_filename)
        python cxxd.api.source_code_model_auto_completion_code_complete_request(server_handle, vim.eval('a:filename'), vim.eval('l:contents_filename'), vim.eval('a:line'), vim.eval('a:column'), vim.eval('line2byte(a:line)'))
    endif
endfunction

function! cxxd#services#source_code_model#auto_completion#run_p(filename, line, column)
    if g:cxxd_src_code_model['services']['auto_completion']['enabled']
        if cxxd#utils#is_more_modifications_done(winnr())
            let l:contents_filename = '/tmp/tmp_' . fnamemodify(a:filename, ':p:t')
            call cxxd#utils#serialize_current_buffer_contents(l:contents_filename)
            python cxxd.api.source_code_model_auto_completion_code_complete_request(server_handle, vim.eval('a:filename'), vim.eval('l:contents_filename'), vim.eval('a:line'), vim.eval('a:column'), vim.eval('line2byte(a:line)'))
        endif
    endif
endfunction

function! s:SendKeys(keys)
  " By default keys are added to the end of the typeahead buffer. If there are
  " already keys in the buffer, they will be processed first and may change the
  " state that our keys combination was sent for (e.g. <C-X><C-U><C-P> in normal
  " mode instead of insert mode or <C-e> outside of completion mode). We avoid
  " that by inserting the keys at the start of the typeahead buffer with the 'i'
  " option. Also, we don't want the keys to be remapped to something else so we
  " add the 'n' option.
  call feedkeys(a:keys, 'in')
endfunction

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#services#source_code_model#auto_completion#run_callback()
" Description:  Populates the quickfix window with source code auto_completion.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#services#source_code_model#auto_completion#run_callback(status, auto_completion_candidates)
    if a:status == v:true
        let s:completions = a:auto_completion_candidates
        setlocal completeopt-=menu
        setlocal completeopt-=preview
        setlocal completeopt+=menuone,noinsert,noselect
        setlocal complete=
        call s:SendKeys("\<C-X>\<C-U>\<C-P>")
    else
        echohl WarningMsg | echomsg 'Something went wrong with source-code-model (auto_completion) service. See Cxxd server log for more details!' | echohl None
    endif
    return ''
endfunction
