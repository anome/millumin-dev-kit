package org.tuio.gestures {
	
	import flash.display.DisplayObject;
	import flash.utils.getTimer;
	import org.tuio.TuioContainer;
	import org.tuio.TuioEvent;
	import org.tuio.TuioTouchEvent;
	
	/**
	 * This is an example implementation of a two finger move gesture. 
	 * It is recommended to modify this event to fit the wanted behaviour.
	 */
	public class TwoFingerMoveGesture extends Gesture {
		
		/**
		 * This trigger mode detects a gesture as soon as two cursors within the same tuio frame move over the same object on the stage.
		 * This mode should be used with a real Tuio 1.1 tracker since it heavily relies on tuio frames.
		 */
		public static const TRIGGER_MODE_MOVE:int = 1;
		
		/**
		 * This trigger mode detects a gesture as soon as two cursors are created over the same object on the stage.
		 * This behaviour should be used with the <code>MouseTuioAdapter</code> and the <code>NativeTuioAdapter</code>.
		 */
		public static const TRIGGER_MODE_TOUCH:int = 2;
		
		/**
		 * @param	triggerMode The trigger mode changes the behaviour how a two finger move gesture is detected. Possible values are <code>TRIGGER_MODE_MOVE</code> and <code>TRIGGER_MODE_TOUCH</code>
		 */
		public function TwoFingerMoveGesture(triggerMode:int) {
			if(triggerMode == TRIGGER_MODE_MOVE ){
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", frameIDAlias:"!A", targetAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B", frameIDAlias:"A", targetAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", frameIDAlias:"A", targetAlias:"A"} ));
				this.addStep(new GestureStep(TuioEvent.NEW_FRAME, {} ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { optional:true, tuioContainerAlias:"B", goto:4 } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A"} ));
				this.addStep(new GestureStep(TuioEvent.NEW_FRAME, { optional:true, goto:5 } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));	
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { die:true, tuioContainerAlias:"!C", targetAlias:"A" } ));
				this.addStep(new GestureStep(TuioEvent.NEW_FRAME, { goto:5 } ));
			} else {
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, { tuioContainerAlias:"A", targetAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, { tuioContainerAlias:"B", targetAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_DOWN, { die:true, tuioContainerAlias:"!C", targetAlias:"A"} ));

				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"A", optional:true, goto:9 } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_MOVE, { tuioContainerAlias:"B", optional:true, goto:9 } ));
				
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"A" } ));
				this.addStep(new GestureStep(TuioTouchEvent.TOUCH_UP, { die:true, tuioContainerAlias:"B" } ));
				
				this.addStep(new GestureStep(TuioEvent.NEW_FRAME, { goto:4 } ));
			}
			


		}
		
		public override function dispatchGestureEvent(target:DisplayObject, gsg:GestureStepSequence):void {
			trace("two finger move" + getTimer());
		}
		
	}
	
}