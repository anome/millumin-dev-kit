package org.tuio.osc {
	
	/**
	 * Has to be implemented in order to receive data from an IOSCConnector implementation
	 */
    public interface IOSCConnectorListener {
		
		/**
		 * Accept a received OSCPacket
		 * @param	oscPacket The received OSCPacket.
		 */
		function acceptOSCPacket(oscPacket:OSCPacket):void;
		
    }
	
}