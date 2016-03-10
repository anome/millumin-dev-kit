package org.tuio.connectors
{
	import flash.utils.ByteArray;
	
	import org.tuio.connectors.udp.OSCDatagramSocket;
	import org.tuio.osc.IOSCConnector;
	import org.tuio.osc.IOSCConnectorListener;
	import org.tuio.osc.OSCBundle;
	import org.tuio.osc.OSCEvent;
	import org.tuio.osc.OSCMessage;
	import org.tuio.osc.OSCPacket;

	/**
	 * An implementation of the <code>IOSCConnector</code> using UDP.
	 * This connector only works in Adobe AIR since v2 due to it using the <code>DatagramSocket</code>
	 * 
	 * This connector can be used to send an receive OSC bundles and messages. 
	 * Though you have to create seperate instances of the connector.
	 * 
	 * @author Johannes Luderschmidt
	 * @author Immanuel Bauer
	 * 
	 */
	public class UDPConnector implements IOSCConnector
	{
		private var connection:OSCDatagramSocket;
		private var listeners:Array;
		
		/**
		 * 
		 * @example The following code shows three approaches to initialize UDPConnector. Use only one of them:
		 * <listing version="3.0">
		 * //tracker runs on localhost on default port 3333
		 * var tuio:TuioClient = new TuioClient(new UDPConnector());
		 * //or 
		 * //tracker runs on 192.0.0.5 on default port 3333 
		 * var tuio:TuioClient = new TuioClient(new UDPConnector("192.0.0.5"));
		 * //or
		 * //tracker runs on 192.0.0.5 on port 3334
		 * var tuio:TuioClient = new TuioClient(new UDPConnector("192.0.0.5",3334));
		 * </listing>
		 * 
		 * @param host ip of the tracker resp. tuio message producer.
		 * @param port of the tracker resp. tuio message producer.
		 * @param bind If true the <code>UDPConnector</code> will try to bind the given IP:port and to receive packets. If false the <code>UDPConnector</code> connects to the given IP:port and will wait for calls of <code>UDPConnector.sendOSCPacket()</code>
		 *
		 */
		public function UDPConnector(host:String = "127.0.0.1", port:int = 3333, bind:Boolean = true)
		{
			this.listeners = new Array();
			
			this.connection = new OSCDatagramSocket(host, port, bind);
			this.connection.addEventListener(OSCEvent.OSC_DATA,receiveOscData);
		}
		
		/**
		 * parses an incoming OSC message.
		 * 
		 * @private
		 * 
		 */
		public function receiveOscData(e:OSCEvent):void {
			var packet:ByteArray = new ByteArray();
			packet.writeBytes(e.data);
			packet.position = 0;
			
			if (packet != null) {
				if (this.listeners.length > 0) {
					//call receive listeners and push the received messages
					for each(var l:IOSCConnectorListener in this.listeners) {
						//packet has to be copied in order to allow for more than one listener
						//that actually reads from the ByteArray (after one listener has read,
						//packet will be empty)
						var copyPacket:ByteArray = copyPacket(packet);
						if (OSCBundle.isBundle(packet)) {
							l.acceptOSCPacket(new OSCBundle(packet));
						} else if (OSCMessage.isMessage(packet)) {
							l.acceptOSCPacket(new OSCMessage(packet));
						} else {
							//this.debug("\nreceived: invalid osc packet.");
						}
						packet = copyPacket;
					}
				}
			}
			
			packet = null;
		}
		
		private function copyPacket(packet:ByteArray):ByteArray{
			var copyPacket:ByteArray = new ByteArray();
			copyPacket.writeBytes(packet);
			copyPacket.position = 0;
			return copyPacket;
		}
		
		/**
		 * @inheritDoc 
		 */
		public function addListener(listener:IOSCConnectorListener):void
		{
			if (this.listeners.indexOf(listener) > -1) return;
			
			this.listeners.push(listener);
		}
		
		/**
		 * @inheritDoc 
		 */
		public function removeListener(listener:IOSCConnectorListener):void
		{
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
		public function sendOSCPacket(oscPacket:OSCPacket):void
		{
			if (this.connection.connected) this.connection.send(oscPacket.getBytes());
			else throw new Error("Can't send if not connected.");
		}
		
		/**
		 * @inheritDoc 
		 */
		public function close():void
		{
			if (this.connection.connected) this.connection.close();
		}
	}
}