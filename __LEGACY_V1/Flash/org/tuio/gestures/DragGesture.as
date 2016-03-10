package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * A simple drag gesture based on the <code>OneFingerMoveGesture</code>
	 */
	public class DragGesture extends OneFingerMoveGesture {
		
		private var lastPosition:Point;
		
		public function DragGesture() {
			super();
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gss:GestureStepSequence):void {                         
			var a:TuioContainer = gss.getTuioContainer("A");
			var ta:DisplayObject = gss.getTarget("A");
			var diffX:Number = 0;
			var diffY:Number = 0;
			lastPosition = gss.getValue("lP") as Point;
			
			if (lastPosition) {
				diffX = a.x * ta.stage.stageWidth - lastPosition.x;
				diffY = a.y * ta.stage.stageHeight - lastPosition.y;
			}
			
			ta.dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_PAN, true, false, null, 0, 0, 1, 1, 0, diffX, diffY));
			gss.storeValue("lP", new Point(a.x * ta.stage.stageWidth, a.y * ta.stage.stageHeight) );
		}
		
	}
	
}