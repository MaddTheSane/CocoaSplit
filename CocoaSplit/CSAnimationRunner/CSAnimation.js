

CSAnimation = function(target, keyPath, animation, kwargs) {
    
    this.target = target;
    this.keyPath = keyPath;
    this.animation = animation;
    this.isWaitMark = false;
    this.isWaitOnly = false;
    this.ignore_wait = false;
    this.extra_model = null;
    this.duration = 0.0;
    this.cs_input = null;
    this.label = null;
    this.end_time = 0;
    this.begin_time = 0;
    this.completion_handler = null;
    this.internal_completion_handler = null;
    this.toValue = null;
    this.baseLayer = null;
    this.layout = null;
    this.uukey = null;
    if (kwargs === undefined) { kwargs = {}; }
    
    
    
    this.completed = function() {
        if (this.internal_completion_handler)
        {
            this.internal_completion_handler();
        }
        if (this.completion_handler)
        {
            this.completion_handler();
        }
    }
    
    this.apply = function(begin_time) {
        this.begin_time = begin_time;
        if (this.target && !this.isWaitMark)
        {
            this.animation.beginTime = begin_time;
            this.uukey = this.keyPath + "-" + generateUUID();
            this.target.addAnimationForKey(this.animation, this.uukey);
        }
        
        console.log("ANIM BEGIN " + begin_time + " DURATION " + this.duration);
        if (!this.ignore_wait)
        {
            this.end_time = begin_time + this.duration;
        }
        
        return this.duration;
    }
    
    this.waitAnimation = function(duration, kwargs) {
        CSAnimationBlock.currentFrame().waitAnimation(duration, this, kwargs);
        return this;
    }
    
    this.apply_immediate = function() {
        if (this.target)
        {
            var p_value = this.toValue;
            CATransaction.begin();
            this.target.setValueForKeyPath(p_value, this.animation.keyPath);
            if (this.extra_model)
            {
                this.extra_model.setValueForKeyPath(p_value, this.animation.keyPath);
            }
            CATransaction.commit();
        }
    }
    
    this.set_model_value = function(realme) {
        if (this.target)
        {
            var p_layer = this.target.presentationLayer();
            if (!p_layer)
            {
                return;
            }
            
            var p_value = p_layer.valueForKeyPath(this.animation.keyPath);
            CATransaction.begin();
            CATransaction.setDisableActions(true);
            this.target.setValueForKeyPath(p_value, this.animation.keyPath);
            if (this.extra_model)
            {
                this.extra_model.setValueForKeyPath(p_value, this.animation.keyPath);
            }
            this.target.removeAnimationForKey(this.uukey);
            CATransaction.commit();
        }
    }
    
    this.internal_completion_handler = this.set_model_value;
    
    this.repeatduration = function(duration) {
        if (this.animation)
        {
            this.animation.repeatDuration = duration;
        }
        this.duration = duration;
    }
    
    this.timingFunction = function(fname) {
        if (this.animation)
        {
            var tfunc = CAMediaTimingFunction.functionWithName(fname);
            if (tfunc)
            {
                this.animation.setTimingFunction(tfunc);
            }
        }
    }
    
    this.repeatcount = function(r_count) {
        if (this.animation)
        {
            if (r_count == 'forever')
            {
                this.ignore_wait = true;
                r_count = HUGE_VALF;
            } else {
                this.duration *= r_count;
            }
            this.animation.repeatCount = r_count;
        }
    }
    
    this.autoreverse = function() {
        if (this.animation)
        {
            this.animation.autoreverses = true;
        }
        this.duration *= 2;
        return this;
    }
    
    if (animation)
    {
        animation.removedOnCompletion = 0;
        animation.fillMode = "forwards";
        this.duration = animation.duration;
        console.log("MY DURATION " + this.duration);
    }
    
    if (kwargs["repeatcount"])
    {
        this.repeatcount(kwargs["repeatcount"]);
    }
    
    if (kwargs["autoreverse"])
    {
        this.autoreverse();
    }
    
    if (kwargs["timing"])
    {
        this.timingFunction(kwargs["timing"]);
    }
    
    if (kwargs["repeatduration"])
    {
        this.repeatduration(kwargs["repeatduration"]);
    }
    
    if (kwargs["extra_model"])
    {
        this.extra_model = kwargs["extra_model"];
    }
    
    if (kwargs["on_complete"])
    {
        this.completion_handler = kwargs["on_complete"];
    }
    
    if (kwargs["label"])
    {
        this.label = kwargs["label"];
    }

}
