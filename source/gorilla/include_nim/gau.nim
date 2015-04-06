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

#* Gorilla Audio Utility API.
# 
#   Utility data structures and functions to enhance Gorilla Audio's functionality.
# 
#   \file gau.h
# 

import 
  common/gc_common, ga

#* Data structures and functions.
# 
#   \defgroup utility Utility API (GAU)
# 
#***********
#  Manager  
#***********
#* High-level audio manager and associated functions.
# 
#   \ingroup utility
#   \defgroup gau_Manager Manager
# 
#* High-level audio manager.
# 
#   \ingroup gau_Manager
# 

type 
  gau_Manager* = object 
  

#* Manager thread policies.
# 
#   \ingroup gau_Manager
#   \defgroup threadPolicy Thread Policies
# 

const 
  GAU_THREAD_POLICY_UNKNOWN* = 0
  GAU_THREAD_POLICY_SINGLE* = 1
  GAU_THREAD_POLICY_MULTI* = 2

#* Creates an audio manager.
# 
#   \ingroup gau_Manager
# 

proc gau_manager_create*(): ptr gau_Manager {.cdecl, 
    importc: "gau_manager_create", dynlib: gorillalib.}
#* Creates an audio manager (customizable).
#
#  \ingroup gau_Manager
#

proc gau_manager_create_custom*(in_devType: int32; in_threadPolicy: int32; 
                                in_numBuffers: int32; in_bufferSamples: int32): ptr gau_Manager {.
    cdecl, importc: "gau_manager_create_custom", dynlib: gorillalib.}
#* Updates an audio manager.
# 
#   \ingroup gau_Manager
# 

proc gau_manager_update*(in_mgr: ptr gau_Manager) {.cdecl, 
    importc: "gau_manager_update", dynlib: gorillalib.}
#* Retrieves the internal mixer object from an audio manager.
# 
#   \ingroup gau_Manager
# 

proc gau_manager_mixer*(in_mgr: ptr gau_Manager): ptr ga_Mixer {.cdecl, 
    importc: "gau_manager_mixer", dynlib: gorillalib.}
#* Retrieves the internal buffered stream manager object from an audio manager.
# 
#   \ingroup gau_Manager
# 

proc gau_manager_streamManager*(in_mgr: ptr gau_Manager): ptr ga_StreamManager {.
    cdecl, importc: "gau_manager_streamManager", dynlib: gorillalib.}
#* Retrieves the internal device object from an audio manager.
# 
#   \ingroup gau_Manager
# 

proc gau_manager_device*(in_mgr: ptr gau_Manager): ptr ga_Device {.cdecl, 
    importc: "gau_manager_device", dynlib: gorillalib.}
#* Destroys an audio manager.
# 
#   \ingroup gau_Manager
# 

proc gau_manager_destroy*(in_mgr: ptr gau_Manager) {.cdecl, 
    importc: "gau_manager_destroy", dynlib: gorillalib.}
#***************************
#*  Concrete Data Sources  *
#***************************
#* Concrete data source implementations.
# 
#   \ingroup utility
#   \defgroup concreteData Concrete Data Sources
# 
#* Creates a data source of bytes from a file-on-disk.
# 
#   \ingroup concreteData
# 

proc gau_data_source_create_file*(in_filename: cstring): ptr ga_DataSource {.
    cdecl, importc: "gau_data_source_create_file", dynlib: gorillalib.}
#* Creates a data source of bytes from a subregion of a file-on-disk.
# 
#   \ingroup concreteData
# 

proc gau_data_source_create_file_arc*(in_filename: cstring; in_offset: int32; 
                                      in_size: int32): ptr ga_DataSource {.
    cdecl, importc: "gau_data_source_create_file_arc", dynlib: gorillalib.}
#* Creates a data source of bytes from a block of shared memory.
# 
#   \ingroup concreteData
# 

proc gau_data_source_create_memory*(in_memory: ptr ga_Memory): ptr ga_DataSource {.
    cdecl, importc: "gau_data_source_create_memory", dynlib: gorillalib.}
#*****************************
#*  Concrete Sample Sources  *
#*****************************
#* Concrete sample source implementations.
# 
#   \ingroup utility
#   \defgroup concreteSample Concrete Sample Sources
# 
#* Creates a sample source of PCM samples from a WAVE file.
# 
#   \ingroup concreteSample
# 

proc gau_sample_source_create_wav*(in_dataSrc: ptr ga_DataSource): ptr ga_SampleSource {.
    cdecl, importc: "gau_sample_source_create_wav", dynlib: gorillalib.}
#* Creates a sample source of PCM samples from an Ogg/Vorbis file.
# 
#   \ingroup concreteSample
# 

proc gau_sample_source_create_ogg*(in_dataSrc: ptr ga_DataSource): ptr ga_SampleSource {.
    cdecl, importc: "gau_sample_source_create_ogg", dynlib: gorillalib.}
#* Creates a buffered sample source of PCM samples from another sample source.
# 
#   \ingroup concreteSample
# 

proc gau_sample_source_create_buffered*(in_mgr: ptr ga_StreamManager; 
                                        in_sampleSrc: ptr ga_SampleSource; 
                                        in_bufferSamples: int32): ptr ga_SampleSource {.
    cdecl, importc: "gau_sample_source_create_buffered", dynlib: gorillalib.}
#* Creates a sample source of PCM samples from a cached sound object.
# 
#   \ingroup concreteSample
# 

proc gau_sample_source_create_sound*(in_sound: ptr ga_Sound): ptr ga_SampleSource {.
    cdecl, importc: "gau_sample_source_create_sound", dynlib: gorillalib.}
#************************
#*  Loop Sample Source  *
#************************
#* Loop sample source.
# 
#   \ingroup concreteSample
#   \defgroup loopSample Loop Sample Source
# 
#* Loop sample source.
# 
#   Sample source that controls looping behavior of a contained sample source.
# 
#   \ingroup loopSample
# 

type 
  gau_SampleSourceLoop* = object 
  

#* Create a loop sample source.
# 
#   \ingroup loopSample
# 

proc gau_sample_source_create_loop*(in_sampleSrc: ptr ga_SampleSource): ptr gau_SampleSourceLoop {.
    cdecl, importc: "gau_sample_source_create_loop", dynlib: gorillalib.}
#* Set loop points on a loop sample source.
# 
#   \ingroup loopSample
# 

proc gau_sample_source_loop_set*(in_sampleSrc: ptr gau_SampleSourceLoop; 
                                 in_triggerSample: int32; in_targetSample: int32) {.
    cdecl, importc: "gau_sample_source_loop_set", dynlib: gorillalib.}
#* Clear loop points on a loop sample source.
# 
#   \ingroup loopSample
# 

proc gau_sample_source_loop_clear*(in_sampleSrc: ptr gau_SampleSourceLoop) {.
    cdecl, importc: "gau_sample_source_loop_clear", dynlib: gorillalib.}
#* Count number of times a loop sample source has looped.
# 
#   \ingroup loopSample
# 

proc gau_sample_source_loop_count*(in_sampleSrc: ptr gau_SampleSourceLoop): int32 {.
    cdecl, importc: "gau_sample_source_loop_count", dynlib: gorillalib.}
#*************************
#*  On-Finish Callbacks  *
#*************************
#* Generic on-finish callbacks.
#
#  \ingroup utility
#  \defgroup onFinish On-Finish Callbacks
#
#* On-finish callback that destroys the handle.
# 
#   \ingroup onFinish
# 

proc gau_on_finish_destroy*(in_finishedHandle: ptr ga_Handle; 
                            in_context: pointer) {.cdecl, 
    importc: "gau_on_finish_destroy", dynlib: gorillalib.}
#******************
#*  Load Helpers  *
#******************
#* Functions that help load common sources of data into cached memory.
# 
#   \ingroup utility
#   \defgroup loadHelper Load Helpers
# 
#* Load a file's raw binary data into a memory object.
# 
#   \ingroup loadHelper
# 

proc gau_load_memory_file*(in_filename: cstring): ptr ga_Memory {.cdecl, 
    importc: "gau_load_memory_file", dynlib: gorillalib.}
#* Load a file's PCM data into a sound object.
# 
#   \ingroup loadHelper
# 

proc gau_load_sound_file*(in_filename: cstring; in_format: cstring): ptr ga_Sound {.
    cdecl, importc: "gau_load_sound_file", dynlib: gorillalib.}
#********************
#*  Create Helpers  *
#********************
#* Functions that help to create common handle configurations.
#
#  \ingroup utility
#  \defgroup createHelper Create Helpers
#
#* Create a handle to play a memory object in a given data format.
# 
#   \ingroup createHelper
# 

proc gau_create_handle_memory*(in_mixer: ptr ga_Mixer; in_memory: ptr ga_Memory; 
                               in_format: cstring; 
                               in_callback: ga_FinishCallback; 
                               in_context: pointer; 
                               out_loopSrc: ptr ptr gau_SampleSourceLoop): ptr ga_Handle {.
    cdecl, importc: "gau_create_handle_memory", dynlib: gorillalib.}
#* Create a handle to play a sound object.
# 
#   \ingroup createHelper
# 

proc gau_create_handle_sound*(in_mixer: ptr ga_Mixer; in_sound: ptr ga_Sound; 
                              in_callback: ga_FinishCallback; 
                              in_context: pointer; 
                              out_loopSrc: ptr ptr gau_SampleSourceLoop): ptr ga_Handle {.
    cdecl, importc: "gau_create_handle_sound", dynlib: gorillalib.}
#* Create a handle to play a background-buffered stream from a data source.
# 
#   \ingroup createHelper
# 

proc gau_create_handle_buffered_data*(in_mixer: ptr ga_Mixer; 
                                      in_streamMgr: ptr ga_StreamManager; 
                                      in_dataSrc: ptr ga_DataSource; 
                                      in_format: cstring; 
                                      in_callback: ga_FinishCallback; 
                                      in_context: pointer; 
                                      out_loopSrc: ptr ptr gau_SampleSourceLoop): ptr ga_Handle {.
    cdecl, importc: "gau_create_handle_buffered_data", dynlib: gorillalib.}
#* Create a handle to play a background-buffered stream from a file.
# 
#   \ingroup createHelper
# 

proc gau_create_handle_buffered_file*(in_mixer: ptr ga_Mixer; 
                                      in_streamMgr: ptr ga_StreamManager; 
                                      in_filename: cstring; in_format: cstring; 
                                      in_callback: ga_FinishCallback; 
                                      in_context: pointer; 
                                      out_loopSrc: ptr ptr gau_SampleSourceLoop): ptr ga_Handle {.
    cdecl, importc: "gau_create_handle_buffered_file", dynlib: gorillalib.}