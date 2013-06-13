package org.tuio.connectors {
	
	import flash.utils.ByteArray;
	
	import org.tuio.osc.*;
	import org.tuio.connectors.lc.*;
	
	/**
	 * This implementation of the <code>IOSCConnector</code> uses Flash's <code>LocalConnection</code> to receive and send OSC data.
	 * It is primarily meant to be used with Georg Kaindl's UPD -> LC bridge: http://gkaindl.com/software/udp-flashlc-bridge
	 * Though you can run into problems depending on the tracker and the amount of data that is transmitted.
	 * 
	 * If you want to transmit OSC bundles between two Flash instances this connector probably will do better than UDP.
	 * Note that the default values for the connection names used by the constructor do not support this out of the box. 
	 */
	public class LCConnector implements IOSCConnector {
		
		private var connectionNameIn:String;
		private var connectionNameOut:String;
		
		private var connectionOut:LCSender;
		private var connectionIn:LCReceiver;
		
		private var listeners:Array;
		
		/**
		 * Creates an instance of the LCConnector 
		 * @param	connectionNameIn The name of the <code>LocalConnection</code> to receive from. If the name is already in use a number will be added.
		 * @param	connectionNameOut The name of the <code>LocalConnection</code> to send data to.
		 */
		public function LCConnector(connectionNameIn:String = "_OscDataStream", connectionNameOut:String = "_OscDataStreamOut") {
			
			this.listeners = new Array();
			
			this.connectionNameIn = connectionNameIn;
			this.connectionNameOut = connectionNameOut;
			
			this.connectionIn = new LCReceiver(this.connectionNameIn, this);
			this.connectionOut = new LCSender(this.connectionNameOut, "receiveOscData");
			
			this.connectionIn.start();
		}
		
		/**
		 * @private
		 */
		public function receiveOscData(packet:ByteArray):void {		
			if (packet != null) {
				if (this.listeners.length > 0) {
					//call receive listeners and push the received messages
					for each(var l:IOSCConnectorListener in this.listeners) {
						if (OSCBundle.isBundle(packet)) {
							l.acceptOSCPacket(new OSCBundle(packet));
						} else if (OSCMessage.isMessage(packet)) {
							l.acceptOSCPacket(new OSCMessage(packet));
						} else {
							this.debug("\nreceived: invalid osc packet.");
						}
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function addListener(listener:IOSCConnectorListener):void {
			
			if (this.listeners.indexOf(listener) > -1) return;
			
			this.listeners.push(listener);
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeListener(listener:IOSCConnectorListener):void {
			
			var tmp:Array = this.listeners.concat();
			var newList:Array = new Array();
			
			var item:Object = tmp.pop();
			while (item != null) {
				if (item != listener) newList.push(item);
			}
			
			this.listeners = newList;
			
		}
		
		/**
		 * @inheritDoc
		 */
		public function sendOSCPacket(oscPacket:OSCPacket):void {
			
			this.connectionOut.send(oscPacket);
			
		}
		
		/**
		 * @inheritDoc 
		 */
		public function close():void
		{
			connectionIn.stop();
		}
		
		private function debug(msg:String):void {
			trace(msg);
		}
		
	}
	
}
	