import cxxd.server
from services.clang_format.clang_format import VimClangFormat
from services.clang_tidy.clang_tidy import VimClangTidy
from services.project_builder.project_builder import VimProjectBuilder
from services.source_code_model.source_code_model import VimSourceCodeModel

def get_instance(handle, args):
    vim_instance = args
    return cxxd.server.Server(
        handle,
        VimSourceCodeModel(vim_instance),
        VimProjectBuilder(vim_instance),
        VimClangFormat(vim_instance),
        VimClangTidy(vim_instance)
    )
