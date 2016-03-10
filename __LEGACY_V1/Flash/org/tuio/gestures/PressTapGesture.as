package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * This is an example implementation of a two finger press tap gesture. 
	 * It is recommended to modify this event to fit the wanted behaviour.
	 */
	public class PressTapGesture extends Gesture {
		
		public function PressTapGesture() {
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, { tuioContainerAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { tuioContainerAlias:"A", die:true } ));
			this.addStep(new GestureStep(TuioTouchEvent.TAP, {minDelay:500, goto:2} ));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			trace("press tap " + getTimer());
		}
		
	}
	
}