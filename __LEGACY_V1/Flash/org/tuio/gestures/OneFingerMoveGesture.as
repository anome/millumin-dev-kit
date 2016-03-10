package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * This is an example implementation of a one finger move gesture. 
	 * It is recommended to modify this event to fit the wanted behaviour.
	 */
	public class OneFingerMoveGesture extends Gesture {
		
		public function OneFingerMoveGesture() {
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, { tuioContainerAlias:"A", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!B", targetAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
			this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", goto:2 } ));
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			trace("one finger move" + getTimer());
		}
		
	}
	
}