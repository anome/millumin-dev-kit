package org.tuio {

	/**
	 * This is a generic class that contains values present in every profile specified in TUIO 1.1
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioContainer {
		
		/** @private */
		internal var _sessionID:uint;
		/** @private */
		internal var _x:Number;
		/** @private */
		internal var _y:Number;
		/** @private */
		internal var _z:Number;
		/** @private */
		internal var _X:Number;
		/** @private */
		internal var _Y:Number;
		/** @private */
		internal var _Z:Number;
		/** @private */
		internal var _m:Number;
		/** @private */
		internal var _type:String;
		/** @private */
		internal var _frameID:uint;
		/** @private */
		internal var _source:String;
		
		public var isAlive:Boolean;
		
		public function TuioContainer(type:String, sID:Number, x:Number, y:Number, z:Number, X:Number, Y:Number, Z:Number, m:Number, frameID:uint, source:String) {
			this._type = type;
			this._sessionID = sID;
			this._x = x;
			this._y = y;
			this._z = z;
			this._X = X;
			this._Y = Y;
			this._Z = Z;
			this._m = m;
			this._frameID = frameID;
			this._source = source;
			this.isAlive = true;
		}
		
		public function get type():String {
			return this._type;
		}
		
		public function get sessionID():uint {
			return this._sessionID;
		}
		
		public function get x():Number {
			return this._x;
		}
		
		public function get y():Number {
			return this._y;
		}
		
		public function get z():Number {
			return this._z;
		}
		
		public function get X():Number {
			return this._X;
		}
		
		public function get Y():Number {
			return this._Y;
		}
		
		public function get Z():Number {
			return this._Z;
		}
		
		public function get m():Number {
			return this._m;
		}
		
		public function get frameID():uint {
			return this._frameID;
		}
		
		public function get source():String {
			return this._source;
		}
	}
	
}