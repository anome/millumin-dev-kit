package org.tuio.osc {
	
	/**
	 * Represents OSC Containers as described in the OSC Spec. 
	 * Basically OSC Containers are nodes in the OSC Addressspace tree.
	 * This class is used internally for OSC Message Address resolution. 
	 */
	public class OSCContainer {
		
		private var children:Array;
		public var name:String;
		public var method:IOSCListener;
		public var parent:OSCContainer;
		
		/**
		 * Creates a new OSCContainer
		 * @param	name The name of the OSC Container.
		 * @param	method The IOSCListener listening for calls to the OSC Method.
		 */
		public function OSCContainer(name:String, method:IOSCListener = null){
			this.name = name;
			this.method = method;
		}
		
		/**
		 * Adds a child to this OSCContainer.
		 * <p>e.g. if this OSCContainer is called "a" and the added "b", the added OSCContainer will be addressed with "/a/b"</p>
		 * @param	child The child OSCContainer
		 */
		public function addChild(child:OSCContainer):void {
			this.children[child.name] = child;
			child.parent = this;
		}
		
		/**
		 * Trys to retreive the child with the given name.
		 * @param	name The name of the requested child.
		 * @return The child with the given name or null
		 */
		public function getChild(name:String):OSCContainer {
			return this.children[name];
		}
		
		/**
		 * Fetches all children matching the given pattern. 
		 * The pattern syntax is explained in the OSC Specification in the segment about OSC Addresses.
		 * @param	pattern The pattern which shall be used to match against the children's names.
		 * @return An Array containing all children which names matched the given pattern.
		 */
		public function getMatchingChildren(pattern:String):Array {
			var out:Array = new Array();
			
			var firstSeperator:int = pattern.indexOf("/");
			var part:String = pattern.substring(0, firstSeperator);
			var rest:String = pattern.substring(firstSeperator + 1, pattern.length); 
			var done:Boolean = (pattern.indexOf("/")==-1);
			
			for each(var child:OSCContainer in this.children) {
				
				if (child.matchName(part)) {
					if (done) {
						if(child.method != null) out.push(child.method);
					} else {
						out = out.concat(child.getMatchingChildren(rest));
					}
				}
				
			}
			
			return out;
		}
		
		/**
		 * Removes the OSCContainer from children.
		 * @param	child The OSCContainer which shall be removed.
		 */
		public function removeChild(child:OSCContainer):void {
			if (child.hasChildren) child.method = null;
			else this.children[child.name] = null;
		}
		
		/**
		 * Matches the name against the given pattern.
		 * The pattern syntax is explained in the OSC Specification in the segment about OSC Addresses.
		 * @param	pattern The pattern to match against.
		 * @return <code>true</code> if the name matches against the pattern. Otherwise <code>false</code>.
		 */
		public function matchName(pattern:String):Boolean {
			
			if (pattern == this.name) return true;
			
			if (pattern == "*") return true;
			
			//convert address patter to regular expression
			var regExStr:String = "";
			for (var c:uint = 0; c < pattern.length; c++) {
				switch(pattern.charAt(c)) {
					case "{": regExStr += "(" ; break;
					case "}": regExStr += ")" ; break;
					case ",": regExStr += "|" ; break;
					case "*": regExStr += ".*" ; break;
					case "?": regExStr += ".+" ; break;
					default: regExStr += pattern.charAt(c); break;
				}
			}
			
			var regEx:RegExp = new RegExp(regExStr, "g");
			
			if (regEx.test(this.name) && regEx.lastIndex == this.name.length) return true; 
			
			return false;
			
		}
		
		/**
		 * Is <code>true</code> if the OSCContainer has children. Otherwise <code>false</code>.
		 */
		public function get hasChildren():Boolean {
			
			return (children.length > 0);
			
		}
		
	}
	
}