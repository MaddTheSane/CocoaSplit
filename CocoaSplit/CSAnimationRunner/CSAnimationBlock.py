import objc
import PyObjCTools.AppHelper
from Foundation import NSObject,NSLog
from Quartz import CACurrentMediaTime,CATransaction
from CSAnimation import *



def current_frame():
  return CATransaction.valueForKey_("__CS_BLOCK_OBJECT__")

class CSAnimationDelegate(NSObject):

    @objc.signature('v@:@c')
    def animationDidStop_finished_(self, animation, finished):
        cs_anim = animation.valueForKeyPath_("__CS_COMPLETION__")
        cs_anim.completed()


class AnimationBlock:
    def __init__(self, duration = 0.0):
        cframe = current_frame()
        if cframe:
            self.layout = cframe.layout
        else:
            self.layout = None
        
        CATransaction.begin()
        CATransaction.setValue_forKey_(self, "__CS_BLOCK_OBJECT__")
        self.animations = []
        self.duration = duration
        self.max_animation_time = 0.0
        self.beginTime =  0.0
        self.real_completion_block = None
        if not self.duration:
            self.duration = 0.25



    def set_completion_block(self, completion_callable):
        if completion_callable:
            CATransaction.setCompletionBlock_(completion_callable)

    def add_waitmarker(self, duration=0, target=None, **kwargs):
        new_mark = CSAnimation(None, "__CS_WAIT_MARK", None, **kwargs)
        new_mark.isWaitMark = True
        new_mark.duration = duration
        new_mark.cs_input = target
        self.animations.append(new_mark)
        return new_mark

    def add_animation(self, animation, target, keyPath):
        if animation.duration == 0:
            #hax
            animation.duration = 0.001
            animation.animation.setDuration_(0.001)
        self.animations.append(animation)

        return animation

    def wait(self, duration=0, target=None, **kwargs):
        waitmark = self.add_waitmarker(duration, target, **kwargs)
        waitmark.isWaitOnly = True

    def waitAnimation(self, duration=0, target=None, **kwargs):
        return self.add_waitmarker(duration, target, **kwargs)

    def commit(self):
        add_time = CACurrentMediaTime()

        target_map = {}
        anim_map = {}
        slayer_time = self.layout.rootLayer().convertTime_fromLayer_(add_time, None)

        total_time = 0.0
        c_begin = slayer_time
        latest_end_time = c_begin
        for anim in self.animations:
            if anim.label and not anim.isWaitMark:
                anim_map[anim.label] = anim

            if anim.cs_input:
                if not anim.cs_input in target_map:
                    target_map[anim.cs_input] = {'c_begin': c_begin, 'latest_end_time':0}
            use_begin = slayer_time
            if anim.isWaitMark:
                tmp_begin = c_begin
                use_end = latest_end_time
                if anim.cs_input:
                    tmp_begin = target_map[anim.cs_input]['c_begin']
                    use_end = target_map[anim.cs_input]['latest_end_time']
                if anim.label and anim.label in anim_map:
                    label_anim = anim_map[anim.label]
                    use_end = label_anim.end_time

                if anim.isWaitOnly:
                    tmp_begin += anim.duration
                else:
                    tmp_begin = use_end
                    tmp_begin += anim.duration
                if anim.cs_input:
                    target_map[anim.cs_input]['c_begin'] = tmp_begin
                else:
                    c_begin = tmp_begin

            if not anim.ignore_wait and anim.animation:
                anim.animation.setValue_forKeyPath_(anim, "__CS_COMPLETION__")
                anim.animation.setDelegate_(CSAnimationDelegate.alloc().init())
            real_begin = c_begin
            if anim.cs_input:
                t_begin = target_map[anim.cs_input]['c_begin']
                if real_begin > t_begin:
                    target_map[anim.cs_input]['c_begin'] = real_begin
                else:
                    real_begin = t_begin
            a_duration = anim.apply(real_begin)
            if not anim.ignore_wait:
                latest_end_time = max(latest_end_time, real_begin+anim.duration)
                if anim.cs_input:
                    t_latest = target_map[anim.cs_input]['latest_end_time']
                    n_latest = real_begin+anim.duration
                    target_map[anim.cs_input]['latest_end_time'] = max(t_latest, n_latest)
        CATransaction.commit()




def setCompletionBlock(completion_block):
    current_frame().set_completion_block(completion_block)

def wait(duration=0):
    current_frame().wait(duration, None)

def waitAnimation(duration=0, **kwargs):
    current_frame().waitAnimation(duration, None, **kwargs)

def animationDuration():
    current_frame().duration

def beginAnimation(duration=0.25):

    new_frame = AnimationBlock(duration)


def commitAnimation():
    current_frame().commit()


