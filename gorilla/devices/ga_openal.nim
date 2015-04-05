 {.deadCodeElim: on.}
# Dynamically link to the correct library for our system: 

when defined(windows): 
  const 
    gorillalib* = "gorilla.dll"
elif defined(macosx): 
  const 
    gorillalib* = "gorilla.dylib"
else: 
  const 
    gorillalib* = "gorilla.so"
# Remove prefixes in our wrapper, we have modules in Nim: 
# These are not recognized by c2nim, but that's easy to fix: 

#* OpenAL Device Implementation.
# 
#   \file ga_openal.h
# 

import 
  ../ga_internal

type 
  ga_DeviceImpl_OpenAl* = object 
    devType*: int32
    numBuffers*: int32
    numSamples*: int32
    format*: ga_Format
    dev*: ptr ALCdevice_struct
    context*: ptr ALCcontext_struct
    hwBuffers*: ptr uint32
    hwSource*: uint32
    nextBuffer*: uint32
    emptyBuffers*: uint32


proc gaX_device_open_openAl*(in_numBuffers: int32; in_numSamples: int32; 
                             in_format: ptr ga_Format): ptr ga_DeviceImpl_OpenAl {.
    cdecl, importc: "gaX_device_open_openAl", dynlib: gorillalib.}
proc gaX_device_check_openAl*(in_device: ptr ga_DeviceImpl_OpenAl): int32 {.
    cdecl, importc: "gaX_device_check_openAl", dynlib: gorillalib.}
proc gaX_device_queue_openAl*(in_device: ptr ga_DeviceImpl_OpenAl; 
                              in_buffer: pointer): gc_result {.cdecl, 
    importc: "gaX_device_queue_openAl", dynlib: gorillalib.}
proc gaX_device_close_openAl*(in_device: ptr ga_DeviceImpl_OpenAl): gc_result {.
    cdecl, importc: "gaX_device_close_openAl", dynlib: gorillalib.}