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
/** Threads and Synchronization.
 *
 *  \file gc_thread.h
 */

#include "gc_types.h"

/************/
/*  Thread  */
/************/
/** Thread data structure and associated functions.
 *
 *  \ingroup common
 *  \defgroup gc_Thread Thread
 */

/** Enumerated thread priorities.
 *
 *  \ingroup gc_Thread
 *  \defgroup threadPrio Thread Priorities
 */
#define GC_THREAD_PRIORITY_NORMAL 0 /**< Normal thread priority. \ingroup threadPrio */
#define GC_THREAD_PRIORITY_LOW 1 /**< Low thread priority. \ingroup threadPrio */
#define GC_THREAD_PRIORITY_HIGH 2 /**< High thread priority. \ingroup threadPrio */
#define GC_THREAD_PRIORITY_HIGHEST 3 /**< Highest thread priority. \ingroup threadPrio */

/** Thread function callback.
 *
 *  Threads execute functions. Those functions must match this prototype.
 *  Thread functions should return non-zero values if they encounter an
 *  error, zero if they terminate without error.
 *
 *  \ingroup gc_Thread
 *  \param in_context The user-specified thread context.
 *  \return GC_SUCCESS if thread terminated without error. GC_ERROR_GENERIC
 *          if not.
 */
typedef gc_int32 (*gc_ThreadFunc)(void* in_context);

/** Thread data structure [\ref SINGLE_CLIENT].
 *
 *  \ingroup gc_Thread
 */
typedef struct gc_Thread {
  gc_ThreadFunc threadFunc;
  void* threadObj;
  void* context;
  gc_int32 id;
  gc_int32 priority;
  gc_int32 stackSize;
};

/** Creates a new thread.
 *
 *  The created thread will not run until gc_thread_run() is called on it.
 *
 *  \ingroup gc_Thread
 */
gc_Thread* gc_thread_create(gc_ThreadFunc in_threadFunc, void* in_context,
                            gc_int32 in_priority, gc_int32 in_stackSize);

/** Runs a thread.
 *
 *  \ingroup gc_Thread
 */
void gc_thread_run(gc_Thread* in_thread);

/** Joins a thread with the current thread.
 *
 *  \ingroup gc_Thread
 */
void gc_thread_join(gc_Thread* in_thread);

/** Signals a thread to wait for a specified time interval.
 *
 *  While the time interval is specified in milliseconds, different operating
 *  systems have different guarantees about the minimum time interval provided.
 *  If accurate sleep timings are desired, make sure the thread priority is set
 *  to GC_THREAD_PRIORITY_HIGH or GC_THREAD_PRIORITY_HIGHEST.
 *
 *  \ingroup gc_Thread
 */
void gc_thread_sleep(gc_uint32 in_ms);

/** Destroys a thread object.
 *
 *  \ingroup gc_Thread
 *  \warning This should usually only be called once the the thread has 
 *           successfully joined with another thread.
 *  \warning Never use a thread after it has been destroyed.
 */
void gc_thread_destroy(gc_Thread* in_thread);

/***********/
/*  Mutex  */
/***********/
/** Mutual exclusion lock data structure and associated functions.
 *
 *  \ingroup common
 *  \defgroup gc_Mutex Mutex
 */

/** Mutual exclusion lock (mutex) thread synchronization primitive data structure [\ref SINGLE_CLIENT].
 *
 *  \ingroup gc_Mutex
 */
typedef struct gc_Mutex {
  void* mutex;
};

/** Creates a mutex.
 *
 *  \ingroup gc_Mutex
 */
gc_Mutex* gc_mutex_create();

/** Locks a mutex.
 *
 *  In general, any lock should have a matching unlock().
 *
 *  \ingroup gc_Mutex
 *  \warning Do not lock a mutex on the same thread without first unlocking.
 */
void gc_mutex_lock(gc_Mutex* in_mutex);

/** Unlocks a mutex.
 *
 *  \ingroup gc_Mutex
 *  \warning Do not unlock a mutex without first locking it.
 */
void gc_mutex_unlock(gc_Mutex* in_mutex);

/** Destroys a mutex.
 *
 *  \ingroup gc_Mutex
 *  \warning Make sure the mutex is no longer in use before destroying it.
 *  \warning Never use a mutex after it has been destroyed.
 */
void gc_mutex_destroy(gc_Mutex* in_mutex);