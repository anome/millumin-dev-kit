package org.tuio.osc {
	
	/**
	 * Has to be implemented in order to handle requests to certain OSC Methods
	 */
    public interface IOSCListener {
		
		/**
		 * Accepts an OSCMessage for further handling and processing
		 * @param	oscmsg The OSCMessage which has to be handled.
		 */
		function acceptOSCMessage(oscmsg:OSCMessage):void;
		
    }
	
}