package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * A basic two finger zoom gesture based on the <code>TwoFingerMoveGesture</code>
	 * @see TwoFingerMoveGesture
	 */
	public class ZoomGesture extends TwoFingerMoveGesture {
		
		private var lastDistance:Number;

		/**
		 * @param	triggerMode The trigger mode changes the behaviour how a zoom gesture is detected. Possible values are <code>TwoFingerMoveGesture.TRIGGER_MODE_MOVE</code> and <code>TwoFingerMoveGesture.TRIGGER_MODE_TOUCH</code>
		 */
		public function ZoomGesture(triggerMode:int) {
			super(triggerMode);
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			var a:TuioContainer = gsg.getTuioContainer("A");
			var b:TuioContainer = gsg.getTuioContainer("B");
			var diffX:Number = a.X * b.X;
			var diffY:Number = a.Y * b.Y;
			if (diffX <= 0 || diffY <= 0) {                           
				var distance:Number = Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
				var scale:Number = 1;
				lastDistance = Number(gsg.getValue("lD"));
				
				if (lastDistance != 0) {
					scale = distance / lastDistance;
				}
				
				gsg.storeValue("lD", distance);
				var center:Point = new Point((b.x + a.x)/2, (b.y + a.y)/2);
				var target:DisplayObject = gsg.getTarget("A");
				var localPos:Point = target.globalToLocal(new Point(center.x * target.stage.stageWidth, center.y * target.stage.stageHeight));
				target.dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_ZOOM, true, false, null, localPos.x, localPos.y, scale, scale));
			}
		}
		
	}
	
}