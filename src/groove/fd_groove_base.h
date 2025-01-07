#ifndef HEADER_fd_src_groove_fd_groove_base_h
#define HEADER_fd_src_groove_fd_groove_base_h

#include "../util/fd_util.h"

/* fd_groove error codes **********************************************/

/* Note: Harmonized with fd_*_para error codes */

#define FD_GROOVE_SUCCESS     (0)
#define FD_GROOVE_ERR_INVAL   (-1)
#define FD_GROOVE_ERR_AGAIN   (-2)
#define FD_GROOVE_ERR_CORRUPT (-3)
#define FD_GROOVE_ERR_EMPTY   (-4)
#define FD_GROOVE_ERR_FULL    (-5)
#define FD_GROOVE_ERR_KEY     (-6)

FD_PROTOTYPES_BEGIN

/* fd_groove_strerror converts an FD_GROOVE_SUCCESS / FD_GROOVE_ERR_*
   code into a human readable cstr.  The lifetime of the returned
   pointer is infinite.  The returned pointer is always to a non-NULL
   cstr. */

FD_FN_CONST char const *
fd_groove_strerror( int err );

FD_PROTOTYPES_END

/* fd_groove_key ******************************************************/

/* A fd_groove_key_t identifies a groov record.  Compact binary keys
   are encouraged but a cstr can be used so long as it has
   strlen(cstr)<FD_FUNK_REC_KEY_FOOTPRINT and the characters c[i] for i
   in [strlen(cstr),FD_FUNK_REC_KEY_FOOTPRINT) zero.  (Also, if encoding
   a cstr in a key, recommend using first byte to encode the strlen for
   accelerating cstr operations further but this is up to the user.) */

/* FIXME: binary compat with funk key? */
/* FIXME: consider aligning key 16 or 32 and/or AVX accelerating? */

#define FD_GROOVE_KEY_ALIGN     (8UL)
#define FD_GROOVE_KEY_FOOTPRINT (32UL)

union __attribute__((aligned(FD_GROOVE_KEY_ALIGN))) fd_groove_key {
  char   c[ FD_GROOVE_KEY_FOOTPRINT ];
  uchar uc[ FD_GROOVE_KEY_FOOTPRINT ];
  ulong ul[ FD_GROOVE_KEY_FOOTPRINT / sizeof(ulong) ];
};

typedef union fd_groove_key fd_groove_key_t;

FD_PROTOTYPES_BEGIN

/* fd_groove_key_eq tests keys ka and kb for equality.  Assumes ka and
   kb point in the caller's address space to valid keys for the duration
   of the call.  Retains no interest in ka or kb.  Returns 1 if the keys
   are equal and 0 otherwise. */

FD_FN_PURE static inline int
fd_groove_key_eq( fd_groove_key_t const * ka,
                  fd_groove_key_t const * kb ) {
  ulong const * a = ka->ul;
  ulong const * b = kb->ul;
  return !(((a[0]^b[0]) | (a[1]^b[1])) | ((a[2]^b[2]) | (a[3]^b[3]))); /* tons of ILP and vectorizable */
}

/* fd_groove_key_hash provides a family of hashes that hash the key
   pointed to by k to a uniform quasi-random 64-bit integer.  seed
   selects the particular hash function to use and can be an arbitrary
   64-bit value.  The hash functions are high quality but not
   cryptographically secure.  Assumes ka points in the caller's address
   space to a valid key for the duration of the call.  Retains no
   interest in ka.  Returns the hash. */

FD_FN_UNUSED FD_FN_PURE static ulong /* Workaround -Winline */
fd_groove_key_hash( fd_groove_key_t const * ka,
                    ulong                   seed ) {
  ulong const * a = ka->ul;
  return (fd_ulong_hash( a[0] ^ seed ) ^ fd_ulong_hash( a[1] ^ seed )) ^
         (fd_ulong_hash( a[2] ^ seed ) ^ fd_ulong_hash( a[3] ^ seed )); /* tons of ILP and vectorizable */
}

FD_PROTOTYPES_END

#endif /* HEADER_fd_src_groove_fd_groove_base_h */
