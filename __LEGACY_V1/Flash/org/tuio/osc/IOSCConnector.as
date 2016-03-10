package org.tuio.osc {
	
	/**
	 * This interface has to be implemented in order to receive OSC data
	 * via a certain connection and forward it to the OSCManager.
	 */
    public interface IOSCConnector {
		
		/**
		 * Adds a listener for incoming data to a private list. 
		 * @param	listener A listener for incoming data
		 */
		function addListener(listener:IOSCConnectorListener):void;
		
		/**
		 * Removes a listener for incoming data to a private list. 
		 * @param	listener A listener for incoming data
		 */
		function removeListener(listener:IOSCConnectorListener):void;
		
		/**
		 * Sends an OSCPacket via the connection type implemented by this IOSCConnector.
		 * @param	oscPacket The OSCPacket to be sent via this connection.
		 */
		function sendOSCPacket(oscPacket:OSCPacket):void;
		
		/**
		 * Closes the connector
		 */
		function close():void;
    }
	
}