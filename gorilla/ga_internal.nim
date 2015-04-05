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

#* Gorilla Internal Interface.
# 
#   Internal data structures and functions.
# 
#   file ga_internal.h
# 
#* defgroup internal Internal Interface
#  Internal data structures and functions used by Gorilla Audio.
# 

import 
  common/gc_common, ga, common/gc_thread

#**********
#  Device  
#**********
#* Internal device object definition.
# 
#   ingroup internal
#   defgroup intDevice Device
# 
#* Header of shared-data for all concrete device implementations.
#   
#   Stores the device type, number of buffers, number of samples, and device PCM format.
# 
#   ingroup intDevice
# 
# #define GA_DEVICE_HEADER gc_int32 devType; gc_int32 numBuffers; gc_int32 numSamples; ga_Format format;
#* Hardware device abstract data structure [\ref SINGLE_CLIENT].
# 
#   Abstracts the platform-specific details of presenting audio buffers to sound playback hardware.
# 
#   ingroup intDevice
#   warning You can only have one device open at-a-time.
#   warning Never instantiate a ga_Device directly, unless you are implementing a new concrete
#   device implementation. Instead, you should use ga_device_open().
# 

type 
  ga_Device* = object 
    devType*: int32
    numBuffers*: int32
    numSamples*: int32
    format*: ga_Format


#***************
#  Data Source  
#***************
#* Internal data source object definition.
# 
#   ingroup internal
#   defgroup intDataSource Data Source
# 
#* Data source read callback prototype.
#   
#   ingroup intDataSource
#   param in_context User context (pointer to the first byte after the data source).
#   param in_dst Destination buffer into which bytes should be read. Guaranteed to
#                 be at least (in_size * in_count) bytes in size.
#   param in_size Size of a single element (in bytes).
#   param in_count Number of elements to read.
#   return Total number of bytes read into the destination buffer.
# 

type 
  tDataSourceFunc_Read* = proc (in_context: pointer; in_dst: pointer; 
                                in_size: int32; in_count: int32): int32 {.cdecl.}

#* Data source seek callback prototype.
#   
#   ingroup intDataSource
#   param in_context User context (pointer to the first byte after the data source).
#   param in_offset Offset (in bytes) from the specified seek origin.
#   param in_origin Seek origin (see [\ref globDefs]).
#   return If seek succeeds, the callback should return 0, otherwise it should return -1.
#   warning Data sources with GA_FLAG_SEEKABLE should always provide a seek callback.
#   warning Data sources with GA_FLAG_SEEKABLE set should only return -1 in the case of
#            an invalid seek request.
#   todo Define a less-confusing contract for extending/defining this function.
# 

type 
  tDataSourceFunc_Seek* = proc (in_context: pointer; in_offset: int32; 
                                in_origin: int32): int32 {.cdecl.}

#* Data source tell callback prototype.
# 
#   ingroup intDataSource
#   param in_context User context (pointer to the first byte after the data source).
#   return The current data source read position.
# 

type 
  tDataSourceFunc_Tell* = proc (in_context: pointer): int32 {.cdecl.}

#* Data source close callback prototype.
# 
#   ingroup intDataSource
#   param in_context User context (pointer to the first byte after the data source).
# 

type 
  tDataSourceFunc_Close* = proc (in_context: pointer) {.cdecl.}

#* Abstract data source data structure [\ref MULTI_CLIENT].
# 
#   A data source is a source of binary data, such as a file or socket, that 
#   generates bytes of binary data. This data is usually piped through a sample 
#   source to generate actual PCM audio data.
# 
#   ingroup intDataSource
#   todo Design a clearer/better system for easily extending this data type.
# 

type 
  ga_DataSource* = object 
    readFunc*: tDataSourceFunc_Read #*< Internal read callback. 
    seekFunc*: tDataSourceFunc_Seek #*< Internal seek callback (optional). 
    tellFunc*: tDataSourceFunc_Tell #*< Internal tell callback (optional). 
    closeFunc*: tDataSourceFunc_Close #*< Internal close callback (optional). 
    refCount*: int32          #*< Reference count. 
    refMutex*: ptr gc_Mutex   #*< Mutex to protect reference count manipulations. 
    flags*: int32             #*< Flags defining which functionality this data source supports (see [\ref globDefs]). 
  

#* Initializes the reference count and other default values.
# 
#   Because ga_DataSource is an abstract data type, this function should not be 
#   called except when implement a concrete data source implementation.
# 
#   ingroup intDataSource
# 

proc ga_data_source_init*(in_dataSrc: ptr ga_DataSource) {.cdecl, 
    importc: "ga_data_source_init", dynlib: gorillalib.}
#*****************
#  Sample Source  
#*****************

type 
  tSampleSourceFunc_Read* = proc (in_context: pointer; in_dst: pointer; 
                                  in_numSamples: int32; 
                                  in_onSeekFunc: tOnSeekFunc; 
                                  in_seekContext: pointer): int32 {.cdecl.}
  tSampleSourceFunc_End* = proc (in_context: pointer): int32 {.cdecl.}
  tSampleSourceFunc_Ready* = proc (in_context: pointer; in_numSamples: int32): int32 {.
      cdecl.}
  tSampleSourceFunc_Seek* = proc (in_context: pointer; in_sampleOffset: int32): int32 {.
      cdecl.}
  tSampleSourceFunc_Tell* = proc (in_context: pointer; 
                                  out_totalSamples: ptr int32): int32 {.cdecl.}
  tSampleSourceFunc_Close* = proc (in_context: pointer) {.cdecl.}
  ga_SampleSource* = object 
    readFunc*: tSampleSourceFunc_Read
    endFunc*: tSampleSourceFunc_End
    readyFunc*: tSampleSourceFunc_Ready
    seekFunc*: tSampleSourceFunc_Seek # OPTIONAL 
    tellFunc*: tSampleSourceFunc_Tell # OPTIONAL 
    closeFunc*: tSampleSourceFunc_Close # OPTIONAL 
    format*: ga_Format
    refCount*: int32
    refMutex*: ptr gc_Mutex
    flags*: int32


proc ga_sample_source_init*(in_sampleSrc: ptr ga_SampleSource) {.cdecl, 
    importc: "ga_sample_source_init", dynlib: gorillalib.}
#**********
#  Memory  
#**********

type 
  ga_Memory* = object 
    data*: pointer
    size*: uint32
    refCount*: int32
    refMutex*: ptr gc_Mutex


#*********
#  Sound  
#*********

type 
  ga_Sound* = object 
    memory*: ptr ga_Memory
    format*: ga_Format
    numSamples*: int32
    refCount*: int32
    refMutex*: ptr gc_Mutex


#**********
#  Handle  
#**********

const 
  GA_HANDLE_STATE_UNKNOWN* = 0
  GA_HANDLE_STATE_INITIAL* = 1
  GA_HANDLE_STATE_PLAYING* = 2
  GA_HANDLE_STATE_STOPPED* = 3
  GA_HANDLE_STATE_FINISHED* = 4
  GA_HANDLE_STATE_DESTROYED* = 5

type 
  ga_Handle* = object 
    mixer*: ptr ga_Mixer
    callback*: ga_FinishCallback
    context*: pointer
    state*: int32
    gain*: float32
    pitch*: float32
    pan*: float32
    dispatchLink*: gc_Link
    mixLink*: gc_Link
    handleMutex*: ptr gc_Mutex
    sampleSrc*: ptr ga_SampleSource
    finished*: int32


#**********
#  Mixer  
#**********

type 
  ga_Mixer* = object 
    format*: ga_Format
    mixFormat*: ga_Format
    numSamples*: int32
    mixBuffer*: ptr int32
    dispatchList*: gc_Link
    dispatchMutex*: ptr gc_Mutex
    mixList*: gc_Link
    mixMutex*: ptr gc_Mutex

  ga_StreamManager* = object 
    streamList*: gc_Link
    streamListMutex*: ptr gc_Mutex

  ga_BufferedStream* = object 
    streamLink*: ptr gc_Link
    innerSrc*: ptr ga_SampleSource
    buffer*: ptr gc_CircBuffer
    produceMutex*: ptr gc_Mutex
    seekMutex*: ptr gc_Mutex
    readMutex*: ptr gc_Mutex
    refMutex*: ptr gc_Mutex
    refCount*: int32
    tellJumps*: gc_Link
    format*: ga_Format
    seek*: int32
    tell*: int32
    nextSample*: int32
    `end`*: int32
    flags*: int32
    bufferSize*: int32

