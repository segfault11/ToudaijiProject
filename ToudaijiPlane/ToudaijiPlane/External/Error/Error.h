/*!
** Error handling methods.
**    
** @since 2013-08-19
*/
#ifndef ERROR_H__
#define ERROR_H__

#define CGTK_REPORT(x, y) ERR::Report(__FILE__, __LINE__, x, y);
#define CGTK_ASSERT(x) if (x) {} else {ERR::Assert(#x, __FILE__, __LINE__);}

/*
** Error codes
*/
enum
{
    CGTK_NO_ERROR = 0,
    CGTK_GL_ERROR,
    CGTK_INVALID_FILE,
    CGTK_INVALID_TEXTURE,
    CGTK_UNKNOWN_ERROR
};

namespace ERR
{
    void Report(const char* filename, int line, const char* message, int code);
    void Assert(const char* expr, const char* filename, int line);
}

#endif /* end of include guard: ERROR_H__ */