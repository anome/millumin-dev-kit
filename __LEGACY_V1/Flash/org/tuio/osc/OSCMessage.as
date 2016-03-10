package org.tuio.osc {
	
	import flash.errors.EOFError;
	import flash.utils.ByteArray;

	/**
	 * An OSCMessage
	 * @author Immanuel Bauer
	 */
	public class OSCMessage extends OSCPacket {
		
		private var addressPattern:String;
		private var pattern:String;
		private var action:String;
		private var argumentArray:Array;
		private var openArray:Array;
		private var innerArray:Array;
		private var typesArray:Array;
		
		/**
		 * Creates a OSCMessage from the given ByteArray containing a binarycoded OSCMessage
		 * 
		 * @param	bytes A ByteArray containing an OSCMessage
		 */
		public function OSCMessage(bytes:ByteArray = null) {
			super(bytes);
			
			if(bytes != null){
				//read the OSCMessage head
				this.addressPattern = this.readString();
				
				//read the parsing pattern for the following OSCMessage bytes
				this.pattern = this.readString();
				
				this.typesArray = new Array();
				
				this.argumentArray = new Array();
				
				//read the remaining bytes according to the parsing pattern
				this.openArray = this.argumentArray;
				var l:int = this.pattern.length;
				try{
					for(var c:int = 0; c < l; c++){
						switch(this.pattern.charAt(c)){
							case "s": openArray.push(this.readString()); this.typesArray.push("s"); break;
							case "f": openArray.push(this.bytes.readFloat()); this.typesArray.push("f"); break;
							case "i": openArray.push(this.bytes.readInt()); this.typesArray.push("i"); break;
							case "b": openArray.push(this.readBlob()); this.typesArray.push("b"); break;
							case "h": openArray.push(this.read64BInt()); this.typesArray.push("h"); break;
							case "t": openArray.push(this.readTimetag()); this.typesArray.push("t"); break;
							case "d": openArray.push(this.bytes.readDouble()); this.typesArray.push("d"); break;
							case "S": openArray.push(this.readString()); this.typesArray.push("S"); break;
							case "c": openArray.push(this.bytes.readMultiByte(4, "US-ASCII")); this.typesArray.push("c"); break;
							case "r": openArray.push(this.bytes.readUnsignedInt()); this.typesArray.push("r"); break;
							case "T": openArray.push(true); this.typesArray.push("T"); break;
							case "F": openArray.push(false); this.typesArray.push("F"); break;
							case "N": openArray.push(null); this.typesArray.push("N"); break;
							case "I": openArray.push(Infinity); this.typesArray.push("I"); break;
							case "[": innerArray = new Array(); openArray = innerArray; this.typesArray.push("["); break;
							case "]": this.argumentArray.push(innerArray.concat()); openArray = this.argumentArray; this.typesArray.push("]"); break;
							default: break;
						}
					}
				} catch (e:EOFError) {
					trace("corrupt");
					this.argumentArray = new Array();
					this.argumentArray.push("Corrupted OSCMessage");
					openArray = null;
				}
			} else {
				this.pattern = ",";
				this.argumentArray = [];
				this.openArray = this.argumentArray;
			}
		}
		
		/**
		 * Adds a single argument value to the OSCMessage
		 * For special oscTypes like booleans or infinity there is no value needed
		 * If you want to add an OSCArray to the <code>OSCMessage</code> use <code>addArgmuents()</code>
		 * 
		 * @param	oscType The OSCType of the argument.
		 * @param	value The value of the argument.
		 */
		public function addArgument(oscType:String, value:Object = null):void {
			if (oscType.length == 1) {
				if ((oscType == "s" || oscType == "S") && value is String) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.writeString(value as String);
				} else if (oscType == "f" && value is Number) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.bytes.writeFloat(value as Number);
				} else if (oscType == "i" && value is int) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.bytes.writeInt(value as int);
				} else if (oscType == "b" && value is ByteArray) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.writeBlob(value as ByteArray);
				} else if (oscType == "h" && value is ByteArray) {
					this.pattern += oscType; 
					this.openArray.push(value);
				} else if (oscType == "t" && value is OSCTimetag) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.writeTimetag(value as OSCTimetag);
				} else if (oscType == "d" && value is Number) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.bytes.writeDouble(value as Number);
				} else if (oscType == "c" && value is String && (value as String).length == 1) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.bytes.writeMultiByte(value as String, "US-ASCII");
				} else if (oscType == "r" && value is uint) {
					this.pattern += oscType; 
					this.openArray.push(value);
					this.bytes.writeUnsignedInt(value as uint);
				} else if (oscType == "T") {
					this.pattern += oscType; 
					this.openArray.push(true);
				} else if (oscType == "F") {
					this.pattern += oscType; 
					this.openArray.push(false);
				} else if (oscType == "N") {
					this.pattern += oscType; 
					this.openArray.push(null);
				} else if (oscType == "I") {
					this.pattern += oscType; 
					this.openArray.push(Infinity);
				} else {
					throw new Error("Invalid or unknown OSCType or invalid value for given OSCType: " + oscType);
				}
			} else {
				throw new Error("The oscType has to be one character.");
			}
		}
		
		/**
		 * Add multiple argument values to the OSCMessage at once.
		 * 
		 * @param	oscTypes The OSCTypes of the arguments
		 * @param	values The values of the arguments
		 */
		public function addArguments(oscTypes:String, values:Array):void {
			var l:int = oscTypes.length;
			var oscType:String = "";
			var vc:int = 0;
			
			for (var c:int = 0; c < l; c++) {
				oscType = oscTypes.charAt(c);
				if (oscType.charCodeAt(0) < 97) { //isn't a small letter
					if (oscType == "[") {
						innerArray = new Array(); 
						openArray = innerArray;
					} else if (oscType == "]") {
						this.argumentArray.push(innerArray.concat()); 
						openArray = this.argumentArray;
					} else if (oscType == "S") {
						addArgument(oscType, values[vc]);
						vc++;
					} else {
						addArgument(oscType);
					}
				} else {
					addArgument(oscType, values[vc]);
					vc++;
				}
			}
		}
		
		/**
		 * @return The address pattern of the OSCMessage
		 */
		public function get address():String {
			return addressPattern;
		}
		
		/**
		 * Sets the address of the Message
		 */
		public function set address(address:String):void {
			this.addressPattern = address;
		}
		
		/**
		 * @return The arguments/content of the OSCMessage
		 */
		public function get arguments():Array {
			return argumentArray;
		}
		
		/* Returns the bytes of this <code>OSCMessage</code>
		 * 
		 * @return A <code>ByteArray</code> containing the bytes of this <code>OSCMessage</code>
		 */
		public override function getBytes():ByteArray {
			var out:ByteArray = new ByteArray();
			this.writeString(this.address, out);
			this.writeString(this.pattern, out);
			out.writeBytes(this.bytes, 0, this.bytes.length);
			out.position = 0;
			return out;
		}
		
		/**
		 * Generates a String representation of this OSCMessage for debugging purposes
		 * 
		 * @return A traceable String.
		 */
		public override function getPacketInfo():String {
			var out:String = new String();
			out += "\nMessagehead: " + this.addressPattern + " | " + this.pattern + " | ->  (" + this.argumentArray.length + ") \n" + this.argumentsToString() ;
			return out;
		}
		
		/**
		 * Generates a String representation of this OSCMessage's content for debugging purposes
		 * 
		 * @return A traceable String.
		 */
		public function argumentsToString():String{
			var out:String = "arguments: ";
			if(this.argumentArray.length > 0){
				out += this.argumentArray[0].toString();
				for(var c:int = 1; c < this.argumentArray.length; c++){
					out += " | " + this.argumentArray[c].toString();
				}
			}
			return out;
		}
		
		/**
		 * Checks if the given ByteArray is an OSCMessage
		 * 
		 * @param	bytes The ByteArray to be checked.
		 * @return true if the ByteArray contains an OSCMessage
		 */
		public static function isMessage(bytes:ByteArray):Boolean {
			if (bytes != null) {
				//bytes.position = 0;
				var header:String = bytes.readUTFBytes(1);
				bytes.position -= 1;
				if (header == "/") {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		}
		
		/**
		 * This is comfort function for creating an OSCMessage with less code.
		 * 
		 * @param	address The OSCAddress of the <code>OSCMessage</code>.
		 * @param	valueOSCTypes A <code>String</code> of OSCTypes describing the types of the <code>Objects</code> within the <code>values</code> <code>Array</code>. There has to be a type for every value in the <code>values</code> <code>Array</code>.
		 * @param	values An <code>Array</code> containing the values that should be part of the <code>OSCMessage</code>.
		 * @return	An <code>OSCMessage</code> containing the given values.
		 */
		public static function createOSCMessage(address:String, valueOSCTypes:String, values:Array):OSCMessage {
			var msg:OSCMessage = new OSCMessage();
			msg.addressPattern = address;
			msg.addArguments(valueOSCTypes, values);
			return msg;
		}
		
		
		/**
		 *  
		 * @return string representation of an OSCMessage. 
		 * 
		 */
		public function toString():String{
			var toString:String = new String();
			toString = toString + ("<name:");
			toString = toString + ("",this.address);
			toString = toString + (",");
			
			//types
			toString = toString + (" [types: ");
			for(var i:Number=0; i<this.typesArray.length;i++){
				toString = toString + ("",this.typesArray[i]);
				if( i < this.typesArray.length-1){
					toString = toString + (", ");
				}
			}
			toString = toString + ("],");
			
			//arguments
			toString = toString + (" [arguments: ");
			for(i=0; i<this.openArray.length;i++){
				toString = toString + ("",this.openArray[i]);
				if( i < this.openArray.length-1){
					toString = toString + (", ");
				}
			}
			toString = toString + ("]");
			
			toString = toString + (">");
			
			return toString;
		} 
	}
	
}