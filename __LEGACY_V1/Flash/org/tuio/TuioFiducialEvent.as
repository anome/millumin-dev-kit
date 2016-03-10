package org.tuio
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.Button;
	
	
	/**
	 * <code>TuipFiducialEvent</code> is a high-level implementation of <code>TuioEvent</code> that
	 * offers only information that is connected to TuioObjects. It is the fiducial analogon to
	 * <code>TuioTouchEvent</code>. 
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class TuioFiducialEvent extends Event
	{
		public static const MOVE:String = "FIDUCIAL_MOVE";
		public static const ROTATE:String = "FIDUCIAL_ROTATE";
		public static const ADD:String = "FIDUCIAL_ADD";
		public static const OVER:String = "FIDUCIAL_OVER";
		public static const OUT:String = "FIDUCIAL_OUT";
		public static const REMOVED:String = "FIDUCIAL_REMOVED";
		public static const NOTIFY_REMOVED:String = "FIDUCIAL_NOTIFY_REMOVED";
		public static const NOTIFY_RETURNED:String = "FIDUCIAL_NOTIFY_RETURNED";
		
		private var _fiducialId:Number;
		private var _x:Number;
		private var _y:Number;
		private var _localX:Number;
		private var _localY:Number;
		
		private var _rotation:Number;
		private var _tuioObject:TuioObject;
		
		public function TuioFiducialEvent(type:String, localX:Number, localY:Number, stageX:Number, stageY:Number, relatedObject:DisplayObject, tuioObject:TuioObject)
		{
			super(type, true, false);
			this.fiducialId = tuioObject.classID;
			this.localX = localX;
			this.localY = localY;
			this.x = stageX;
			this.y = stageY;
			this.rotation = tuioObject.m;
			this.tuioObject = tuioObject;
		}
		
		/**
		 * id of the fiducial pattern (NOT session id).
		 *  
		 * @return id of the fiducial pattern.
		 * 
		 */
		public function get fiducialId():Number{
			return _fiducialId;
		}
		public function set fiducialId(fiducialId:Number):void{
			_fiducialId = fiducialId;
		}
		
		
		/**
		 * Indicates the stage x coordinate of the Fiducial.
		 *  
		 * @return stage x coordinate
		 * 
		 */
		public function get x():Number{
			return _x;
		}
		public function set x(x:Number):void{
			_x = x;
		}
		
		/**
		 * Indicates the stage y coordinate of the Fiducial.
		 *  
		 * @return stage y coordinate
		 * 
		 */
		public function get y():Number{
			return _y;
		}
		public function set y(y:Number):void{
			_y = y;
		}
		
		/**
		 * The fiducial's rotation in degrees. 
		 * 
		 * @return fiducial rotation in degree
		 */
		public function get rotation():Number{
			return _rotation;
		}
		public function set rotation(rotation:Number):void{
			_rotation = rotation;
		}
		
		/**
		 * Offset of the x position of the fiducial's position in relation to the upper left border of the DisplayObject.
		 * 
		 * @return 
		 * 
		 */
		public function get localX():Number{
			return _localX; 
		}
		public function set localX(localX:Number):void{
			_localX = localX;
		}
		
		/**
		 * Offset of the y position of the fiducial's position in relation to the upper left border of the DisplayObject.
		 *  
		 * @return 
		 * 
		 */
		public function get localY():Number{
			return _localY; 
		}
		public function set localY(localY:Number):void{
			_localY = localY;
		}
		
		/**
		 * The raw TuioObject that has been received from the Tuio producer. Session id,
		 * movement acceleration, rotation acceleration etc. can only be retrieved from this
		 * TuioObject and not from the event itself.
		 * 
		 * @return raw TuioObject with all fiducial data. 
		 * 
		 */
		public function get tuioObject():TuioObject{
			return _tuioObject;
		}
		public function set tuioObject(tuioObject:TuioObject):void{
			_tuioObject = tuioObject;
		}
		
	}
}