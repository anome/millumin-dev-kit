package org.tuio.osc {
	
	/**
	 * The main class for receiving and sending OSC data.
	 */
	public class OSCManager implements IOSCConnectorListener {
		
		private var _connectorIn:IOSCConnector;
		private var _connectorOut:IOSCConnector;
		
		private var _currentPacket:OSCPacket;
		
		private var msgListener:Array;
		private var oscMethods:Array;
		private var oscAddressSpace:OSCAddressSpace;
		
		private var running:Boolean;
		
		/**
		 * If <code>true</code> pattern matching is enabled for OSC addresse lookups. The default is <code>false</code>.
		 */
		public var usePatternMatching:Boolean = false;
		
		/**
		 * Creates a new instance of the OSCManager.
		 * @param	connectorIn The IOSConnector which should be used for receiving OSC data.
		 * @param	connectorOut The IOSCConnector which should be used to send OSC data
		 * @param	autoStart If true the OSCManager will immediately begin to process incoming OSCPackets. Default is true.
		 */
		public function OSCManager(connectorIn:IOSCConnector = null, connectorOut:IOSCConnector = null, autoStart:Boolean = true) {
			
			this.msgListener = new Array();
			this.oscMethods = new Array();
			
			this._connectorIn = connectorIn;
			if(this._connectorIn != null) this._connectorIn.addListener(this);
			this._connectorOut = connectorOut;
			
			this.running = autoStart;
			
		}
		
		/**
		 * If called the OSCManager will start to process incoming OSCPackets.
		 */
		public function start():void {
			this.running = true;
		}

		/**
		 * If called the OSCManager will stop to process incoming OSCPackets.
		 */
		public function stop():void {
			this.running = false;
		}
		
		/**
		 * The IOSConnector which is used for receiving OSC data.
		 */
		public function set connectorIn(conn:IOSCConnector):void {
			if (this._connectorIn != null) {
				this._connectorIn.removeListener(this);
			}
			this._connectorIn = conn;
			this._connectorIn.addListener(this);
		}
		
		public function get connectorIn():IOSCConnector {
			return this._connectorIn;
		}
		
		/**
		 * The IOSConnector which is used for sending OSC data.
		 */
		public function set connectorOut(conn:IOSCConnector):void {
			this._connectorOut = conn;
		}
		
		public function get connectorOut():IOSCConnector {
			return this._connectorOut;
		}
		
		/**
		 * Sends the given OSCPacket via the outgoing IOSCConnector.
		 * @param	oscPacket
		 */
		public function sendOSCPacket(oscPacket:OSCPacket):void {
			if(this._connectorOut){
				this._connectorOut.sendOSCPacket(oscPacket);
			}
		}
		
		/**
		 * The OSCPacket which was last received.
		 */
		public function get currentPacket():OSCPacket {
			return this._currentPacket;
		}
		
		/**
		 * @inheritDoc
		 */
		public function acceptOSCPacket(oscPacket:OSCPacket):void {
			if (running) {
				this._currentPacket = oscPacket;
				this.distributeOSCPacket(this._currentPacket);
				oscPacket = null;
			}
		}
		
		/**
		 * Distributes the OSCPacket to all lissteners by checking if the OSCPacket is an
		 * OSCBundle or an OSCMessage and recursively calling itself until the contained
		 * OSCMessages are distibuted.
		 * @param	packet The OSCPacket which has to be distributed
		 */
		private function distributeOSCPacket(packet:OSCPacket):void {
			if (packet is OSCMessage) {
				this.distributeOSCMessage(packet as OSCMessage);
			} else if (packet is OSCBundle) {
				var cont:Array = (packet as OSCBundle).subPackets;
				for each(var p:OSCPacket in cont) {
					this.distributeOSCPacket(p);
				}
			}
		}
		
		/**
		 * Distributes the given OSCMessage to the addressd IOSCListeners.
		 * @param	msg The OSCMessage to distribute.
		 */
		private function distributeOSCMessage(msg:OSCMessage):void {

			for each(var l:IOSCListener in this.msgListener) {
				l.acceptOSCMessage(msg);
			}
			
			if(this.oscMethods.length > 0){
				
				var oscMethod:IOSCListener;
				var oscMethods:Array;
				
				if (this.usePatternMatching) {
					oscMethods = this.oscAddressSpace.getMethods(msg.address);
					for each(l in oscMethods) {
						l.acceptOSCMessage(msg);
					}
				} else {
					oscMethod = this.oscMethods[msg.address];
					if (oscMethod != null) oscMethod.acceptOSCMessage(msg);
				}
			}
			
		}
		
		/**
		 * Registers an OSC Method handler
		 * @param	address The address of the OSC Method
		 * @param	listener The listener for handling calls to the OSC Method
		 */
		public function addMethod(address:String, listener:IOSCListener):void {
			this.oscMethods[address] = listener;
			this.oscAddressSpace.addMethod(address, listener);
		}
		
		/**
		 * Unregisters the OSC Method under the given address
		 * @param	address The address of the OSC Method to be unregistered.
		 */
		public function removeMethod(address:String):void {
			this.oscMethods[address] = null;
			this.oscAddressSpace.removeMethod(address);
		}
		
		/**
		 * Registers a general OSCMethod listener which will be called for every 
		 * recevied OSCMessage.
		 * @param	listener The IOSCListener implementation to handle the OSC Messages.
		 */
		public function addMsgListener(listener:IOSCListener):void {
			if (this.msgListener.indexOf(listener) > -1) return;
			this.msgListener.push(listener);
		}
		
		/**
		 * Removes the given OSC Method listener
		 * @param	listener The listener to be removed.
		 */
		public function removeMsgListener(listener:IOSCListener):void {
			var temp:Array = new Array();
			for each(var l:IOSCListener in this.msgListener) {
				if (l != listener) temp.push(l);
			}
			this.msgListener = temp.concat();
		}
		
	}
	
}