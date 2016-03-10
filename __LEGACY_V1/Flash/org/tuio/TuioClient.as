package org.tuio {
	
	import org.tuio.adapters.AbstractTuioAdapter;
	import org.tuio.osc.*;
	
	/**
	 * A class for receiving tracking data via the TUIO protocol using a seperate OSC parser 
	 * package located in org.tuio.osc.
	 * 
	 * @author Immanuel Bauer
	 */
	public class TuioClient extends AbstractTuioAdapter implements IOSCListener{
			
		private var oscManager:OSCManager;
		
		private var fseq:uint;
		private var src:String = DEFAULT_SOURCE;
		
		/**
		 * Creates an instance of the TuioClient with the given IOSConnector.
		 * 
		 * @param	connector An instance that implements IOSConnector, establishes and handles an incoming connection. 
		 */
		public function TuioClient(connector:IOSCConnector) {
			super(this);
			
			if (!this._tuioBlobs[this.src]) this._tuioBlobs[this.src] = [];
			if (!this._tuioCursors[this.src]) this._tuioCursors[this.src] = [];
			if (!this._tuioObjects[this.src]) this._tuioObjects[this.src] = [];
			
			if (connector != null) {
				this.oscManager = new OSCManager(connector);
				this.oscManager.addMsgListener(this);
			}
			
		}
		
		/**
		 * Callback function for receiving TUIO tracking data in OSCMessages as specified in the IOSCListener interface.
		 * 
		 * @param	msg The OSCMessage containing a single TUIOEvent.
		 */
		public function acceptOSCMessage(msg:OSCMessage):void {
			var tuioContainerList:Array;
			if (msg.arguments[0] == "source") {
				this.src = String(msg.arguments[1]);
				if (!this._tuioBlobs[this.src]) this._tuioBlobs[this.src] = [];
				if (!this._tuioCursors[this.src]) this._tuioCursors[this.src] = [];
				if (!this._tuioObjects[this.src]) this._tuioObjects[this.src] = [];
			}else if (msg.arguments[0] == "alive") {
				
				if (msg.address.indexOf("cur") > -1) {
					
					for each(var tcur:TuioCursor in this._tuioCursors[this.src]) {
						tcur.isAlive = false;
					}
					
					for (var k:uint = 1; k < msg.arguments.length; k++){
						for each(tcur in this._tuioCursors[this.src]) {
							if (tcur.sessionID == msg.arguments[k]) {
								tcur.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this._tuioCursors[this.src].concat();
					this._tuioCursors[this.src] = new Array();
					
					for each(tcur in tuioContainerList) {
						if (tcur.isAlive) this._tuioCursors[this.src].push(tcur);
						else {
							dispatchRemoveCursor(tcur);
						}
					}
					
				} else if (msg.address.indexOf("obj") > -1) {
					
					for each(var to:TuioObject in this._tuioObjects[this.src]) {
						to.isAlive = false;
					}
					
					for (var t:uint = 1; t < msg.arguments.length; t++){
						for each(to in this._tuioObjects[this.src]) {
							if (to.sessionID == msg.arguments[t]) {
								to.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this._tuioObjects[this.src].concat();
					this._tuioObjects[this.src] = new Array();
					
					for each(to in tuioContainerList) {
						if (to.isAlive) this._tuioObjects[this.src].push(to);
						else {
							dispatchRemoveObject(to);
						}
					}
					
				} else if (msg.address.indexOf("blb") > -1) {
					
					for each(var tb:TuioBlob in this._tuioBlobs[this.src]) {
						tb.isAlive = false;
					}
					
					for (var u:uint = 1; u < msg.arguments.length; u++){
						for each(tb in this._tuioBlobs[this.src]) {
							if (tb.sessionID == msg.arguments[u]) {
								tb.isAlive = true;
								break;
							}
						}
					}
					
					tuioContainerList = this._tuioBlobs[this.src].concat();
					this._tuioBlobs[this.src] = new Array();
					
					for each(tb in tuioContainerList) {
						if (tb.isAlive) this._tuioBlobs[this.src].push(tb);
						else {
							dispatchRemoveBlob(tb);
						}
					}
					
				} else return;
				
			}else if (msg.arguments[0] == "set"){
				
				var isObj:Boolean = false;
				var isBlb:Boolean = false;
				var isCur:Boolean = false;
				
				var is2D:Boolean = false;
				var is25D:Boolean = false;
				var is3D:Boolean = false;
				
				if (msg.address.indexOf("/tuio/2D") == 0) {
					is2D = true;
				} else if (msg.address.indexOf("/tuio/25D") == 0) {
					is25D = true;
				} else if (msg.address.indexOf("/tuio/3D") == 0) {
					is3D = true;
				} else return;
				
				if (msg.address.indexOf("cur") > -1) {
					isCur = true;
				} else if (msg.address.indexOf("obj") > -1) {
					isObj = true;
				} else if (msg.address.indexOf("blb") > -1) {
					isBlb = true;
				} else return;
				
				var s:Number = 0;
				var i:Number = 0;
				var x:Number = 0, y:Number = 0, z:Number = 0;
				var a:Number = 0, b:Number = 0, c:Number = 0;
				var X:Number = 0, Y:Number = 0, Z:Number = 0;
				var A:Number = 0, B:Number = 0, C:Number = 0;
				var w:Number = 0, h:Number = 0, d:Number = 0;
				var f:Number = 0;
				var v:Number = 0;
				var m:Number = 0, r:Number = 0;
				
				var index:uint = 2;
				
				s = Number(msg.arguments[1]);
				
				if (isObj) {
					i = Number(msg.arguments[index++]);
				}
				
				x = Number(msg.arguments[index++]);
				y = Number(msg.arguments[index++]);
				
				if (!is2D) {
					z = Number(msg.arguments[index++]);
				}
				
				if (!isCur) {
					a = Number(msg.arguments[index++]);
					if (is3D) {
						b = Number(msg.arguments[index++]);
						c = Number(msg.arguments[index++]);
					}
				}
				
				if (isBlb) {
					w = Number(msg.arguments[index++]);
					h = Number(msg.arguments[index++]);
					if (!is3D) {
						f = Number(msg.arguments[index++]);
					} else {
						d = Number(msg.arguments[index++]);
						v = Number(msg.arguments[index++]);
					}
				}
				
				X = Number(msg.arguments[index++]);
				Y = Number(msg.arguments[index++]);
				
				if (!is2D) {
					Z = Number(msg.arguments[index++]);
				}
				
				if (!isCur) {
					A = Number(msg.arguments[index++]);
					if (msg.address.indexOf("/tuio/3D") == 0) {
						B = Number(msg.arguments[index++]);
						C = Number(msg.arguments[index++]);
					}
				}
				
				m = Number(msg.arguments[index++]);
				
				if (!isCur) {
					r = Number(msg.arguments[index++]);
				}
				
				//generate object
				
				var type:String = msg.address.substring(6, msg.address.length);
				
				var tuioContainer:TuioContainer;
				
				if (isCur) {
					tuioContainerList = this._tuioCursors[this.src];
				} else if (isObj) {
					tuioContainerList = this._tuioObjects[this.src];
				} else if (isBlb) {
					tuioContainerList = this._tuioBlobs[this.src];
				} else return;
				
				//resolve if add or update
				for each(var tc:TuioContainer in tuioContainerList) {
					if (tc.sessionID == s) {
						tuioContainer = tc;
						break;
					}
				}
				
				if(tuioContainer == null){
					if (isCur) {
						tuioContainer = new TuioCursor(type, s, x, y, z, X, Y, Z, m, this.fseq, this.src);
						this._tuioCursors[this.src].push(tuioContainer);
						dispatchAddCursor(tuioContainer as TuioCursor);
					} else if (isObj) {
						tuioContainer = new TuioObject(type, s, i, x, y, z, a, b, c, X, Y, Z, A, B, C, m, r, this.fseq, this.src);
						this._tuioObjects[this.src].push(tuioContainer);
						dispatchAddObject(tuioContainer as TuioObject);
					} else if (isBlb) {
						tuioContainer = new TuioBlob(type, s, x, y, z, a, b, c, w, h, d, f, v, X, Y, Z, A, B, C, m, r, this.fseq, this.src);
						this._tuioBlobs[this.src].push(tuioContainer);
						dispatchAddBlob(tuioContainer as TuioBlob);
					} else return;
					
				} else {
					if (isCur) {
						(tuioContainer as TuioCursor).update(x, y, z, X, Y, Z, m, this.fseq);
						dispatchUpdateCursor(tuioContainer as TuioCursor);
					} else if (isObj) {
						(tuioContainer as TuioObject).update(x, y, z, a, b, c, X, Y, Z, A, B, C, m, r, this.fseq);
						dispatchUpdateObject(tuioContainer as TuioObject);
					} else if (isBlb) {
						(tuioContainer as TuioBlob).update(x, y, z, a, b, c, w, h, d, f, v, X, Y, Z, A, B, C, m, r, this.fseq);
						dispatchUpdateBlob(tuioContainer as TuioBlob);
					} else return;
				}
			} else if (msg.arguments[0] == "fseq") {
				var newFseq:uint = uint(msg.arguments[1]);
				if (newFseq != this.fseq) {
					dispatchNewFseq();
					this.fseq = newFseq;
					//as fseq should be the last message in a TUIO bundle, the source is reset to DEFAULT_SOURCE 
					this.src = DEFAULT_SOURCE;
				}
			}
		}
		/**
		 * @return The last received fseq value by the tracker.
		 */
		public function get currentFseq():uint {
			return this.fseq;
		}
		
		/**
		 * @return The last received source specification by the tracker.
		 */
		public function get currentSource():String {
			return this.src;
		}
		
		private function dispatchNewFseq():void {
			for each(var l:ITuioListener in this.listeners) {
				l.newFrame(this.fseq);
			}
		}
	}
	
}