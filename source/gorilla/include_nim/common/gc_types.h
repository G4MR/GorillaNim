#ifdef C2NIM
#  dynlib gorillalib
#  cdecl

/* Dynamically link to the correct library for our system: */
#  if defined(windows)
#    define gorillalib "gorilla.dll"
#  elif defined(macosx)
#    define gorillalib "gorilla.dylib"
#  else
#    define gorillalib "gorilla.so"
#  endif

/* These are not recognized by c2nim, but that's easy to fix: */
#  mangle gc_uint8 uint8
#  mangle gc_uint16 uint16
#  mangle gc_uint32 uint32
#  mangle gc_uint64 uint64
#  mangle gc_int8 int8
#  mangle gc_int16 int16
#  mangle gc_int32 int32
#  mangle gc_int64 int64
#  mangle gc_float32 float32
#  mangle gc_float64 float64
#endif
/** Common Types.
 *
 *  Cross-platform primitive type definitions.
 *
 *  \file gc_types.h
 */


/*********************/
/**  Result Values  **/
/*********************/
/** Result Values
 *
 *  \ingroup common
 *  \defgroup results Result Values
 */

typedef gc_int32 gc_result; /**< Return type for the result of an operation. \ingroup results */

#define GC_FALSE 0 /**< Result was false. \ingroup results */
#define GC_TRUE 1 /**< Result was true. \ingroup results */
#define GC_SUCCESS 1 /**< Operation completed successfully. \ingroup results */
#define GC_ERROR_GENERIC -1 /**< Operation failed with an unspecified error. \ingroup results */

