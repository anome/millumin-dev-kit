package org.tuio {
	
	/**
	 * A simple naming extension of the <code>Error</code> class to propagate TUIO errors
	 */
	public class TuioError extends Error {
		
		public function TuioError(msg:String){
			super(msg);
		}
		
	}
	
}