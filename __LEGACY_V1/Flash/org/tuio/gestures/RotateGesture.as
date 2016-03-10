package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.events.TransformGestureEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import org.tuio.*
	
	/**
	 * A basic two finger rotate gesture based on the <code>TwoFingerMoveGesture</code>
	 * @see TwoFingerMoveGesture
	 */
	public class RotateGesture extends TwoFingerMoveGesture {
		
		private var lastAngle:Number;
		
		/**
		 * @param	triggerMode The trigger mode changes the behaviour how a rotate gesture is detected. Possible values are <code>TwoFingerMoveGesture.TRIGGER_MODE_MOVE</code> and <code>TwoFingerMoveGesture.TRIGGER_MODE_TOUCH</code>
		 */
		public function RotateGesture(triggerMode:int) {
			super(triggerMode);
		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			var a:TuioContainer = gsg.getTuioContainer("A");
			var b:TuioContainer = gsg.getTuioContainer("B");
			var center:Point = new Point((b.x + a.x)/2, (b.y + a.y)/2);
			var vector:Point;
			if (a.y > b.y) vector = new Point(a.x - b.x, a.y - b.y);
			else vector = new Point(b.x - a.x, b.y - a.y);
			var length:Number = Math.sqrt(Math.pow(vector.x, 2) + Math.pow(vector.y, 2));
			var angle:Number = Math.acos( vector.x / length);
			lastAngle = Number(gsg.getValue("lA"));
			
			var rotation:Number = 0;
			
			if (lastAngle != 0) {
				rotation = 180 * (angle - lastAngle) / Math.PI;
				if (rotation > 90) {
					rotation = rotation - 180;
				} else if (rotation < -90) {
					rotation = rotation + 180;
				}
			} 
			
			gsg.storeValue("lA", angle);
			var target:DisplayObject = gsg.getTarget("A");
			var localPos:Point = target.globalToLocal(new Point(center.x * target.stage.stageWidth, center.y * target.stage.stageHeight));
			target.dispatchEvent(new TransformGestureEvent(TransformGestureEvent.GESTURE_ROTATE, true, false, null, localPos.x, localPos.y, 0, 0, rotation)); ;
		}
		
	}
	
}