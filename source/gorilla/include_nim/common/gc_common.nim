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
# These are not recognized by c2nim, but that's easy to fix: 

#* Gorilla Common API.
# 
#   A collection of non-audio-specific classes that are common to most libraries.
# 
#   \file gc_common.h
# 
#* Common data structures and functions.
# 
#   \defgroup common Common API (GC)
# 

import 
  gc_types, gc_thread

#***********************
#*  System Operations  *
#***********************
#* System operations.
# 
#   \ingroup common
#   \defgroup gc_SystemOps System Operations
# 
#* System allocation policies [\ref POD].
# 
#   \ingroup gc_SystemOps
# 

type 
  gc_SystemOps* = object 
    allocFunc*: proc (in_size: uint32): pointer {.cdecl.}
    reallocFunc*: proc (in_ptr: pointer; in_size: uint32): pointer {.cdecl.}
    freeFunc*: proc (in_ptr: pointer) {.cdecl.}


var gcX_ops* {.importc: "gcX_ops", dynlib: gorillalib.}: ptr gc_SystemOps

#* Initialize the Gorilla library.
# 
#   This must be called before any other functions in the library.
# 
#   \ingroup gc_SystemOps
#   \param in_callbacks You may (optionally) pass in a gc_SystemOps structure
#                       to define custom allocation functions.  If you do not,
#                       Gorilla will use standard ANSI C malloc/realloc/free
#                       functions.
#   \return GC_SUCCESS if library initialized successfully. GC_ERROR_GENERIC
#           if not.
# 

proc gc_initialize*(in_callbacks: ptr gc_SystemOps): gc_result {.cdecl, 
    importc: "gc_initialize", dynlib: gorillalib.}
#* Shutdown the Gorilla library.
# 
#   Call this once you are finished using the library. After calling it,
#   do not call any functions in the library.
# 
#   \ingroup gc_SystemOps
#   \return GC_SUCCESS if the library shut down successfully. GC_ERROR_GENERIC
#           if not.
# 

proc gc_shutdown*(): gc_result {.cdecl, importc: "gc_shutdown", 
                                 dynlib: gorillalib.}
#*********************
#*  Circular Buffer  *
#*********************
#* Circular Buffer.
# 
#   \ingroup common
#   \defgroup gc_CircBuffer Circular Buffer
# 
#* Circular buffer object [\ref SINGLE_CLIENT].
# 
#   A circular buffer object that is thread-safe for single producer/single
#   consumer use cases. It assumes a single thread producing (writing)
#   data, and a single thread consuming (reading) data. The producer and 
#   consumer threads may be the same thread.
# 
#   \ingroup gc_CircBuffer
#   \warning While it can be read/written from two different threads, the
#            object’s memory management policy is Single Client, since there
#            is only one owner responsible for creation/destruction of the
#            thread.
# 

type 
  gc_CircBuffer* = object 
    data*: ptr uint8
    dataSize*: uint32
    nextAvail*: uint32
    nextFree*: uint32


#* Create a circular buffer object.
# 
#   \ingroup gc_CircBuffer
# 

proc gc_buffer_create*(in_size: uint32): ptr gc_CircBuffer {.cdecl, 
    importc: "gc_buffer_create", dynlib: gorillalib.}
#* Destroy a circular buffer object.
# 
#   \ingroup gc_CircBuffer
# 

proc gc_buffer_destroy*(in_buffer: ptr gc_CircBuffer): gc_result {.cdecl, 
    importc: "gc_buffer_destroy", dynlib: gorillalib.}
#* Retrieve number of available bytes to read from a circular buffer object.
# 
#   \ingroup gc_CircBuffer
# 

proc gc_buffer_bytesAvail*(in_buffer: ptr gc_CircBuffer): uint32 {.cdecl, 
    importc: "gc_buffer_bytesAvail", dynlib: gorillalib.}
#* Retrieve number of free bytes to write to a circular buffer object.
# 
#   \ingroup gc_CircBuffer
# 

proc gc_buffer_bytesFree*(in_buffer: ptr gc_CircBuffer): uint32 {.cdecl, 
    importc: "gc_buffer_bytesFree", dynlib: gorillalib.}
#* Retrieve write buffer(s) of free data in a circular buffer object.
# 
#   \ingroup gc_CircBuffer
#   \warning You must call gc_buffer_produce() to tell the buffer how many
#            bytes you wrote to it.
# 

proc gc_buffer_getFree*(in_buffer: ptr gc_CircBuffer; in_numBytes: uint32; 
                        out_dataA: ptr pointer; out_sizeA: ptr uint32; 
                        out_dataB: ptr pointer; out_sizeB: ptr uint32): gc_result {.
    cdecl, importc: "gc_buffer_getFree", dynlib: gorillalib.}
#* Write data to the circular buffer.
# 
#   Easier-to-use than gc_buffer_getFree(), but less flexible.
# 
#   \ingroup gc_CircBuffer
#   \warning You must call gc_buffer_produce() to tell the buffer how many
#            bytes you wrote to it.
# 

proc gc_buffer_write*(in_buffer: ptr gc_CircBuffer; in_data: pointer; 
                      in_numBytes: uint32): gc_result {.cdecl, 
    importc: "gc_buffer_write", dynlib: gorillalib.}
#* Retrieve read buffer(s) of available data in a circular buffer object.
# 
#   \ingroup gc_CircBuffer
#   \warning You must call gc_buffer_consume() to tell the buffer how many
#            bytes you read from it.
# 

proc gc_buffer_getAvail*(in_buffer: ptr gc_CircBuffer; in_numBytes: uint32; 
                         out_dataA: ptr pointer; out_sizeA: ptr uint32; 
                         out_dataB: ptr pointer; out_sizeB: ptr uint32): gc_result {.
    cdecl, importc: "gc_buffer_getAvail", dynlib: gorillalib.}
#* Read data from the circular buffer.
# 
#   Easier-to-use than gc_buffer_getAvail(), but less flexible.
# 
#   \ingroup gc_CircBuffer
#   \warning You must call gc_buffer_consume() to tell the buffer how many
#            bytes you read from it.
# 

proc gc_buffer_read*(in_buffer: ptr gc_CircBuffer; in_data: pointer; 
                     in_numBytes: uint32) {.cdecl, importc: "gc_buffer_read", 
    dynlib: gorillalib.}
#* Tell the buffer that bytes have been written to it.
# 
#   \ingroup gc_CircBuffer
# 

proc gc_buffer_produce*(in_buffer: ptr gc_CircBuffer; in_numBytes: uint32) {.
    cdecl, importc: "gc_buffer_produce", dynlib: gorillalib.}
#* Tell the buffer that bytes have been read from it.
# 
#   \ingroup gc_CircBuffer
# 

proc gc_buffer_consume*(in_buffer: ptr gc_CircBuffer; in_numBytes: uint32) {.
    cdecl, importc: "gc_buffer_consume", dynlib: gorillalib.}
#*********************
#*  Linked List  *
#*********************
#* Linked list data structure and associated functions.
# 
#   \ingroup common
#   \defgroup gc_Link Linked List
# 
#* Linked list data structure [POD].
# 
#   Intended usage: create a gc_Link head link. Add and remove additional links
#   as needed. To iterate, start with it = head->next. Each loop, it = it->next.
#   Terminate when it == &head.
# 
#   \ingroup gc_Link
# 

type 
  gc_Link* = object 
    next*: ptr gc_Link
    prev*: ptr gc_Link
    data*: pointer


#* Initializes a linked list head element.
# 
#   \ingroup gc_Link
# 

proc gc_list_head*(in_head: ptr gc_Link) {.cdecl, importc: "gc_list_head", 
    dynlib: gorillalib.}
#* Adds a link to a linked list (initializes the link).
# 
#   \ingroup gc_Link
# 

proc gc_list_link*(in_head: ptr gc_Link; in_link: ptr gc_Link; in_data: pointer) {.
    cdecl, importc: "gc_list_link", dynlib: gorillalib.}
#* Removes a link from the linked list.
# 
#   \ingroup gc_Link
# 

proc gc_list_unlink*(in_link: ptr gc_Link) {.cdecl, importc: "gc_list_unlink", 
    dynlib: gorillalib.}
#*
#  --------------------------------------------------
#  Patch, Common struct types between ga_intermal/ga
#  --------------------------------------------------
# 
#* Audio format data structure [\ref POD].
# 
#   Stores the format (sample rate, bps, channels) for PCM audio data.
# 
#   This object may be used on any thread.
# 
#   \ingroup ga_Format
# 

type 
  ga_Format* = object 
    sampleRate*: int32        #*< Sample rate (usually 44100) 
    bitsPerSample*: int32     #*< Bits per PCM sample (usually 16) 
    numChannels*: int32       #*< Number of audio channels (1 for mono, 2 for stereo) 
  

#* Hardware device abstract data structure [\ref SINGLE_CLIENT].
# 
#   Abstracts the platform-specific details of presenting audio buffers to sound playback hardware.
# 
#   \ingroup intDevice
#   \warning You can only have one device open at-a-time.
#   \warning Never instantiate a ga_Device directly, unless you are implementing a new concrete
#            device implementation. Instead, you should use ga_device_open().
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
#   \ingroup internal
#   \defgroup intDataSource Data Source
# 
#* Data source read callback prototype.
#   
#   \ingroup intDataSource
#   \param in_context User context (pointer to the first byte after the data source).
#   \param in_dst Destination buffer into which bytes should be read. Guaranteed to
#                 be at least (in_size * in_count) bytes in size.
#   \param in_size Size of a single element (in bytes).
#   \param in_count Number of elements to read.
#   \return Total number of bytes read into the destination buffer.
# 

type 
  tDataSourceFunc_Read* = proc (in_context: pointer; in_dst: pointer; 
                                in_size: int32; in_count: int32): int32 {.cdecl.}

#* Data source seek callback prototype.
#   
#   \ingroup intDataSource
#   \param in_context User context (pointer to the first byte after the data source).
#   \param in_offset Offset (in bytes) from the specified seek origin.
#   \param in_origin Seek origin (see [\ref globDefs]).
#   \return If seek succeeds, the callback should return 0, otherwise it should return -1.
#   \warning Data sources with GA_FLAG_SEEKABLE should always provide a seek callback.
#   \warning Data sources with GA_FLAG_SEEKABLE set should only return -1 in the case of
#            an invalid seek request.
#   \todo Define a less-confusing contract for extending/defining this function.
# 

type 
  tDataSourceFunc_Seek* = proc (in_context: pointer; in_offset: int32; 
                                in_origin: int32): int32 {.cdecl.}

#* Data source tell callback prototype.
# 
#   \ingroup intDataSource
#   \param in_context User context (pointer to the first byte after the data source).
#   \return The current data source read position.
# 

type 
  tDataSourceFunc_Tell* = proc (in_context: pointer): int32 {.cdecl.}

#* Data source close callback prototype.
# 
#   \ingroup intDataSource
#   \param in_context User context (pointer to the first byte after the data source).
# 

type 
  tDataSourceFunc_Close* = proc (in_context: pointer) {.cdecl.}

#* Abstract data source data structure [\ref MULTI_CLIENT].
# 
#   A data source is a source of binary data, such as a file or socket, that 
#   generates bytes of binary data. This data is usually piped through a sample 
#   source to generate actual PCM audio data.
# 
#   \ingroup intDataSource
#   \todo Design a clearer/better system for easily extending this data type.
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
#   \ingroup intDataSource
# 

proc ga_data_source_init*(in_dataSrc: ptr ga_DataSource) {.cdecl, 
    importc: "ga_data_source_init", dynlib: gorillalib.}
#*****************
#  Sample Source  
#*****************
#* On-seek callback function.
# 
#   A callback that gets called while reading a sample source, if the sample source
#   seeks as part of the read. This callback is used to implement gapless looping 
#   features within the sample source pipeline.
# 
#   \ingroup ga_SampleSource
#   \param in_sample The sample the sample source was at when the seek happened.
#   \param in_delta The signed distance from the old position to the new position.
#   \param in_seekContext The user-specified context provided in ga_sample_source_read().
# 

type 
  tOnSeekFunc* = proc (in_sample: int32; in_delta: int32; 
                       in_seekContext: pointer) {.cdecl.}
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

#* Abstract sample source data structure [\ref MULTI_CLIENT].
# 
#   A sample source is a source of PCM audio samples. These samples are usually 
#   generated from a compatible data source or sample source, which is transformed
#   or decoded into the resulting PCM audio data.
# 
#   This object may only be used on the main thread.
# 
#   \ingroup ga_SampleSource
# 

type 
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
#* Shared memory object data structure [\ref MULTI_CLIENT].
# 
#   As a way of sharing data between multiple client across multiple threads, 
#   this data structure allows for a safe internal copy of the data. This is
#   used in the internal implementation of ga_Sound, and can also be used to 
#   play compressed audio directly from memory without having to read the data 
#   source from a high-latency I/O interface or needlessly duplicate the data.
# 
#   This object may be created on a secondary thread, but may otherwise only 
#   be used on the main thread.
# 
#   \ingroup ga_Memory
# 

type 
  ga_Memory* = object 
    data*: pointer
    size*: uint32
    refCount*: int32
    refMutex*: ptr gc_Mutex


#*********
#  Sound  
#*********
#* Shared sound object data structure [\ref MULTI_CLIENT].
# 
#   As a way of sharing sounds between multiple client across multiple threads, 
#   this data structure allows for a safe internal copy of the PCM data. The 
#   data buffer must contain only raw PCM data, not formatted or compressed 
#   in any other way. To cache or share any other data, use a ga_Memory.
# 
#   This object may be created on a secondary thread, but may otherwise only 
#   be used on the main thread.
#  
#   \ingroup ga_Sound
# 

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


#**********
#  Mixer  
#**********
#* Audio mixer data structure [\ref SINGLE_CLIENT].
# 
#   The mixer mixes PCM samples from multiple audio handles into a single buffer
#   of PCM samples. The mixer is responsible for applying handle parameters 
#   such as gain, pan, and pitch. The mixer has a fixed sample size and format 
#   that must be specified upon creation. Buffers passed in must be large enough
#   to hold the specified number of samples of the specified format.
# 
#   This object may only be used on the main thread.
# 
#   \ingroup ga_Mixer
# 

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

#* Audio playback control handle data structure [\ref SINGLE_CLIENT].
# 
#   A handle is a set of controls for manipulating the playback and mix 
#   parameters of a sample source.
# 
#   Handles track playback parameters such as pan, pitch, and gain (volume)
#   which are taken into account during the mix. Additionally, each handle
#   tracks its playback state (playing/stopped/finished).
# 
#   This object may only be used on the main thread.
# 
#   \ingroup ga_Handle
# 

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


#* Buffered-stream manager data structure [\ref SINGLE_CLIENT].
# 
#   Manages a list of buffered streams, filling them. This class can be used
#   on a background thread, to allow filling the streams without causing
#   real-time applications to stutter.
# 
#   \ingroup ga_StreamManager
# 

type 
  ga_StreamManager* = object 
    streamList*: gc_Link
    streamListMutex*: ptr gc_Mutex


#* Buffered stream data structure [\ref MULTI_CLIENT].
# 
#   Buffered streams read samples from a sample source into a buffer. They 
#   support seeking, reading, and all other sample source functionality,
#   albeit through a different interface. This is done to decouple the
#   background-streaming logic from the audio-processing pipeline logic.
# 
#   \ingroup ga_BufferedStream
# 

type 
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

