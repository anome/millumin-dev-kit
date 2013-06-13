package org.tuio.adapters
{
	import org.tuio.ITuioListener;
	import org.tuio.TuioBlob;
	import org.tuio.TuioCursor;
	import org.tuio.TuioObject;

	/**
	 * Provides basic functionality for a Tuio adapter. This can either be a real Tuio adapter like <code>TuioClient</code>
	 * or an adapter that simulates Tuio functionality like <code>MouseTuioAdapter</code> or <code>NativeTuioAdapter</code>.
	 * 
	 * @author Johannes Luderschmidt
	 * @author Immanuel Bauer
	 * 
	 * @see org.tuio.TuioClient
	 * @see org.tuio.adapters.MouseTuioAdapter
	 * @see org.tuio.adapters.NativeTuioAdapter
	 * 
	 */
	public class AbstractTuioAdapter
	{
		/** @private */
		protected var _tuioCursors:Object;
		/** @private */
		protected var _tuioObjects:Object;
		/** @private */
		protected var _tuioBlobs:Object;
		
		/** @private */
		protected var listeners:Array;
		
		public static const DEFAULT_SOURCE:String = "_no_source_";
		
		public function AbstractTuioAdapter(self:AbstractTuioAdapter){
			if(self != this){
				throw new Error("Do not initialize this abstract class directly. Instantiate from inheriting class instead.");
			}
			this.listeners = new Array();
			
			this._tuioCursors = {};
			this._tuioObjects = {};
			this._tuioBlobs = {};
		}
		
		/**
		 * Adds a listener to the callback stack. The callback functions of the listener will be called on incoming TUIOEvents.
		 * 
		 * @param	listener Object of a class that implements the callback functions defined in the ITuioListener interface.
		 */
		public function addListener(listener:ITuioListener):void {
			if (this.listeners.indexOf(listener) > -1) return;
			this.listeners.push(listener);
		}
		
		/**
		 * Removes the given listener from the callback stack.
		 * 
		 * @param	listener
		 */
		public function removeListener(listener:ITuioListener):void {
			var temp:Array = new Array();
			for each(var l:ITuioListener in this.listeners) {
				if (l != listener) temp.push(l);
			}
			this.listeners = temp.concat();
		}
		
		/**
		 * Retrieves all active <code>TuioCursors</code> for the given source.
		 * @param The wanted source. If null or ommited all active <code>TuioCursors</code> are returned.
		 * @return A copy of the list of currently active tuioCursors
		 */
		public function getTuioCursors(source:String = null):Array {
			var returnArray:Array;
			
			if(source == null){
				returnArray = getAllTuioContainersOf(this._tuioCursors);
			}else{
				returnArray  = this._tuioCursors[source]; 
			}
			return returnArray;
		}
		
		/**
		 * Retrieves all active <code>TuioObjects</code> for the given source.
		 * @param The wanted source. If null or ommited all active <code>TuioObjects</code> are returned.
		 * @return A copy of the list of currently active tuioObjects
		 */
		public function getTuioObjects(source:String = null):Array {
			var returnArray:Array;
			
			if(source == null){
				returnArray = getAllTuioContainersOf(this._tuioObjects);
			}else{
				returnArray  = this._tuioObjects[source]; 
			}
			return returnArray;
		}
		
		/**
		 * Retrieves all active <code>TuioBlobs</code> for the given source.
		 * @param The wanted source. If null or ommited all active <code>TuioBlobs</code> are returned.
		 * @return A copy of the list of currently active tuioBlobs
		 */
		public function getTuioBlobs(source:String = null):Array {
			var returnArray:Array;
			
			if(source == null){
				returnArray = getAllTuioContainersOf(this._tuioBlobs);
			}else{
				returnArray  = this._tuioBlobs[source]; 
			}
			return returnArray;
		}
		
		
		/**
		 * Takes care for TUIO 1.0 clients that do not use the source message. Creates one big array 
		 * for the TUIO cursors of all TUIO message in tuioDictionary.
		 * 
		 * @param tuioDictionary contains lists of TuioContainers that will be combined in one array.
		 * @return 
		 * 
		 */
		private function getAllTuioContainersOf(tuioDictionary:Object):Array{
			var allTuioContainers:Array = new Array();
			
			for each(var tuioCursorArray:Array in tuioDictionary){
				allTuioContainers = allTuioContainers.concat(tuioCursorArray);
			}
			
			return allTuioContainers;
		}
		
		/**
		 * Retrieves the <code>TuioCursor</code> fitting the given sessionID and source.
		 * @param	sessionID The sessionID of the designated tuioCursor
		 * @param	source The source message of the TUIO message provider. If null, all TuioCursor source messages will be searched for the 
		 * TuioCursor with the appropriate sessionID. Attention: If there are more than one TuioCursor with sessionID the first appropriate
		 * TuioCursor will be returned. 
		 * 
		 * @return The <code>TuioCursor</code> matching the given sessionID. Returns null if the tuioCursor doesn't exists
		 */
		public function getTuioCursor(sessionID:Number, source:String = null):TuioCursor {
			var out:TuioCursor = null;
			var searchArray:Array;
			
			if(source != null){
				searchArray = this._tuioCursors[source];
			}else{
				searchArray = getAllTuioContainersOf(this._tuioCursors);
			}
				
			for each(var tc:TuioCursor in searchArray) {
				if (tc.sessionID == sessionID) {
					out = tc;
					break;
				}
			}
			return out;
		}
		
		/**
		 * Retrieves the <code>TuioObject</code> fitting the given sessionID and source.
		 * @param	sessionID The sessionID of the designated tuioObject
		 * @param	source The source message of the TUIO message provider. If null, all TuioObject source messages will be searched for the 
		 * TuioObject with the appropriate sessionID. Attention: If there are more than one TuioObject with sessionID the first appropriate
		 * TuioObject will be returned. 
		 *    
		 * @return The <code>TuioObject</code> matching the given sessionID. Returns null if the tuioObject doesn't exists
		 */
		public function getTuioObject(sessionID:Number, source:String = null):TuioObject {
			var out:TuioObject = null;

			var searchArray:Array;
			if(source != null){
				searchArray = this._tuioObjects[source];
			}else{
				searchArray = getAllTuioContainersOf(this._tuioObjects);
			}
			
			for each(var to:TuioObject in searchArray) {
				if (to.sessionID == sessionID) {
					out = to;
					break;
				}
			}
			return out;
		}
		
		/**
		 * Retrieves the <code>TuioBlob</code> fitting the given sessionID and source.
		 * @param	sessionID The sessionID of the designated tuioBlob
		 * @param	source The source message of the TUIO message provider. If null, all TuioBlob source messages will be searched for the 
		 * TuioBlob with the appropriate sessionID. Attention: If there are more than one TuioBlob with sessionID the first appropriate
		 * TuioBlob will be returned. 
		 * 
		 * @return The <code>TuioBlob</code> matching the given sessionID. Returns null if the tuioBlob doesn't exists
		 */
		public function getTuioBlob(sessionID:Number, source:String = null):TuioBlob {
			var out:TuioBlob = null;
			
			var searchArray:Array;
			if(source != null){
				searchArray = this._tuioBlobs[source];
			}else{
				searchArray = getAllTuioContainersOf(this._tuioBlobs);
			}
			
			for each(var tb:TuioBlob in searchArray) {
				if (tb.sessionID == sessionID) {
					out = tb;
					break;
				}
			}
			return out;
		}
		
		/**
		 * Helper functions for dispatching TUIOEvents to the ITuioListeners.
		 */
		
		protected function dispatchAddCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioCursor(tuioCursor);
			}
		}
		
		protected function dispatchUpdateCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioCursor(tuioCursor);
			}
		}
		
		protected function dispatchRemoveCursor(tuioCursor:TuioCursor):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioCursor(tuioCursor);
			}
		}
		
		protected function dispatchAddObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioObject(tuioObject);
			}
		}
		
		protected function dispatchUpdateObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioObject(tuioObject);
			}
		}
		
		protected function dispatchRemoveObject(tuioObject:TuioObject):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioObject(tuioObject);
			}
		}
		
		protected function dispatchAddBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.addTuioBlob(tuioBlob);
			}
		}
		
		protected function dispatchUpdateBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.updateTuioBlob(tuioBlob);
			}
		}
		
		protected function dispatchRemoveBlob(tuioBlob:TuioBlob):void {
			for each(var l:ITuioListener in this.listeners) {
				l.removeTuioBlob(tuioBlob);
			}
		}
	}
}