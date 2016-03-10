package org.tuio.debug
{
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import org.tuio.*;

	/**
	 * 
	 * <p>implements the interface <code>ITuioListener</code> to show debug information about all tuio cursors and objects 
	 * that are prevailing in the application.</p>
	 * 
	 * <p>The appearance of the cursors and objects is controlled by the classes <code>TuioDebugCursor</code> and 
	 * <code>TuioDebugObject</code>. Their appearance can be tweaked with multiple settings. Additionally, custom debug cursor 
	 * and object implementations can be set via the functions <code>customCursorSprite</code> and <code>customObjectClass</code>.</p> 
	 * 
	 * @see org.tuio.ITuioListener
	 * @see TuioDebugCursor
	 * @see ITuioDebugCursor
	 * @see TuioDebugObject
	 * @see ITuioDebugObject
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class TuioDebug implements ITuioListener{
		
		[Embed(source="/org/tuio/assets/fonts.swf", fontName="Arial")]
		private var Arial:Class;
		private var arialFont:Font;
		
		private var stage:Stage;
		private var tuioClient:TuioClient;
		
		private var fseq:uint;
		
		private var cursors:Array;
		private var objects:Array;
		private var blobs:Array;
		
		private var _showCursors:Boolean = true;
		private var _showObjects:Boolean = true;
		private var _showBlobs:Boolean = true;
		
		private var _showDebugText:Boolean = true;
		
		private var _cursorRadius:Number = 13;
		private var _cursorColor:Number = 0x0;
		private var _cursorAlpha:Number = 0;
		private var _cursorLineThickness:Number = 3;
		private var _cursorLineColor:Number = 0x0;
		private var _cursorLineAlpha:Number = 0.5;
		private var _customCursorSprite:Class;
		
		private var _objectWidth:Number = 80;
		private var _objectHeight:Number = 80;
		private var _objectColor:Number = 0x0;
		private var _objectAlpha:Number = 0.5;
		private var _objectLineThickness:Number = 0;
		private var _objectLineColor:Number = 0x0;
		private var _objectLineAlpha:Number = 0;
		private var _customObjectClass:Class;
		
		private static var allowInst:Boolean;
		private static var inst:TuioDebug;
		
		public function TuioDebug(stage:Stage){
			if (!allowInst) {
	            throw new Error("Error: Instantiation failed: Use TuioDebug.getInstance() instead of new.");
			}else{
				this.stage = stage;
				fseq = 0;
				cursors = new Array();
				objects = new Array();
				blobs = new Array();
				
				_customObjectClass = TuioDebugObject;
				_customCursorSprite = TuioDebugCursor;
				
				this.arialFont = new Arial(); 
			}
		}
		
		/**
		 * initializes Singleton instance of TuioDebug. Must be called before <code>getInstance()</code> 
		 * can be called.
		 *  
		 * @param stage
		 * @return Singleton instance of TuioDebug.
		 * 
		 */
		public static function init(stage:Stage):TuioDebug{
			if(inst == null){
				allowInst = true;
				inst = new TuioDebug(stage);
				allowInst = false;
			}
			
			return inst;
		}
		
		/**
		 * Singleton instance of TuioDebug.
		 * 
		 * @return Singleton instance of TuioDebug.
		 * 
		 */
		public static function getInstance():TuioDebug{
			if(inst == null){
				throw new Error("Please initialize with method init(...) first!");
			}
			return inst;
		}
		
		/**
		 * Called if a new object was tracked.
		 * @param	tuioObject the received /tuio/2Dobj.
		 */
		public function addTuioObject(tuioObject:TuioObject):void{
			addTuioObjectWithDebugOption(tuioObject, false);
		}
		
		/**
		 * creates actual debug representation of TUIO object and shows it on screen 
		 *  
		 * @param tuioObject the current TUIO object
		 * @param debugMode sets whether the TUIO id should be shown (debugMode == false) or 
		 * whether only the hint 'Debug' should be shown (debugMode == true) as the debug TUIO session id 
		 * starts  
		 * with the highest possible unsigned integer value and decrements for each other TUIO debug
		 * element in order to not interfere with regular TUIO session ids from a tracker or from
		 * the TUIO debug application. Thus, the high session ids would be looking awkwardly and only
		 * the 'Debug' string is being shown.
		 * 
		 */
		public function addTuioObjectWithDebugOption(tuioObject:TuioObject, debugMode:Boolean):void{
			var objectSprite:Sprite;
			
			if(_customObjectClass == TuioDebugObject){
				objectSprite = new TuioDebugObject(tuioObject.classID, tuioObject.sessionID, tuioObject.a, _objectWidth, _objectHeight, _objectColor, _objectAlpha,_objectLineThickness, _objectLineColor, _objectLineAlpha, tuioObject.source);
			}else{
				objectSprite = new _customObjectClass(tuioObject);
				if(!(objectSprite is ITuioDebugObject)){
					throw new Error("Custom Tuio Object class must implement ITuioDebugObject.");
				}
			}
			var objectObject:Object = new Object();
			if(_showObjects){
				objectSprite.x = tuioObject.x*stage.stageWidth;
				objectSprite.y = tuioObject.y*stage.stageHeight;
				
				objectSprite.rotation = tuioObject.a/Math.PI*180;
				
				objectObject.object = objectSprite;
				objectObject.sessionID = tuioObject.sessionID;
				objectObject.source = tuioObject.source;
				objects.push(objectObject);
				stage.addChild(objectSprite);
				
				if(_showDebugText){
					var label:TextField = new TextField();
					label.autoSize = TextFieldAutoSize.LEFT;
					label.selectable = false;
					label.background = false;
					label.border = false;
					label.text = generateObjectLabelText(objectSprite.x, objectSprite.y, tuioObject.classID, tuioObject.sessionID, debugMode);
				
					label.defaultTextFormat = debugTextFormat();
					label.setTextFormat(debugTextFormat());
					label.embedFonts = true;
					
					objectSprite.addChild(label);
					label.x  = Math.round(_objectWidth/2);
					label.y  = -Math.round(label.height/2);
					
					objectObject.label = label;
				}
			}
		}
		
		/**
		 * updates the display of the TUIO debug object
		 * 
		 * @param	tuioObject The received /tuio/2Dobj.
		 */
		public function updateTuioObject(tuioObject:TuioObject):void{
			updateTuioObjectWithDebugOption(tuioObject, false);
		}
		
		/**
		 * updates the display of the TUIO debug object.
		 *  
		 * @param tuioObject The received /tuio/2Dobj.
		 * @param debugMode sets whether the TUIO id should be shown (debugMode == false) or 
		 * whether only the hint 'Debug' should be shown (debugMode == true) as the debug TUIO session id 
		 * starts  
		 * with the highest possible unsigned integer value and decrements for each other TUIO debug
		 * element in order to not interfere with regular TUIO session ids from a tracker or from
		 * the TUIO debug application. Thus, the high session ids would be looking awkwardly and only
		 * the 'Debug' string is being shown.
		 * 
		 */
		public function updateTuioObjectWithDebugOption(tuioObject:TuioObject, debugMode:Boolean):void{
			for each(var object:Object in objects){
				if(object.sessionID == tuioObject.sessionID){
					var debugObject:DisplayObjectContainer = object.object as DisplayObjectContainer; 
					debugObject.x = tuioObject.x*stage.stageWidth;
					debugObject.y = tuioObject.y*stage.stageHeight;
					debugObject.rotation = tuioObject.a/Math.PI*180;
					if(_showDebugText){
						object.label.text = generateObjectLabelText(object.object.x, object.object.y, tuioObject.classID, tuioObject.sessionID, debugMode);
						object.label.setTextFormat(debugTextFormat());
					}
					break;
				}
			}
		}
		
		/**
		 * Called if a tracked object was removed.
		 * 
		 * @param	tuioObject The values of the received /tuio/2Dobj.
		 */
		public function removeTuioObject(tuioObject:TuioObject):void{
			var i:Number = 0;
			for each(var object:Object in objects){
				if(object.sessionID == tuioObject.sessionID){
					stage.removeChild(object.object);
					objects.splice(i,1);
					break;
				}
				i=i+1;
			}
		}

		/**
		 * width of debug object rectangle.
		 * 
		 */
		public function get objectWidth():Number{
			return _objectWidth;
		}
		public function set objectWidth(objectWidth:Number):void{
			_objectWidth = objectWidth;
		}
		
		
		/**
		 * height of debug object rectangle. 
		 * 
		 */
		public function get objectHeight():Number{
			return _objectHeight;
		}
		public function set objectHeight(objectHeight:Number):void{
			_objectHeight = objectHeight;
		}
		
		
		/**
		 * color of the filling of debug object rectangle.
		 *  
		 */
		public function get objectColor():Number{
			return _objectColor;
		}
		public function set objectColor(objectColor:Number):void{
			_objectColor = objectColor;
		}
		
		/**
		 * alpha of the filling of debug object rectangle. 
		 * 
		 */
		public function get objectAlpha():Number{
			return _objectAlpha;
		}
		public function set objectAlpha(objectAlpha:Number):void{
			_objectAlpha = objectAlpha;
		}
		
		/**
		 * thickness of the line around a debug object rectangle.
		 *  
		 */	
		public function get objectLineThickness():Number{
			return _objectLineThickness;
		}
		public function set objectLineThickness(objectLineThickness:Number):void{
			_objectLineThickness = objectLineThickness;
		}
		
		/**
		 * color of the line around a debug object rectangle.
		 *  
		 */
		public function get objectLineColor():Number{
			return _objectLineColor;
		}
		public function set objectLineColor(objectLineColor:Number):void{
			_objectLineColor = objectLineColor;
		}
		
		/**
		 * alpha of the line around a debug object rectangle.
		 *  
		 */
		public function get objectLineAlpha():Number{
			return _objectLineAlpha;
		}
		public function set objectLineAlpha(objectLineAlpha:Number):void{
			_objectLineAlpha = objectLineAlpha;
		}
		
		/**
		 * sets base class for the Sprite that should be drawn on screen when a new
		 * object is added via a Tuio message.
		 *  
		 */
		public function get customObjectClass():Class{
			return _customObjectClass;
		}
		public function set customObjectClass (customObjectClass:Class):void{
			_customObjectClass = customObjectClass;
		}
		
		/**
		 * Called if a new cursor was tracked.
		 * @param	tuioObject The values of the received /tuio/**Dcur.
		 */
		public function addTuioCursor(tuioCursor:TuioCursor):void{
			var cursorSprite:Sprite;
			
			if(_customCursorSprite == TuioDebugCursor){
				cursorSprite = new TuioDebugCursor(_cursorRadius,_cursorColor, _cursorAlpha, _cursorLineThickness, _cursorLineColor, _cursorLineAlpha);
			}else{
				try{
					cursorSprite = new _customCursorSprite(tuioCursor);
				}catch(error:Error){
					cursorSprite = new _customCursorSprite();
				}
				if(!(cursorSprite is ITuioDebugCursor)){
					throw new Error("Custom Tuio Debug Cursor class must implement ITuioDebugCursor.");
				}
			}
			(cursorSprite as ITuioDebugCursor).sessionId = tuioCursor.sessionID;
			(cursorSprite as ITuioDebugCursor).source = tuioCursor.source;
			
			var cursorObject:Object = new Object();
			
			if(_showCursors){
				cursorSprite.x = tuioCursor.x*stage.stageWidth;
				cursorSprite.y = tuioCursor.y*stage.stageHeight;
				cursorObject.cursor = cursorSprite;
				cursorObject.sessionID = tuioCursor.sessionID;
				cursorObject.source = tuioCursor.source;
				cursors.push(cursorObject);
				stage.addChild(cursorSprite);
				
				if(_showDebugText){
					var label:TextField = new TextField();
					label.autoSize = TextFieldAutoSize.LEFT;
					label.selectable = false;
					label.background = false;
					label.border = false;
					label.text = generateCursorLabelText(cursorSprite.x, cursorSprite.y, tuioCursor.sessionID, tuioCursor.source);
					
					label.defaultTextFormat = debugTextFormat();
					label.setTextFormat(debugTextFormat());
					label.embedFonts = true;
					
					cursorSprite.addChild(label);
					label.x = _cursorRadius+3;
					label.y = -Math.round(label.height/2);
					
					cursorObject.label = label;
				}
			}
		}
		
		/**
		 * Called if a tracked cursor was updated.
		 * @param	tuioCursor The values of the received /tuio/2Dcur.
		 */
		public function updateTuioCursor(tuioCursor:TuioCursor):void{
			for each(var cursor:Object in cursors){
				if(cursor.sessionID == tuioCursor.sessionID && cursor.source == tuioCursor.source){
					cursor.cursor.x = tuioCursor.x*stage.stageWidth;
					cursor.cursor.y = tuioCursor.y*stage.stageHeight;
					
					if(_showDebugText){
						cursor.label.text = generateCursorLabelText(cursor.cursor.x, cursor.cursor.y, tuioCursor.sessionID, tuioCursor.source);
					}
					break;
				}
			}
		}
		
		/**
		 * Called if a tracked cursor was removed.
		 * @param	tuioCursor The values of the received /tuio/2Dcur.
		 */
		public function removeTuioCursor(tuioCursor:TuioCursor):void{
			var i:Number = 0;
			for each(var cursor:Object in cursors){
				if(cursor.sessionID == tuioCursor.sessionID && cursor.source == tuioCursor.source){
					stage.removeChild(cursor.cursor);
					cursors.splice(i,1);
					break;
				}
				i=i+1;
			}
		}
		
		private function generateCursorLabelText(xVal:Number, yVal:Number, id:Number, source:String):String{
			var cursorLabel:String;
			cursorLabel = "x: " + xVal + "\ny: " + yVal + "\nsessionId: " + id+ "\nsource: " + source;
			return cursorLabel;
		}
		
		private function debugTextFormat():TextFormat{
			var format:TextFormat = new TextFormat();
	            format.font = this.arialFont.fontName;
	            format.color = 0x0;
	            format.size = 11;
	            format.underline = false;
	            
        	return format;
		}
		
		/**
		 * Called if a new blob was tracked.
		 * @param	tuioBlob The values of the received /tuio/**Dblb.
		 */
		public function addTuioBlob(tuioBlob:TuioBlob):void{
			if(_showBlobs){
				_showCursors = true;
				addTuioCursor(new TuioCursor("2dcur", tuioBlob.sessionID, tuioBlob.x, tuioBlob.y, tuioBlob.z,tuioBlob.X, tuioBlob.Y, tuioBlob.Z, tuioBlob.m, tuioBlob.frameID, "TuioDebug"));
			}
		}

		/**
		 * Called if a tracked blob was updated.
		 * @param	tuioBlob The values of the received /tuio/**Dblb.
		 */
		public function updateTuioBlob(tuioBlob:TuioBlob):void{
			if(_showBlobs){
				_showCursors = true;
				updateTuioCursor(new TuioCursor("2dcur", tuioBlob.sessionID, tuioBlob.x, tuioBlob.y, tuioBlob.z,tuioBlob.X, tuioBlob.Y, tuioBlob.Z, tuioBlob.m, tuioBlob.frameID, "TuioDebug"));
			}
				
		}
		
		/**
		 * Called if a tracked blob was removed.
		 * @param	tuioBlob The values of the received /tuio/**Dblb.
		 */
		public function removeTuioBlob(tuioBlob:TuioBlob):void{
			if(_showBlobs){
				_showCursors = true;
				removeTuioCursor(new TuioCursor("2dcur", tuioBlob.sessionID, tuioBlob.x, tuioBlob.y, tuioBlob.z,tuioBlob.X, tuioBlob.Y, tuioBlob.Z, tuioBlob.m, tuioBlob.frameID, "TuioDebug"));
			}
		}
		
		public function newFrame(id:uint):void {
			this.fseq = id;
        }
		
		private function generateObjectLabelText(xVal:Number, yVal:Number, objectId:Number, sessionId:Number, debugMode:Boolean=false):String{
			var objectLabel:String;
			if(!debugMode){
				objectLabel = "x: " + xVal + "\ny: " + yVal + "\nfiducialId: " + objectId+ "\nsessionId: " + sessionId;
			}else{
				objectLabel = "x: " + xVal + "\ny: " + yVal + "\nfiducialId: " + objectId+ "\nsessionId: Debug";
			}
			return objectLabel;
		}
		
		/**
		 * radius of the debug cursor circle.
		 *  
		 */
		public function get cursorRadius():Number{
			return _cursorRadius;
		}
		public function set cursorRadius(cursorRadius:Number):void{
			_cursorRadius = cursorRadius;
		}
		
		/**
		 * color of the filling of the debug cursor circle.
		 *  
		 */
		public function get cursorColor():Number{
			return _cursorColor;
		}
		public function set cursorColor(cursorColor:Number):void{
			_cursorColor = cursorColor;
		}
		
		/**
		 * alpha of the filling of the debug cursor circle.
		 *  
		 */
		public function get cursorAlpha():Number{
			return _cursorAlpha;
		}
		public function set cursorAlpha(cursorAlpha:Number):void{
			_cursorAlpha = cursorAlpha;
		}
		
		/**
		 * thickness of the line around a debug cursor circle.
		 * 
		 */
		public function get cursorLineThickness():Number{
			return _cursorLineThickness;
		}
		public function set cursorLineThickness(cursorLineThickness:Number):void{
			_cursorLineThickness = cursorLineThickness;
		}
		
		/**
		 * color of the line around a debug cursor circle.
		 *  
		 */
		public function get cursorLineColor():Number{
			return _cursorLineColor;
		}
		public function set cursorLineColor(cursorLineColor:Number):void{
			_cursorLineColor = cursorLineColor;
		}
		
		/**
		 * alpha of the line around a debug cursor circle.
		 *  
		 */
		public function get cursorLineAlpha():Number{
			return _cursorLineAlpha;
		}
		public function set cursorLineAlpha(cursorLineAlpha:Number):void{
			_cursorLineAlpha = cursorLineAlpha;
		}
		
		/**
		 * controls whether debug text (session id, x position, y position and fiducial id) should be shown next to
		 * a debug cursor or debug object.
		 *   
		 * @param showDebugText 
		 * 
		 */
		public function set showDebugText(showDebugText:Boolean):void{
			_showDebugText = showDebugText;
		}
		
		public function get showDebugText():Boolean{
			return _showDebugText;
		}
		
		/**
		 * sets base class for the Sprite that should be drawn on screen when a new
		 * cursor is added via a Tuio message.
		 *  
		 * @param customCursorSprite class name of class that should be used as debug cursor information.
		 * 
		 */
		public function set customCursorSprite (customCursorSprite:Class):void{
			_customCursorSprite = customCursorSprite;
		}
		
		/**
		 * returns base class of the Sprite that is being drawn on screen when a new
		 * cursor is added via a Tuio message.
		 *  
		 * @return class of debug cursor sprite. 
		 * 
		 */
		public function get customCursorSprite():Class{
			return _customCursorSprite;
		}
		
		/**
		 * controls whether debug information for objects is shown. 
		 *   
		 * @param showCursors 
		 * 
		 */
		public function set showCursors(showCursors:Boolean):void{
			_showCursors = showCursors;
		}
		public function get showCursors():Boolean{
			return _showCursors;
		}
		
		/**
		 * controls whether debug information for objects is shown. 
		 *   
		 * @param showCursors 
		 * 
		 */
		public function set showObjects(showObjects:Boolean):void{
			_showObjects = showObjects;
		}
		public function get showObjects():Boolean{
			return _showObjects;
		}
		
	}
}