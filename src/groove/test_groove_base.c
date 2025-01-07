#include "fd_groove.h"

FD_STATIC_ASSERT( FD_GROOVE_SUCCESS    == 0, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_ERR_INVAL  ==-1, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_ERR_AGAIN  ==-2, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_ERR_CORRUPT==-3, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_ERR_EMPTY  ==-4, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_ERR_FULL   ==-5, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_ERR_KEY    ==-6, unit_test );

FD_STATIC_ASSERT( FD_GROOVE_KEY_ALIGN    == 8UL, unit_test );
FD_STATIC_ASSERT( FD_GROOVE_KEY_FOOTPRINT==32UL, unit_test );

FD_STATIC_ASSERT( alignof(fd_groove_key_t)==FD_GROOVE_KEY_ALIGN,     unit_test );
FD_STATIC_ASSERT( sizeof (fd_groove_key_t)==FD_GROOVE_KEY_FOOTPRINT, unit_test );

static inline fd_groove_key_t *
fd_rng_key( fd_rng_t *        rng,
            fd_groove_key_t * k ) {
  k->ul[0] = fd_rng_ulong( rng );
  k->ul[1] = fd_rng_ulong( rng );
  k->ul[2] = fd_rng_ulong( rng );
  k->ul[3] = fd_rng_ulong( rng );
  return k;
}

int
main( int     argc,
      char ** argv ) {
  fd_boot( &argc, &argv );

  fd_rng_t rng[1]; fd_rng_join( fd_rng_new( rng, 0U, 0UL ) );

  FD_LOG_NOTICE(( "bad error code        (%i-%s)", 1,                     fd_groove_strerror( 1                     ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_SUCCESS     (%i-%s)", FD_GROOVE_SUCCESS,     fd_groove_strerror( FD_GROOVE_SUCCESS     ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_ERR_INVAL   (%i-%s)", FD_GROOVE_ERR_INVAL,   fd_groove_strerror( FD_GROOVE_ERR_INVAL   ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_ERR_AGAIN   (%i-%s)", FD_GROOVE_ERR_AGAIN,   fd_groove_strerror( FD_GROOVE_ERR_AGAIN   ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_ERR_CORRUPT (%i-%s)", FD_GROOVE_ERR_CORRUPT, fd_groove_strerror( FD_GROOVE_ERR_CORRUPT ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_ERR_EMPTY   (%i-%s)", FD_GROOVE_ERR_EMPTY,   fd_groove_strerror( FD_GROOVE_ERR_EMPTY   ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_ERR_FULL    (%i-%s)", FD_GROOVE_ERR_FULL,    fd_groove_strerror( FD_GROOVE_ERR_FULL    ) ));
  FD_LOG_NOTICE(( "FD_GROOVE_ERR_KEY     (%i-%s)", FD_GROOVE_ERR_KEY,     fd_groove_strerror( FD_GROOVE_ERR_KEY     ) ));

  for( ulong rem=1000000UL; rem; rem-- ) {
    ulong seed = fd_rng_ulong( rng );
    fd_groove_key_t ka[1]; fd_rng_key( rng, ka ); (void)fd_groove_key_hash( ka, seed );
    fd_groove_key_t kb[1]; fd_rng_key( rng, kb ); (void)fd_groove_key_hash( kb, seed );

    int eq = (ka->ul[0]==kb->ul[0]) && (ka->ul[1]==kb->ul[1]) && (ka->ul[2]==kb->ul[2]) && (ka->ul[3]==kb->ul[3]);

    FD_TEST( fd_groove_key_eq( ka, ka )== 1 ); FD_TEST( fd_groove_key_eq( ka, kb )==eq );
    FD_TEST( fd_groove_key_eq( kb, ka )==eq ); FD_TEST( fd_groove_key_eq( kb, kb )== 1 );

    memcpy( kb, ka, FD_GROOVE_KEY_FOOTPRINT ); eq = 1;

    FD_TEST( fd_groove_key_eq( ka, ka )== 1 ); FD_TEST( fd_groove_key_eq( ka, kb )==eq );
    FD_TEST( fd_groove_key_eq( kb, ka )==eq ); FD_TEST( fd_groove_key_eq( kb, kb )== 1 );
  }

  fd_rng_delete( fd_rng_leave( rng ) );

  FD_LOG_NOTICE(( "pass" ));
  fd_halt();
  return 0;
}
