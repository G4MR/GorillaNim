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

#* Threads and Synchronization.
# 
#   \file gc_thread.h
# 

import 
  gc_types

#**********
#  Thread  
#**********
#* Thread data structure and associated functions.
# 
#   \ingroup common
#   \defgroup gc_Thread Thread
# 
#* Enumerated thread priorities.
# 
#   \ingroup gc_Thread
#   \defgroup threadPrio Thread Priorities
# 

const 
  GC_THREAD_PRIORITY_NORMAL* = 0
  GC_THREAD_PRIORITY_LOW* = 1
  GC_THREAD_PRIORITY_HIGH* = 2
  GC_THREAD_PRIORITY_HIGHEST* = 3

#* Thread function callback.
# 
#   Threads execute functions. Those functions must match this prototype.
#   Thread functions should return non-zero values if they encounter an
#   error, zero if they terminate without error.
# 
#   \ingroup gc_Thread
#   \param in_context The user-specified thread context.
#   \return GC_SUCCESS if thread terminated without error. GC_ERROR_GENERIC
#           if not.
# 

type 
  gc_ThreadFunc* = proc (in_context: pointer): int32 {.cdecl.}

#* Thread data structure [\ref SINGLE_CLIENT].
# 
#   \ingroup gc_Thread
# 

type 
  gc_Thread* = object 
    threadFunc*: gc_ThreadFunc
    threadObj*: pointer
    context*: pointer
    id*: int32
    priority*: int32
    stackSize*: int32


#* Creates a new thread.
# 
#   The created thread will not run until gc_thread_run() is called on it.
# 
#   \ingroup gc_Thread
# 

proc gc_thread_create*(in_threadFunc: gc_ThreadFunc; in_context: pointer; 
                       in_priority: int32; in_stackSize: int32): ptr gc_Thread {.
    cdecl, importc: "gc_thread_create", dynlib: gorillalib.}
#* Runs a thread.
# 
#   \ingroup gc_Thread
# 

proc gc_thread_run*(in_thread: ptr gc_Thread) {.cdecl, importc: "gc_thread_run", 
    dynlib: gorillalib.}
#* Joins a thread with the current thread.
# 
#   \ingroup gc_Thread
# 

proc gc_thread_join*(in_thread: ptr gc_Thread) {.cdecl, 
    importc: "gc_thread_join", dynlib: gorillalib.}
#* Signals a thread to wait for a specified time interval.
# 
#   While the time interval is specified in milliseconds, different operating
#   systems have different guarantees about the minimum time interval provided.
#   If accurate sleep timings are desired, make sure the thread priority is set
#   to GC_THREAD_PRIORITY_HIGH or GC_THREAD_PRIORITY_HIGHEST.
# 
#   \ingroup gc_Thread
# 

proc gc_thread_sleep*(in_ms: uint32) {.cdecl, importc: "gc_thread_sleep", 
                                       dynlib: gorillalib.}
#* Destroys a thread object.
# 
#   \ingroup gc_Thread
#   \warning This should usually only be called once the the thread has 
#            successfully joined with another thread.
#   \warning Never use a thread after it has been destroyed.
# 

proc gc_thread_destroy*(in_thread: ptr gc_Thread) {.cdecl, 
    importc: "gc_thread_destroy", dynlib: gorillalib.}
#*********
#  Mutex  
#*********
#* Mutual exclusion lock data structure and associated functions.
# 
#   \ingroup common
#   \defgroup gc_Mutex Mutex
# 
#* Mutual exclusion lock (mutex) thread synchronization primitive data structure [\ref SINGLE_CLIENT].
# 
#   \ingroup gc_Mutex
# 

type 
  gc_Mutex* = object 
    mutex*: pointer


#* Creates a mutex.
# 
#   \ingroup gc_Mutex
# 

proc gc_mutex_create*(): ptr gc_Mutex {.cdecl, importc: "gc_mutex_create", 
                                        dynlib: gorillalib.}
#* Locks a mutex.
# 
#   In general, any lock should have a matching unlock().
# 
#   \ingroup gc_Mutex
#   \warning Do not lock a mutex on the same thread without first unlocking.
# 

proc gc_mutex_lock*(in_mutex: ptr gc_Mutex) {.cdecl, importc: "gc_mutex_lock", 
    dynlib: gorillalib.}
#* Unlocks a mutex.
# 
#   \ingroup gc_Mutex
#   \warning Do not unlock a mutex without first locking it.
# 

proc gc_mutex_unlock*(in_mutex: ptr gc_Mutex) {.cdecl, 
    importc: "gc_mutex_unlock", dynlib: gorillalib.}
#* Destroys a mutex.
# 
#   \ingroup gc_Mutex
#   \warning Make sure the mutex is no longer in use before destroying it.
#   \warning Never use a mutex after it has been destroyed.
# 

proc gc_mutex_destroy*(in_mutex: ptr gc_Mutex) {.cdecl, 
    importc: "gc_mutex_destroy", dynlib: gorillalib.}