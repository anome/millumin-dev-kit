package org.tuio.gestures {
	import flash.events.Event;
	
	/**
	 * This event is used for dispatching statechanges of <code>GestureSteps</code> back to their gestures. 
	 */
	public class GestureStepEvent extends Event {
		
		public static const SATURATED:String = "saturated";
		public static const DEAD:String = "dead";
		
		private var _step:uint;
		private var _group:GestureStepSequence;
		
		function GestureStepEvent(type:String, step:uint, group:GestureStepSequence) {
			super(type, false, false);
			this._step = step;
			this._group = group;
		}
		
		/**
		 * At which step in the containing <code>GestureStepSequence</code> the statechange happened
		 */
		public function get step():uint {
			return this._step;
		}
		
		/**
		 * The <code>GestureStepSequence</code> in which the statechange happened
		 */
		public function get group():GestureStepSequence {
			return this._group;
		}
		
	}
	
}