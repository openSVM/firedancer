#ifndef HEADER_fd_src_groove_fd_groove_meta_h
#define HEADER_fd_src_groove_fd_groove_meta_h

#include "fd_groove_base.h"

/* FIXME: consider if memoizing is worth speed / footprint tradeoff */

#define FD_GROOVE_META_FLAG_USED (1<<0)
#define FD_GROOVE_META_FLAG_COLD (1<<1)
#define FD_GROOVE_META_FLAG_HOT  (1<<2)

struct fd_groove_meta {
  fd_groove_key_t key;
  int             flags;   /* Account metadata */
  uint            val_sz;  /* Size of the account */
  ulong           val_off; /* Location of the account in cold store */
};

typedef struct fd_groove_meta fd_groove_meta_t;

#define  MAP_NAME                  fd_groove_meta_map
#define  MAP_ELE_T                 fd_groove_meta_t
#define  MAP_KEY_T                 fd_groove_key_t
#define  MAP_KEY_EQ                fd_groove_key_eq
#define  MAP_KEY_HASH              fd_groove_key_hash
#define  MAP_ELE_IS_FREE(ctx,ele)  (!((ele)->flags & FD_GROOVE_META_FLAG_USED))
#define  MAP_ELE_FREE(ctx,ele)     do (ele)->flags = 0; while(0)
#define  MAP_ELE_MOVE(ctx,dst,src) do { fd_groove_meta_t * _src = (src); *(dst) = *_src; _src->flags = 0; } while(0)
#define  MAP_VERSION_T             ushort
#define  MAP_LOCK_MAX              (8192)
#define  MAP_MAGIC                 (0xfd67007e3e7a3a90) /* fd groove meta map version 0 */
#define  MAP_IMPL_STYLE            1
#include "../util/tmpl/fd_map_slot_para.c"

#endif /* HEADER_fd_src_groove_fd_groove_meta_h */
