package org.tuio {
	
	import flash.display.*;
	import flash.events.Event;
	import flash.geom.Point;
	
	/**
	 * The <code>TuioTouchEvent</code> is the event dispatched by the <code>TuioManager</code> and behaves uch like the MouseEvent or the native TouchEvent. 
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioTouchEvent extends Event {
		
		/**Triggered on a touch.*/
		public static const TOUCH_DOWN:String = "org.tuio.TuioTouchEvent.TOUCH_DOWN";
		/**Triggered if a touch is released.*/
		public static const TOUCH_UP:String = "org.tuio.TuioTouchEvent.TOUCH_UP";
		/**Triggered if a touch is moved.*/
		public static const TOUCH_MOVE:String = "org.tuio.TuioTouchEvent.TOUCH_MOVE";
		/**Triggered if a touch is moved out of a DisplayObject.*/
		public static const TOUCH_OUT:String = "org.tuio.TuioTouchEvent.TOUCH_OUT";
		/**Triggered if a touch is moved over a DisplayObject.*/
		public static const TOUCH_OVER:String = "org.tuio.TuioTouchEvent.TOUCH_OVER";
		/**Triggered if a touch is moved out of a DisplayObject.*/
		public static const ROLL_OUT:String = "org.tuio.TuioTouchEvent.ROLL_OUT";
		/**Triggered if a touch is moved over a DisplayObject.*/
		public static const ROLL_OVER:String = "org.tuio.TuioTouchEvent.ROLL_OVER";
		
		/**Triggered if a TOUCH_DOWN and TOUCH_UP occurred over the same DisplayObject.*/
		public static const TAP:String = "org.tuio.TuioTouchEvent.TAP";
		/**Triggered if two subsequent TAPs occurred over the same DisplayObject.*/
		public static const DOUBLE_TAP:String = "org.tuio.TuioTouchEvent.DOUBLE_TAP";
		
		/**Triggered if a touch is held for a certain time over the same DisplayObject without movement.*/
		public static const HOLD:String = "org.tuio.TuioTouchEvent.HOLD";
		
		private var _tuioContainer:TuioContainer;
		
		private var _localX:Number = NaN;
		private var _localY:Number = NaN;
		private var _stageX:Number = NaN;
		private var _stageY:Number = NaN;
		private var _relatedObject:DisplayObject;
		
		public function TuioTouchEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, localX:Number = NaN, localY:Number = NaN, stageX:Number = NaN, stageY:Number = NaN, relatedObject:DisplayObject = null, tuioContainer:TuioContainer = null) {
			super(type, bubbles, cancelable);
			this._tuioContainer = tuioContainer;
			
			this._relatedObject = relatedObject;
			
			this._stageX = stageX;
			this._stageY = stageY;
				
			this._localX = localX;
			this._localY = localY;
		}
		
		/**
		 * The <code>TuioContainer</code> related to this <code>TuioTouchEvent</code> containing the raw TUIO information.
		 * @see TuioContainer
		 * @see TuioCursor
		 */
		public function get tuioContainer():TuioContainer {
			return this._tuioContainer;
		}
		
		/**
		 * The touch's position on the x-axis relative to the touchTarget's origin.
		 */
		public function get localX():Number {
			return this._localX;
		}
		
		/**
		 * The touch's position on the y-axis relative to the touchTarget's origin.
		 */
		public function get localY():Number {
			return this._localY;
		}
		
		/**
		 * The touch's position on the x-axis relative to the stage's origin.
		 */
		public function get stageX():Number {
			return this._stageX;
		}
		
		/**
		 * The touch's position on the y-axis relative to the stage's origin.
		 */
		public function get stageY():Number {
			return this._stageY;
		}
		
		/**
		 * The related <code>DisplayObject</code>
		 */
		public function get relatedObject():DisplayObject {
			return this._relatedObject;
		}
	}
	
}