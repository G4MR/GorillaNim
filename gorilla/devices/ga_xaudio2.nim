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

#* XAudio2 Device Implementation.
# 
#   \file ga_xaudio2.h
# 

import 
  ../ga_internal

type 
  ga_DeviceImpl_XAudio2* = object 
    devType*: int32
    numBuffers*: int32
    numSamples*: int32
    format*: ga_Format
    xa*: ptr IXAudio2
    master*: ptr IXAudio2MasteringVoice
    source*: ptr IXAudio2SourceVoice
    sampleSize*: int32
    nextBuffer*: uint32
    buffers*: ptr pointer


proc gaX_device_open_xaudio2*(in_numBuffers: int32; in_numSamples: int32; 
                              in_format: ptr ga_Format): ptr ga_DeviceImpl_XAudio2 {.
    cdecl, importc: "gaX_device_open_xaudio2", dynlib: gorillalib.}
proc gaX_device_check_xaudio2*(in_device: ptr ga_DeviceImpl_XAudio2): int32 {.
    cdecl, importc: "gaX_device_check_xaudio2", dynlib: gorillalib.}
proc gaX_device_queue_xaudio2*(in_device: ptr ga_DeviceImpl_XAudio2; 
                               in_buffer: pointer): gc_result {.cdecl, 
    importc: "gaX_device_queue_xaudio2", dynlib: gorillalib.}
proc gaX_device_close_xaudio2*(in_dev: ptr ga_DeviceImpl_XAudio2): gc_result {.
    cdecl, importc: "gaX_device_close_xaudio2", dynlib: gorillalib.}