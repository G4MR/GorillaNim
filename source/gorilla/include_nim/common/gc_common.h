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
/** Gorilla Common API.
 *
 *  A collection of non-audio-specific classes that are common to most libraries.
 *
 *  \file gc_common.h
 */

/** Common data structures and functions.
 *
 *  \defgroup common Common API (GC)
 */

#include "gc_types.h"
#include "gc_thread.h"

/*************************/
/**  System Operations  **/
/*************************/
/** System operations.
 *
 *  \ingroup common
 *  \defgroup gc_SystemOps System Operations
 */

/** System allocation policies [\ref POD].
 *
 *  \ingroup gc_SystemOps
 */
typedef struct gc_SystemOps {
  void* (*allocFunc)(gc_uint32 in_size);
  void* (*reallocFunc)(void* in_ptr, gc_uint32 in_size);
  void (*freeFunc)(void* in_ptr);
};

extern gc_SystemOps* gcX_ops;

/** Initialize the Gorilla library.
 *
 *  This must be called before any other functions in the library.
 *
 *  \ingroup gc_SystemOps
 *  \param in_callbacks You may (optionally) pass in a gc_SystemOps structure
 *                      to define custom allocation functions.  If you do not,
 *                      Gorilla will use standard ANSI C malloc/realloc/free
 *                      functions.
 *  \return GC_SUCCESS if library initialized successfully. GC_ERROR_GENERIC
 *          if not.
 */
gc_result gc_initialize(gc_SystemOps* in_callbacks);

/** Shutdown the Gorilla library.
 *
 *  Call this once you are finished using the library. After calling it,
 *  do not call any functions in the library.
 *
 *  \ingroup gc_SystemOps
 *  \return GC_SUCCESS if the library shut down successfully. GC_ERROR_GENERIC
 *          if not.
 */
gc_result gc_shutdown();

/***********************/
/**  Circular Buffer  **/
/***********************/
/** Circular Buffer.
 *
 *  \ingroup common
 *  \defgroup gc_CircBuffer Circular Buffer
 */

/** Circular buffer object [\ref SINGLE_CLIENT].
 *
 *  A circular buffer object that is thread-safe for single producer/single
 *  consumer use cases. It assumes a single thread producing (writing)
 *  data, and a single thread consuming (reading) data. The producer and 
 *  consumer threads may be the same thread.
 *
 *  \ingroup gc_CircBuffer
 *  \warning While it can be read/written from two different threads, the
 *           object’s memory management policy is Single Client, since there
 *           is only one owner responsible for creation/destruction of the
 *           thread.
 */
typedef struct gc_CircBuffer {
  gc_uint8* data;
  gc_uint32 dataSize;
  volatile gc_uint32 nextAvail;
  volatile gc_uint32 nextFree;
} gc_CircBuffer;

/** Create a circular buffer object.
 *
 *  \ingroup gc_CircBuffer
 */
gc_CircBuffer* gc_buffer_create(gc_uint32 in_size);

/** Destroy a circular buffer object.
 *
 *  \ingroup gc_CircBuffer
 */
gc_result gc_buffer_destroy(gc_CircBuffer* in_buffer);

/** Retrieve number of available bytes to read from a circular buffer object.
 *
 *  \ingroup gc_CircBuffer
 */
gc_uint32 gc_buffer_bytesAvail(gc_CircBuffer* in_buffer);

/** Retrieve number of free bytes to write to a circular buffer object.
 *
 *  \ingroup gc_CircBuffer
 */
gc_uint32 gc_buffer_bytesFree(gc_CircBuffer* in_buffer);

/** Retrieve write buffer(s) of free data in a circular buffer object.
 *
 *  \ingroup gc_CircBuffer
 *  \warning You must call gc_buffer_produce() to tell the buffer how many
 *           bytes you wrote to it.
 */
gc_result gc_buffer_getFree(gc_CircBuffer* in_buffer, gc_uint32 in_numBytes,
                            void** out_dataA, gc_uint32* out_sizeA,
                            void** out_dataB, gc_uint32* out_sizeB);

/** Write data to the circular buffer.
 *
 *  Easier-to-use than gc_buffer_getFree(), but less flexible.
 *
 *  \ingroup gc_CircBuffer
 *  \warning You must call gc_buffer_produce() to tell the buffer how many
 *           bytes you wrote to it.
 */
gc_result gc_buffer_write(gc_CircBuffer* in_buffer, void* in_data,
                          gc_uint32 in_numBytes);

/** Retrieve read buffer(s) of available data in a circular buffer object.
 *
 *  \ingroup gc_CircBuffer
 *  \warning You must call gc_buffer_consume() to tell the buffer how many
 *           bytes you read from it.
 */
gc_result gc_buffer_getAvail(gc_CircBuffer* in_buffer, gc_uint32 in_numBytes,
                             void** out_dataA, gc_uint32* out_sizeA,
                             void** out_dataB, gc_uint32* out_sizeB);

/** Read data from the circular buffer.
 *
 *  Easier-to-use than gc_buffer_getAvail(), but less flexible.
 *
 *  \ingroup gc_CircBuffer
 *  \warning You must call gc_buffer_consume() to tell the buffer how many
 *           bytes you read from it.
 */
void gc_buffer_read(gc_CircBuffer* in_buffer, void* in_data,
                    gc_uint32 in_numBytes);

/** Tell the buffer that bytes have been written to it.
 *
 *  \ingroup gc_CircBuffer
 */
void gc_buffer_produce(gc_CircBuffer* in_buffer, gc_uint32 in_numBytes);

/** Tell the buffer that bytes have been read from it.
 *
 *  \ingroup gc_CircBuffer
 */
void gc_buffer_consume(gc_CircBuffer* in_buffer, gc_uint32 in_numBytes);

/***********************/
/**  Linked List  **/
/***********************/
/** Linked list data structure and associated functions.
 *
 *  \ingroup common
 *  \defgroup gc_Link Linked List
 */

/** Linked list data structure [POD].
 *
 *  Intended usage: create a gc_Link head link. Add and remove additional links
 *  as needed. To iterate, start with it = head->next. Each loop, it = it->next.
 *  Terminate when it == &head.
 *
 *  \ingroup gc_Link
 */
typedef struct gc_Link {
  struct gc_Link* next;
  struct gc_Link* prev;
  void* data;
} gc_Link;


/** Initializes a linked list head element.
 *
 *  \ingroup gc_Link
 */
void gc_list_head(gc_Link* in_head);

/** Adds a link to a linked list (initializes the link).
 *
 *  \ingroup gc_Link
 */
void gc_list_link(gc_Link* in_head, gc_Link* in_link, void* in_data);

/** Removes a link from the linked list.
 *
 *  \ingroup gc_Link
 */
void gc_list_unlink(gc_Link* in_link);

/**
 * --------------------------------------------------
 * Patch, Common struct types between ga_intermal/ga
 * --------------------------------------------------
 */

 /** Audio format data structure [\ref POD].
 *
 *  Stores the format (sample rate, bps, channels) for PCM audio data.
 *
 *  This object may be used on any thread.
 *
 *  \ingroup ga_Format
 */
typedef struct ga_Format {
  gc_int32 sampleRate; /**< Sample rate (usually 44100) */
  gc_int32 bitsPerSample; /**< Bits per PCM sample (usually 16) */
  gc_int32 numChannels; /**< Number of audio channels (1 for mono, 2 for stereo) */
};

/** Hardware device abstract data structure [\ref SINGLE_CLIENT].
 *
 *  Abstracts the platform-specific details of presenting audio buffers to sound playback hardware.
 *
 *  \ingroup intDevice
 *  \warning You can only have one device open at-a-time.
 *  \warning Never instantiate a ga_Device directly, unless you are implementing a new concrete
 *           device implementation. Instead, you should use ga_device_open().
 */
struct ga_Device {
  gc_int32 devType; 
  gc_int32 numBuffers; 
  gc_int32 numSamples; 
  ga_Format format;
};

/*****************/
/*  Data Source  */
/*****************/
/** Internal data source object definition.
 *
 *  \ingroup internal
 *  \defgroup intDataSource Data Source
 */

/** Data source read callback prototype.
 *  
 *  \ingroup intDataSource
 *  \param in_context User context (pointer to the first byte after the data source).
 *  \param in_dst Destination buffer into which bytes should be read. Guaranteed to
 *                be at least (in_size * in_count) bytes in size.
 *  \param in_size Size of a single element (in bytes).
 *  \param in_count Number of elements to read.
 *  \return Total number of bytes read into the destination buffer.
 */
typedef gc_int32 (*tDataSourceFunc_Read)(void* in_context, void* in_dst, gc_int32 in_size, gc_int32 in_count);

/** Data source seek callback prototype.
 *  
 *  \ingroup intDataSource
 *  \param in_context User context (pointer to the first byte after the data source).
 *  \param in_offset Offset (in bytes) from the specified seek origin.
 *  \param in_origin Seek origin (see [\ref globDefs]).
 *  \return If seek succeeds, the callback should return 0, otherwise it should return -1.
 *  \warning Data sources with GA_FLAG_SEEKABLE should always provide a seek callback.
 *  \warning Data sources with GA_FLAG_SEEKABLE set should only return -1 in the case of
 *           an invalid seek request.
 *  \todo Define a less-confusing contract for extending/defining this function.
 */
typedef gc_int32 (*tDataSourceFunc_Seek)(void* in_context, gc_int32 in_offset, gc_int32 in_origin);

/** Data source tell callback prototype.
 *
 *  \ingroup intDataSource
 *  \param in_context User context (pointer to the first byte after the data source).
 *  \return The current data source read position.
 */
typedef gc_int32 (*tDataSourceFunc_Tell)(void* in_context);

/** Data source close callback prototype.
 *
 *  \ingroup intDataSource
 *  \param in_context User context (pointer to the first byte after the data source).
 */
typedef void (*tDataSourceFunc_Close)(void* in_context);

/** Abstract data source data structure [\ref MULTI_CLIENT].
 *
 *  A data source is a source of binary data, such as a file or socket, that 
 *  generates bytes of binary data. This data is usually piped through a sample 
 *  source to generate actual PCM audio data.
 *
 *  \ingroup intDataSource
 *  \todo Design a clearer/better system for easily extending this data type.
 */
struct ga_DataSource {
  tDataSourceFunc_Read readFunc; /**< Internal read callback. */
  tDataSourceFunc_Seek seekFunc; /**< Internal seek callback (optional). */
  tDataSourceFunc_Tell tellFunc; /**< Internal tell callback (optional). */
  tDataSourceFunc_Close closeFunc; /**< Internal close callback (optional). */
  gc_int32 refCount; /**< Reference count. */
  gc_Mutex* refMutex; /**< Mutex to protect reference count manipulations. */
  gc_int32 flags; /**< Flags defining which functionality this data source supports (see [\ref globDefs]). */
};

/** Initializes the reference count and other default values.
 *
 *  Because ga_DataSource is an abstract data type, this function should not be 
 *  called except when implement a concrete data source implementation.
 *
 *  \ingroup intDataSource
 */
void ga_data_source_init(ga_DataSource* in_dataSrc);

/*******************/
/*  Sample Source  */
/*******************/
/** On-seek callback function.
 *
 *  A callback that gets called while reading a sample source, if the sample source
 *  seeks as part of the read. This callback is used to implement gapless looping 
 *  features within the sample source pipeline.
 *
 *  \ingroup ga_SampleSource
 *  \param in_sample The sample the sample source was at when the seek happened.
 *  \param in_delta The signed distance from the old position to the new position.
 *  \param in_seekContext The user-specified context provided in ga_sample_source_read().
 */
typedef void (*tOnSeekFunc)(gc_int32 in_sample, gc_int32 in_delta, void* in_seekContext);

typedef gc_int32 (*tSampleSourceFunc_Read)(void* in_context, void* in_dst, gc_int32 in_numSamples,
                                           tOnSeekFunc in_onSeekFunc, void* in_seekContext);
typedef gc_int32 (*tSampleSourceFunc_End)(void* in_context);
typedef gc_int32 (*tSampleSourceFunc_Ready)(void* in_context, gc_int32 in_numSamples);
typedef gc_int32 (*tSampleSourceFunc_Seek)(void* in_context, gc_int32 in_sampleOffset);
typedef gc_int32 (*tSampleSourceFunc_Tell)(void* in_context, gc_int32* out_totalSamples);
typedef void (*tSampleSourceFunc_Close)(void* in_context);


/** Abstract sample source data structure [\ref MULTI_CLIENT].
 *
 *  A sample source is a source of PCM audio samples. These samples are usually 
 *  generated from a compatible data source or sample source, which is transformed
 *  or decoded into the resulting PCM audio data.
 *
 *  This object may only be used on the main thread.
 *
 *  \ingroup ga_SampleSource
 */
struct ga_SampleSource {
  tSampleSourceFunc_Read readFunc;
  tSampleSourceFunc_End endFunc;
  tSampleSourceFunc_Ready readyFunc;
  tSampleSourceFunc_Seek seekFunc; /* OPTIONAL */
  tSampleSourceFunc_Tell tellFunc; /* OPTIONAL */
  tSampleSourceFunc_Close closeFunc; /* OPTIONAL */
  ga_Format format;
  gc_int32 refCount;
  gc_Mutex* refMutex;
  gc_int32 flags;
};

void ga_sample_source_init(ga_SampleSource* in_sampleSrc);

/************/
/*  Memory  */
/************/

/** Shared memory object data structure [\ref MULTI_CLIENT].
 *
 *  As a way of sharing data between multiple client across multiple threads, 
 *  this data structure allows for a safe internal copy of the data. This is
 *  used in the internal implementation of ga_Sound, and can also be used to 
 *  play compressed audio directly from memory without having to read the data 
 *  source from a high-latency I/O interface or needlessly duplicate the data.
 *
 *  This object may be created on a secondary thread, but may otherwise only 
 *  be used on the main thread.
 *
 *  \ingroup ga_Memory
 */
struct ga_Memory {
  void* data;
  gc_uint32 size;
  gc_int32 refCount;
  gc_Mutex* refMutex;
};

/***********/
/*  Sound  */
/***********/

/** Shared sound object data structure [\ref MULTI_CLIENT].
 *
 *  As a way of sharing sounds between multiple client across multiple threads, 
 *  this data structure allows for a safe internal copy of the PCM data. The 
 *  data buffer must contain only raw PCM data, not formatted or compressed 
 *  in any other way. To cache or share any other data, use a ga_Memory.
 *
 *  This object may be created on a secondary thread, but may otherwise only 
 *  be used on the main thread.
 * 
 *  \ingroup ga_Sound
 */
struct ga_Sound {
  ga_Memory* memory;
  ga_Format format;
  gc_int32 numSamples;
  gc_int32 refCount;
  gc_Mutex* refMutex;
};

/************/
/*  Handle  */
/************/
#define GA_HANDLE_STATE_UNKNOWN 0
#define GA_HANDLE_STATE_INITIAL 1
#define GA_HANDLE_STATE_PLAYING 2
#define GA_HANDLE_STATE_STOPPED 3
#define GA_HANDLE_STATE_FINISHED 4
#define GA_HANDLE_STATE_DESTROYED 5

/** Audio playback control handle data structure [\ref SINGLE_CLIENT].
 *
 *  A handle is a set of controls for manipulating the playback and mix 
 *  parameters of a sample source.
 *
 *  Handles track playback parameters such as pan, pitch, and gain (volume)
 *  which are taken into account during the mix. Additionally, each handle
 *  tracks its playback state (playing/stopped/finished).
 *
 *  This object may only be used on the main thread.
 *
 *  \ingroup ga_Handle
 */
struct ga_Handle {
  ga_Mixer* mixer;
  ga_FinishCallback callback;
  void* context;
  gc_int32 state;
  gc_float32 gain;
  gc_float32 pitch;
  gc_float32 pan;
  gc_Link dispatchLink;
  gc_Link mixLink;
  gc_Mutex* handleMutex;
  ga_SampleSource* sampleSrc;
  volatile gc_int32 finished;
};

/************/
/*  Mixer  */
/************/

/** Audio mixer data structure [\ref SINGLE_CLIENT].
 *
 *  The mixer mixes PCM samples from multiple audio handles into a single buffer
 *  of PCM samples. The mixer is responsible for applying handle parameters 
 *  such as gain, pan, and pitch. The mixer has a fixed sample size and format 
 *  that must be specified upon creation. Buffers passed in must be large enough
 *  to hold the specified number of samples of the specified format.
 *
 *  This object may only be used on the main thread.
 *
 *  \ingroup ga_Mixer
 */
struct ga_Mixer {
  ga_Format format;
  ga_Format mixFormat;
  gc_int32 numSamples;
  gc_int32* mixBuffer;
  gc_Link dispatchList;
  gc_Mutex* dispatchMutex;
  gc_Link mixList;
  gc_Mutex* mixMutex;
};

/** Buffered-stream manager data structure [\ref SINGLE_CLIENT].
 *
 *  Manages a list of buffered streams, filling them. This class can be used
 *  on a background thread, to allow filling the streams without causing
 *  real-time applications to stutter.
 *
 *  \ingroup ga_StreamManager
 */
struct ga_StreamManager {
  gc_Link streamList;
  gc_Mutex* streamListMutex;
};

/** Buffered stream data structure [\ref MULTI_CLIENT].
 *
 *  Buffered streams read samples from a sample source into a buffer. They 
 *  support seeking, reading, and all other sample source functionality,
 *  albeit through a different interface. This is done to decouple the
 *  background-streaming logic from the audio-processing pipeline logic.
 *
 *  \ingroup ga_BufferedStream
 */
struct ga_BufferedStream {
  gc_Link* streamLink;
  ga_SampleSource* innerSrc;
  gc_CircBuffer* buffer;
  gc_Mutex* produceMutex;
  gc_Mutex* seekMutex;
  gc_Mutex* readMutex;
  gc_Mutex* refMutex;
  gc_int32 refCount;
  gc_Link tellJumps;
  ga_Format format;
  gc_int32 seek;
  gc_int32 tell;
  gc_int32 nextSample;
  gc_int32 end;
  gc_int32 flags;
  gc_int32 bufferSize;
};