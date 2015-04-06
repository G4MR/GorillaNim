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

#* Gorilla Internal Interface.
# 
#   Internal data structures and functions.
# 
#   \file ga_internal.h
# 
#* \defgroup internal Internal Interface
#  Internal data structures and functions used by Gorilla Audio.
# 

include 
  common/gc_common
