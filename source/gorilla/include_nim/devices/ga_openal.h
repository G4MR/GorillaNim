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
/** OpenAL Device Implementation.
 *
 *  \file ga_openal.h
 */

#include "../common/gc_types.h"
#include "../ga_internal.h"

typedef struct ga_DeviceImpl_OpenAl
{
  gc_int32 devType; 
  gc_int32 numBuffers; 
  gc_int32 numSamples; 
  ga_Format format;
  struct ALCdevice_struct* dev;
  struct ALCcontext_struct* context;
  gc_uint32* hwBuffers;
  gc_uint32 hwSource;
  gc_uint32 nextBuffer;
  gc_uint32 emptyBuffers;
};

ga_DeviceImpl_OpenAl* gaX_device_open_openAl(gc_int32 in_numBuffers,
                                             gc_int32 in_numSamples,
                                             ga_Format* in_format);
gc_int32 gaX_device_check_openAl(ga_DeviceImpl_OpenAl* in_device);
gc_result gaX_device_queue_openAl(ga_DeviceImpl_OpenAl* in_device,
                                  void* in_buffer);
gc_result gaX_device_close_openAl(ga_DeviceImpl_OpenAl* in_device);