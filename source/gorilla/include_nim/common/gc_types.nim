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

#* Common Types.
# 
#   Cross-platform primitive type definitions.
# 
#   \file gc_types.h
# 
#*******************
#*  Result Values  *
#*******************
#* Result Values
# 
#   \ingroup common
#   \defgroup results Result Values
# 

type 
  gc_result* = int32

#*< Return type for the result of an operation. \ingroup results 

const 
  GC_FALSE* = 0
  GC_TRUE* = 1
  GC_SUCCESS* = 1
  GC_ERROR_GENERIC* = - 1
