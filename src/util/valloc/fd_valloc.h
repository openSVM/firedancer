#ifndef HEADER_fd_src_util_valloc_fd_valloc_h
#define HEADER_fd_src_util_valloc_fd_valloc_h

#include "../fd_util_base.h"

/* APIs to abstract memory allocators. */

typedef void * (* fd_valloc_malloc_fn_t)( void * allocator, ulong align, ulong sz );
typedef void   (* fd_valloc_free_fn_t  )( void * allocator, void * ptr );

struct fd_valloc_vtable {
  fd_valloc_malloc_fn_t malloc;
  fd_valloc_free_fn_t   free;
};

typedef struct fd_valloc_vtable fd_valloc_vtable_t;

struct fd_valloc {
  void *                     self;
  fd_valloc_vtable_t const * vt;
};

typedef struct fd_valloc fd_valloc_t;

FD_PROTOTYPES_BEGIN

extern const fd_valloc_vtable_t fd_libc_vtable;
#if FD_HAS_HOSTED
extern const fd_valloc_vtable_t fd_backtracing_vtable;
#endif

static inline FD_FN_CONST fd_valloc_t
fd_libc_alloc_virtual( void ) {
  fd_valloc_t valloc = { NULL, &fd_libc_vtable };
  return valloc;
}

static inline FD_FN_CONST fd_valloc_t
fd_null_alloc_virtual( void ) {
  fd_valloc_t valloc = { NULL, NULL };
  return valloc;
}

static inline FD_FN_CONST int
fd_is_null_alloc_virtual( fd_valloc_t valloc ) {
  return (int)(valloc.vt == NULL);
}

#if FD_HAS_HOSTED
/* The backtracing valloc is a debugging tool for tracking memory leaks in
   applications using vallocs. It can be used in combination with
   contrib/tool/leak-detector.py to find potential memory leaks. */
static inline FD_FN_CONST fd_valloc_t
fd_backtracing_alloc_virtual( fd_valloc_t * inner_valloc ) {
  fd_valloc_t valloc = { inner_valloc, &fd_backtracing_vtable };
  return valloc;
}
#endif

static inline void *
fd_valloc_malloc( fd_valloc_t valloc,
                  ulong       align,
                  ulong       sz ) {
  return valloc.vt->malloc( valloc.self, align, sz );
}

static inline void
fd_valloc_free( fd_valloc_t valloc,
                void *      ptr ) {
  valloc.vt->free( valloc.self, ptr );
}

FD_PROTOTYPES_END

#endif /* HEADER_fd_src_util_valloc_fd_valloc_h */
