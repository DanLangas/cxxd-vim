" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Our Python path has to include a parent directory of 'cxxd' submodule.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
python import os, sys, vim
python sys.path.append(vim.eval("fnamemodify(fnamemodify(expand('<sfile>:p:h'), ':h'), ':h')") + os.sep + 'lib')

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Our public interface to cxxd.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
python import cxxd.api

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" We need a handle to server to establish the communication.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
python server_handle = None

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#server#start()
" Description:  Starts cxxd server.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#server#start()
python << EOF
import os
import tempfile
import vim
import server
vim_server_name = vim.eval('v:servername')
server_handle = cxxd.api.server_start(
    server.get_instance,
    vim_server_name,
    tempfile.gettempdir() + os.sep + vim_server_name + '_server.log'
)
EOF
endfunction

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#server#stop()
" Description:  Stops cxxd server.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#server#stop()
    python cxxd.api.server_stop(server_handle, False)
endfunction

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#server#start_all_services()
" Description:  Starts all cxxd server services.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#server#start_all_services(project_root_directory)
    let l:clang_format_config_file = a:project_root_directory . '/' . g:cxxd_clang_format['config']   
    let l:compilation_db_path      = cxxd#server#discover_compilation_db(a:project_root_directory)

    if l:compilation_db_path == ''
        echo ' '
        echohl WarningMsg | echomsg 'No config file found which exposes project-specific compiler flags. Functionality will be limited!' | echohl None
        echohl MoreMsg
        echomsg 'Supported ways of providing compiler flags are:'
        for [descr, comp_db_type] in items(g:cxxd_supported_comp_db)
            echomsg '[' . comp_db_type.id . '] ' . comp_db_type.name . '  (' . comp_db_type.description . ')'
        endfor
        echohl None
        call input('Press <Enter> to continue')
    endif

    call cxxd#services#source_code_model#start(a:project_root_directory, l:compilation_db_path)
    call cxxd#services#clang_tidy#start(l:compilation_db_path)
    call cxxd#services#clang_format#start(l:clang_format_config_file)
    call cxxd#services#project_builder#start(a:project_root_directory)
endfunction

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#server#stop_all_services()
" Description:  Stops all cxxd server services.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#server#stop_all_services(subscribe_for_shutdown_callback)
    call cxxd#services#source_code_model#stop(a:subscribe_for_shutdown_callback)
    call cxxd#services#clang_tidy#stop(a:subscribe_for_shutdown_callback)
    call cxxd#services#clang_format#stop(a:subscribe_for_shutdown_callback)
    call cxxd#services#project_builder#stop(a:subscribe_for_shutdown_callback)
endfunction

" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Function:     cxxd#server#discover_compilation_db()
" Description:  Discovers compilation database, if any.
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! cxxd#server#discover_compilation_db(project_root_directory)
    let l:compilation_db_json = a:project_root_directory . '/' . g:cxxd_supported_comp_db['json']['name']
    let l:compilation_db_txt  = a:project_root_directory . '/' . g:cxxd_supported_comp_db['txt']['name']

    if filereadable(l:compilation_db_json)
        return l:compilation_db_json
    elseif filereadable(l:compilation_db_txt)
        return l:compilation_db_txt
    else
        return ''
    endif
endfunction

