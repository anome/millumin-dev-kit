package org.tuio.osc {
	
	/**
	 * An internaly used class which implements a tree structure
	 * for managing OSCContainers and speeding up OSCAddress lookups.
	 */
	public class OSCAddressSpace {
		
		private var root:OSCContainer;
		
		public function OSCAddressSpace() {
			this.root = new OSCContainer("");
		}
		
		/**
		 * Adds a OSC Method to the lookup tree.
		 * @param	address The OSC Address of the OSC Method.
		 * @param	method The IOSCListener handling calls to the OSC Method.
		 */
		public function addMethod(address:String, method:IOSCListener):void {
			var parts:Array = address.split("/");
			var part:String;
			var currentNode:OSCContainer = root;
			var nextNode:OSCContainer;
			while (parts.length > 0) {
				part = parts.pop();
				nextNode = currentNode.getChild(part);
				if (nextNode == null) {
					nextNode = new OSCContainer(part);
					currentNode.addChild(nextNode);
				}
				currentNode = nextNode;
			}
			currentNode.method = method;
		}
		
		/**
		 * Removes the OSC Method stored under the given Address from the tree.
		 * @param	address The OSC Address of th eOSC Method to be removed.
		 */
		public function removeMethod(address:String):void {
			var parts:Array = address.split("/");
			var part:String;
			var currentNode:OSCContainer = root;
			var nextNode:OSCContainer;
			while (parts.length > 0) {
				part = parts.pop();
				nextNode = currentNode.getChild(part);
				if (nextNode == null) {
					break;
				}
				currentNode = nextNode;
			}
			currentNode.parent.removeChild(currentNode);
		}
		
		/**
		 * Retreives all OSC Methods stored in the tree matching the given OSC Address pattern.
		 * @param	pattern The OSC Address pattern to match against.
		 * @return An Array containing all matching OSCContainers.
		 */
		public function getMethods(pattern:String):Array {
			return root.getMatchingChildren(pattern.substr(1, pattern.length));
		}
		
	}
	
}