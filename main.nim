import gorilla/ga
import gorilla/gau
import gorilla/common/gc_common

var mgr : ptr gau_Manager = gau_manager_create_custom(GA_DEVICE_TYPE_DEFAULT, GAU_THREAD_POLICY_SINGLE, 4, 512);
var mixer = gau_manager_mixer(mgr)
#var mixer : ga_Mixer
#var streamMgr : ga_StreamManager
#var stream : ga_Handle
#var loopSrc : gau_SampleSourceLoop = nil
#var pLoopSrc : ptr gau_SampleSourceLoop = addr(loopSrc)
#var loop : int32 = 0
#var quit : int32 = 0

#gc_initialize(addr(gcX_ops))

#gc_shutdown()