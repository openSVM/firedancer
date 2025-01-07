#include "fd_groove_base.h"

char const *
fd_groove_strerror( int err ) {
  switch( err ) {
  case FD_GROOVE_SUCCESS:     return "success";
  case FD_GROOVE_ERR_INVAL:   return "bad input";
  case FD_GROOVE_ERR_AGAIN:   return "try again later";
  case FD_GROOVE_ERR_CORRUPT: return "map corrupt";
  case FD_GROOVE_ERR_EMPTY:   return "map empty";
  case FD_GROOVE_ERR_FULL:    return "map too full";
  case FD_GROOVE_ERR_KEY:     return "key not found";
  default: break;
  }
  return "unknown";
}
