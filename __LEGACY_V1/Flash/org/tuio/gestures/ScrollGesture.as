package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * A basic two finger scroll gesture based on the <code>TwoFingerMoveGesture</code>
	 * @see TwoFingerMoveGesture
	 */
	public class ScrollGesture extends TwoFingerMoveGesture {
		
		/**
		 * @param	triggerMode The trigger mode changes the behaviour how a scroll gesture is detected. Possible values are <code>TwoFingerMoveGesture.TRIGGER_MODE_MOVE</code> and <code>TwoFingerMoveGesture.TRIGGER_MODE_TOUCH</code>
		 */
		public function ScrollGesture(triggerMode:int) {
			super(triggerMode);
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			var diffX:Number = gsg.getTuioContainer("A").X - gsg.getTuioContainer("B").X;
			var diffY:Number = gsg.getTuioContainer("A").Y - gsg.getTuioContainer("B").Y;
			if (diffX < 0.01 || diffY < 0.01) {
				trace("scroll " + getTimer());
			}
		}
		
	}
	
}