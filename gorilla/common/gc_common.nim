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