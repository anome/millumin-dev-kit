package org.tuio {
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import org.tuio.adapters.AbstractTuioAdapter;
	import org.tuio.debug.ITuioDebugBlob;
	import org.tuio.debug.ITuioDebugCursor;
	import org.tuio.debug.ITuioDebugObject;
	import org.tuio.debug.ITuioDebugTextSprite;
	import org.tuio.util.DisplayListHelper;
	
	/**@eventType org.tuio.TuioEvent.ADD*/
	[Event(name = "org.tuio.TuioEvent.add", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.UPDATE*/
	[Event(name = "org.tuio.TuioEvent.update", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.REMOVE*/
	[Event(name = "org.tuio.TuioEvent.remove", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.ADD_OBJECT*/
	[Event(name = "org.tuio.TuioEvent.addObject", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.UPDATE_OBJECT*/
	[Event(name = "org.tuio.TuioEvent.updateObject", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.REMOVE_OBJECT*/
	[Event(name = "org.tuio.TuioEvent.removeObject", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.ADD_CURSOR*/
	[Event(name = "org.tuio.TuioEvent.addCursor", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.UPDATE_CURSOR*/
	[Event(name = "org.tuio.TuioEvent.updateCursor", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.REMOVE_CURSOR*/
	[Event(name = "org.tuio.TuioEvent.removeCursor", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.ADD_BLOB*/
	[Event(name = "org.tuio.TuioEvent.addBlob", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.UPDATE_BLOB*/
	[Event(name = "org.tuio.TuioEvent.updateBlob", type = "org.tuio.TuioEvent")]
	/**@eventType org.tuio.TuioEvent.REMOVE_BLOB*/
	[Event(name = "org.tuio.TuioEvent.removeBlob", type = "org.tuio.TuioEvent")]
	
	/**
	 * The TuioManager class implements the ITuioListener interface and dispatches events 
	 * into Flash's event flow according to the called callback functions.
	 * 
	 * <p><b>Dispatched events</b></p>
	 * <ul>
	 * 	<li>TuioEvent: Is dispatced on the TuioManager itself.</li>
	 * 	<li>TuioTouchEvent: Is dispatched on DisplayObjects under the tracked point according to the TuioManager's settings.</li>
	 * 	<li>TuioFiducialEvent: Is dispatched on DisplayObjects under the tracked point according to the TuioManager's settings.</li>
	 * </ul>
	 * 
	 <p><b>Callback system</b></p>
	 * <ul>
	 * 	<li>Touches: Callbackreceivers can register themselves in order to receive callbacks for a certain session id. 
	 * 	A touch callback class must implement <code>ITuioTouchReceiver</code>.</li>
	 * 	<li>Fiducials: Callbackreceivers can register themselves in order to receive callbacks for a certain fiducial id. 
	 * 	A fiducial callback class must implement <code>ITuioFiducialReceiver</code>.</li>
	 * </ul>
	 * 
	 * @author Immanuel Bauer
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class TuioManager extends EventDispatcher implements ITuioListener {
		
		/**The number of milliseconds within two subsequent taps trigger a double tap.*/
		public var doubleTapTimeout:int = 300;
		
		/**The maximum distance between two subsequent taps on the x/y axis to be counted as double tap in px*/
		public var doubleTapDistance:Number = 10;
		 
		/**The time between a touch down event and a hold event in ms*/
		public var holdTimeout:int = 500;
		
		/**If set true a TuioTouchEvent is triggered if a TuioObject is received. The default is false.*/
		public var triggerTouchOnObject:Boolean = false;
		
		/**If set true a TuioTouchEvent is triggered if a TuioBlob is received. The default is false.*/
		public var triggerTouchOnBlob:Boolean = false;	
		
		/**Sets the method how to discover the TuioTouchEvent's target object. The default is TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED.*/
		public var touchTargetDiscoveryMode:uint = TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
		
		//the possible touch target discovery modes.
		/**The events will be triggered on the top object under the tracked point. Fastest method. Works for DisplayObject and subclasses.*/
		public static const TOUCH_TARGET_DISCOVERY_NONE:Number = 0;
		/**The InteractiveObject's mouseEnabled parameter is used to determine whether a TuioTouchEvent is triggered on an InteractiveObject under the tracked point. Works only for InteractiveObject and subclasses.*/
		public static const TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED:Number = 1;
		/**An ignore list is used to determine whether a TuioTouchEvent is triggered on an InteractiveObject under the tracked point. Works for DisplayObject and subclasses.*/
		public static const TOUCH_TARGET_DISCOVERY_IGNORELIST:Number = 2;
		
		//if true MouseEvents are dispatched alongside the TuioTouchEvents
		private var _dispatchMouseEvents:Boolean = false;
		
		//if true native TouchEvents are dispatched alongside the org.tuio.TuioTouchEvents
		private var _dispatchNativeTouchEvents:Boolean = false;
		
		private var lastTarget:Dictionary;
		private var firstTarget:Dictionary;
		private var tapped:Array;
		private var hold:Dictionary;
		
		private var ignoreList:Array;
		
		private var stage:Stage;

		private var touchReceiversDict:Dictionary;
		
		private static var allowInst:Boolean;
		private static var inst:TuioManager;
		
		
		/////////////////////properties integrated from TuioFiducialDispatcher///////////////////////
		private var fiducialReceivers:Array;
		private var fiducialRemovalTimes:Array;
		
		private const ROTATION_MINIMUM:Number = 0.05;
		private const MOVEMENT_MINIMUM:Number = 3;
		private const ROTATION_SHIFT_DEFAULT:Number = 0;
		private const TIMEOUT_TIME_DEFAULT:Number = 1000;
		
		private var _timeoutTime:Number;
		private var _rotationShift:Number;
		private var _invertRotation:Boolean;
		
		private var lastFiducialTarget:Array;
		private var firstFiducialTarget:Array;
		////////////////////////////////////////////////////////
		
		/**
		 * Creates a new TuioManager instance which processes the Tuio tracking data received by the given TuioClient.
		 * The constructor is only meant to be used for internal calls. Use <code>getInstance</code> instead.
		 * 
		 * @param	stage The Stage object of the Flashmovie.
		 */
		public function TuioManager(stage:Stage) {
			if (!allowInst) {
				throw new Error("Error: Instantiation failed: Use TuioManager.getInstance() instead of new.");
			}else{
				this.stage = stage;
				this.lastTarget = new Dictionary();
				this.firstTarget = new Dictionary();
				this.tapped = new Array();
				this.hold = new Dictionary();
				this.ignoreList = new Array();
				this.touchReceiversDict = new Dictionary();
				
				/////////////////////constructor integrated from TuioFiducialDispatcher///////////////////////
				this._rotationShift = ROTATION_SHIFT_DEFAULT;
				this._timeoutTime = TIMEOUT_TIME_DEFAULT;
				
				fiducialReceivers = new Array();
				fiducialRemovalTimes = new Array();
				this.lastFiducialTarget = new Array();
				this.firstFiducialTarget = new Array();
				////////////////////////////////////////////////////////
			}
		}
		
		/**
		 * initializes Singleton instance.
		 * 
		 * @param	stage The Stage object of the Flashmovie.
		 * @param	tuioClient A TuioClient instance that receives Tuio tracking data from a tracker.
		 */
		public static function init(stage:Stage):TuioManager{
			if(inst == null){
				allowInst = true;
				inst = new TuioManager(stage);
				allowInst = false;
			}
			
			return inst;
		}
		
		/**
		 * gets Singleton instance
		 */
		public static function getInstance():TuioManager{
			if(inst == null){
				throw new Error("Please initialize with method TuioManager.init(...) first!");
			}
			return inst;
		}
		
		/** @private */
		public function handleAdd(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			firstTarget[tuioContainer] = target;
			lastTarget[tuioContainer] = target;
			hold[tuioContainer] = getTimer();
			
			//target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_OVER, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			//target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OVER, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_DOWN, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_DOWN, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			
			if (_dispatchMouseEvents) {
				//target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
				//target.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
				target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_DOWN, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
			}
			
			if (_dispatchNativeTouchEvents) {
				target.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_BEGIN, true, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, target as InteractiveObject));
			}
			
		}
		
		/** @private */
		public function handleUpdate(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var targetDict:Dictionary = createDict(stage.getObjectsUnderPoint(stagePos));
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			var last:DisplayObject = lastTarget[tuioContainer];
			
			//mouse move or hold
			if (Math.abs(tuioContainer.X) > 0.001 || Math.abs(tuioContainer.Y) > 0.001 || Math.abs(tuioContainer.Z) > 0.001) {
				hold[tuioContainer] = getTimer();
				target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				if (_dispatchMouseEvents) {
					target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_MOVE, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
				}
				if (_dispatchNativeTouchEvents) {
					target.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_MOVE, true, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, target as InteractiveObject));
				}
			} else if (hold[tuioContainer] < getTimer() - holdTimeout) {
				hold[tuioContainer] = getTimer();
				target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.HOLD, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
				this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.HOLD, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			}
			
			//mouse out/over
			if (target != last && last != null) {
				var lastLocal:Point = last.globalToLocal(new Point(stagePos.x, stagePos.y));
				var lastAncestors:Array = createAncestorList(last);
				var ancestors:Array = createAncestorList(target);
				var lastAncestorLocal:Point = new Point(lastLocal.x+last.x, lastLocal.y+last.y);
				var ancestorLocal:Point = new Point(local.x+target.x, local.y+target.y);
				var la:DisplayObject = lastAncestors.pop();
				while (la != null && la == ancestors.pop()) {
					la = lastAncestors.pop();
				}
				if (la != null) lastAncestors.push(la);
				
				if (_dispatchMouseEvents) {
					target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
					target.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
				}
				if (_dispatchNativeTouchEvents) {
					target.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_OVER, true, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, target as InteractiveObject));
					target.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_ROLL_OVER, false, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, target as InteractiveObject));
				}
				
				if (ancestors.indexOf(last) < 0) {
					if (_dispatchMouseEvents) {
						last.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, local.x, local.y, (last as InteractiveObject), false, false, false, false, 0));
						last.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, false, false, local.x, local.y, (last as InteractiveObject), false, false, false, false, 0));
					}
					if (_dispatchNativeTouchEvents) {
						last.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_OUT, true, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, last as InteractiveObject));
						last.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_ROLL_OUT, false, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, last as InteractiveObject));
					}
					last.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_OUT, true, false, lastLocal.x, lastLocal.y, stagePos.x, stagePos.y, last, tuioContainer));
					last.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OUT, false, false, local.x, local.y, stagePos.x, stagePos.y, last, tuioContainer));
					this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_OUT, true, false, lastLocal.x, lastLocal.y, stagePos.x, stagePos.y, last, tuioContainer));
					this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OUT, false, false, local.x, local.y, stagePos.x, stagePos.y, last, tuioContainer));
					
					for each(var a:InteractiveObject in lastAncestors) {
						if(a != target){
							a.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OUT, false, false, lastAncestorLocal.x, lastAncestorLocal.y, stagePos.x, stagePos.y, a, tuioContainer));
							this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OUT, false, false, lastAncestorLocal.x, lastAncestorLocal.y, stagePos.x, stagePos.y, a, tuioContainer));
							if (_dispatchMouseEvents) {
								a.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OUT, false, false, lastAncestorLocal.x, lastAncestorLocal.y, a, false, false, false, false, 0));
							}
							if (_dispatchNativeTouchEvents) {
								a.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_ROLL_OUT, false, false, tuioContainer.sessionID, false, lastAncestorLocal.x, lastAncestorLocal.y, 0, 0, 0, a));
							}
						}
						lastAncestorLocal.x += a.x;
						lastAncestorLocal.y += a.y;
					}
					
				} else {
					var ta:InteractiveObject = ancestors.pop();
					while (last != ta && ta != null) {
						ta = ancestors.pop();
					}
				}
				
				if (lastAncestors.indexOf(target) < 0) {
					target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_OVER, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
					target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OVER, false, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
					for each(var b:InteractiveObject in ancestors) {
						b.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OVER, false, false, ancestorLocal.x, ancestorLocal.y, stagePos.x, stagePos.y, b, tuioContainer));
						this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.ROLL_OVER, false, false, ancestorLocal.x, ancestorLocal.y, stagePos.x, stagePos.y, b, tuioContainer));
						if (_dispatchMouseEvents) {
							b.dispatchEvent(new MouseEvent(MouseEvent.ROLL_OVER, false, false, ancestorLocal.x, ancestorLocal.y, b, false, false, false, false, 0));
						}
						if (_dispatchNativeTouchEvents) {
							b.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_ROLL_OVER, false, false, tuioContainer.sessionID, false, ancestorLocal.x, ancestorLocal.y, 0, 0, 0, b));
						}
						ancestorLocal.x += b.x;
						ancestorLocal.y += b.y;
					}
				}
			}
			
			lastTarget[tuioContainer] = target;
			
			//handle updates on receivers: call updateTouch from each receiver that listens on sessionID
			
			//handle TUIO 1.0 touch receivers that do not make use of the source message
			updateTouchReceiver(""+tuioContainer.sessionID, local, stagePos, target, tuioContainer);
//			if(this.touchReceiversDict[tuioContainer.sessionID+tuioContainer.source]){
//				for each(var receiver:ITuioTouchReceiver in this.touchReceiversDict[tuioContainer.sessionID+tuioContainer.source]){
//					receiver.updateTouch(new TuioTouchEvent(TuioTouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
//				}
//			}
			
			//handle TUIO 1.1 touch receivers that make use of the source message
			updateTouchReceiver(tuioContainer.sessionID+tuioContainer.source, local, stagePos, target, tuioContainer);
//			if(this.touchReceiversDict[tuioContainer.sessionID+tuioContainer.source]){
//				for each(var receiver:ITuioTouchReceiver in this.touchReceiversDict[tuioContainer.sessionID+tuioContainer.source]){
//					receiver.updateTouch(new TuioTouchEvent(TuioTouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
//				}
//			}
		}
		
		private function updateTouchReceiver(keyString:String, local:Point, stagePos:Point, target:DisplayObject, tuioContainer:TuioContainer):void{
			if(this.touchReceiversDict[keyString]){
				var event:TuioTouchEvent = new TuioTouchEvent(TuioTouchEvent.TOUCH_MOVE, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer);
				for each(var receiver:ITuioTouchReceiver in this.touchReceiversDict[keyString]){
					receiver.updateTouch(event);
				}
			}
		}
		
		/**
		 * adds a touch callback class that is called when a TUIO 2dcur or 2dblb with a certain sessionId
		 * is added, updated or removed.
		 * 
		 * @param receiver callback class.
		 * @param sessionId of the cursor/blob to listen to.
		 * 
		 */
		public function registerTouchReceiver(receiver:ITuioTouchReceiver, sessionId:Number, src:String = null):void{
			var keyString:String;
			if(src != null){
				keyString = sessionId+src;
			}else{
				keyString = ""+sessionId;
			}
			if(!this.touchReceiversDict[keyString]){
				this.touchReceiversDict[keyString] = new Array();
			}
			this.touchReceiversDict[keyString].push(receiver);	
		}
		
		/**
		 * removes a touch callback.
		 * 
		 * @param receiver callback class.
		 * @param sessionId of the cursor/blob to listen to.
		 * 
		 */
		public function removeTouchReceiver(receiver:ITuioTouchReceiver, sessionId:Number, src:String = null):void{
			var keyString:String;
			if(src != null){
				keyString = sessionId+src;
			}else{
				keyString = ""+sessionId;
			}
			delete this.touchReceiversDict[keyString];
		}
		
		private function subtractDicts(dict1:Dictionary, dict2:Dictionary):Array{
			var diffArray:Array = new Array();
			
			for (var key:Object in dict1){
				var isIn:Object = dict2[key];
				if(isIn == null){
					diffArray.push(key);
				}
			}
			
			return diffArray;
		}
		
		private function createDict(objectsUnderPoint:Array):Dictionary{
			var objectsDict:Dictionary = new Dictionary();
			for each(var displayObject:DisplayObject in objectsUnderPoint){
				objectsDict[displayObject] = "";
			}
			return objectsDict;
		}
		
		/** @private */
		public function handleRemove(tuioContainer:TuioContainer):void {
			var stagePos:Point = new Point(stage.stageWidth * tuioContainer.x, stage.stageHeight * tuioContainer.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TOUCH_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
			if (_dispatchMouseEvents) {
				target.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_UP, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
			}
			if (_dispatchNativeTouchEvents) {
				target.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_END, true, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, target as InteractiveObject));
			}
			
			
			//handle receivers
			if(this.touchReceiversDict[tuioContainer.sessionID+tuioContainer.source]){
				//call removeTouch from each receiver that listens on sessionID
				var event:TuioTouchEvent = new TuioTouchEvent(TuioTouchEvent.TOUCH_UP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer);
				for each(var receiver:ITuioTouchReceiver in this.touchReceiversDict[tuioContainer.sessionID+tuioContainer.source]){
					receiver.removeTouch(event);
				}
				
				//delete receivers from dictionary
				delete this.touchReceiversDict[tuioContainer];
			}
			
			//tap
			if (target == firstTarget[tuioContainer]) {
				var double:Boolean = false;
				var tmpArray:Array = new Array();
				var item:DoubleTapStore;
				while (tapped.length > 0) {
					item = tapped.pop() as DoubleTapStore;
					if (item.check(this.doubleTapTimeout)) {
						if (item.target == target && Math.abs(stagePos.x-item.x) < this.doubleTapDistance && Math.abs(stagePos.y - item.y) < this.doubleTapDistance ) double = true;
						else tmpArray.push(item);
					}
				}
				tapped = tmpArray.concat();
				
				if (double) {
					target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.DOUBLE_TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
					this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.DOUBLE_TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
					if (_dispatchMouseEvents) {
						target.dispatchEvent(new MouseEvent(MouseEvent.DOUBLE_CLICK, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
					}
				} else {
					tapped.push(new DoubleTapStore(target, getTimer(), stagePos.x, stagePos.y));
					target.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
					this.dispatchEvent(new TuioTouchEvent(TuioTouchEvent.TAP, true, false, local.x, local.y, stagePos.x, stagePos.y, target, tuioContainer));
					if (_dispatchMouseEvents) {
						target.dispatchEvent(new MouseEvent(MouseEvent.CLICK, true, false, local.x, local.y, (target as InteractiveObject), false, false, false, false, 0));
					}
					if (_dispatchNativeTouchEvents) {
						target.dispatchEvent(new flash.events.TouchEvent(flash.events.TouchEvent.TOUCH_TAP, true, false, tuioContainer.sessionID, false, local.x, local.y, 0, 0, 0, target as InteractiveObject));
					}
				}
			}
			
			lastTarget[tuioContainer] = null;
			firstTarget[tuioContainer] = null;
			hold[tuioContainer] = null;
		}
		
		private function getTopDisplayObjectUnderPoint(point:Point):DisplayObject {
			var targets:Array =  stage.getObjectsUnderPoint(point);
			var item:DisplayObject = (targets.length > 0) ? targets[targets.length - 1] : stage;
			
			if(this.touchTargetDiscoveryMode == TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED){
				while(targets.length > 0) {
					item = targets.pop() as DisplayObject;
					//ignore debug cursor/object/blob and send object under debug cursor/object/blob
					if((item is ITuioDebugCursor || item is ITuioDebugBlob || item is ITuioDebugObject || item is ITuioDebugTextSprite) && targets.length > 0){
						continue;
					}
					if (item.parent != null && !(item is InteractiveObject)) item = item.parent;
					if (item is InteractiveObject) {
						if ((item as InteractiveObject).mouseEnabled) return item;
					}
				}
				item = stage;
			} else if (this.touchTargetDiscoveryMode == TOUCH_TARGET_DISCOVERY_IGNORELIST) {
				while(targets.length > 0) {
					item = targets.pop();
					//ignore debug cursor/object/blob and send object under debug cursor/object/blob
					if((item is ITuioDebugCursor || item is ITuioDebugBlob || item is ITuioDebugObject || item is ITuioDebugTextSprite) && targets.length > 0){
						continue;
					}
					if (!bubbleListCheck(item)) return item;
				}
				item = stage;
			}
			
			return item;
		}
		
		/**
		 * Checks if a DisplayObject or its parents are in the ignoreList.
		 * 
		 * @param	obj The DisplayObject that has to be checked.
		 * @return Is true if the DisplayObject or one of its parents is in the ignoreList.
		 */
		private function bubbleListCheck(obj:DisplayObject):Boolean {
			if (ignoreList.indexOf(obj) < 0){
				if (obj.parent != null) {
					return bubbleListCheck(obj.parent);
				} else {
					return false;
				}
			} else {
				return true;
			}
		}
		
		/**
		 * Creates a list of all ancestors for the given <code>DisplayObject</code> from 
		 * the <code>DisplayObject</code>'s parent to the stage.
		 * 
		 * @param	item The <code>DisplayObject</code> of which the list will be created.
		 * @return The ancestor list of the given <code>DisplayObject</code>
		 */
		private function createAncestorList(item:DisplayObject):Array {
			var list:Array = new Array();
			var stage:Stage = item.stage;
			while (item != stage) {
				list.push(item.parent);
				item = item.parent;
			}
			return list;
		}
		
		/**
		 * Adds the given DisplayObject to an internal list of DisplayObjects that won't receive TouchEvents.
		 * If a DisplayobjectContainer is added to the list its children can still receive TouchEvents.
		 * The touchTargetDiscoveryMode is automatically set to TOUCH_TARGET_DISCOVERY_IGNORELIST.
		 * 
		 * @param	item The DisplayObject that should be ignored by TouchEvents.
		 */
		public function addToIgnoreList(item:DisplayObject):void {
			this.touchTargetDiscoveryMode = TOUCH_TARGET_DISCOVERY_IGNORELIST;
			if(ignoreList.indexOf(item) < 0) ignoreList.push(item);
		}
		
		/**
		 * Removes the given DisplayObject from the internal list of DisplayObjects that won't receive TouchEvents.
		 * 
		 * @param	item The DisplayObject that should be ignored by TouchEvents.
		 */
		public function removeFromIgnoreList(item:DisplayObject):void {
			var tmpList:Array = new Array();
			var listItem:Object;
			while (ignoreList.length > 0) {
				listItem = ignoreList.pop();
				if (listItem != item) tmpList.push(listItem);
			}
			ignoreList = tmpList.concat();
		}
		
		/**
		 * If set <code>true</code> MouseEvents are dispatched alongside the TouchEvents also the touchTargetDicoveryMode
		 * is automatically set to TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED.
		 * @default false.
		 */
		public function set dispatchMouseEvents(value:Boolean):void {
			if (value) this.touchTargetDiscoveryMode = TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
			this._dispatchMouseEvents = value;
		}
		
		public function get dispatchMouseEvents():Boolean {
			return this._dispatchMouseEvents;
		}
		
		/**
		 * If set <code>true</code> native TouchEvents (since Flash 10.1 and Air2.0) are dispatched alongside the TuioTouchEvents also the touchTargetDicoveryMode
		 * is automatically set to TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED.
		 * @default false.
		 */
		public function set dispatchNativeTouchEvents(value:Boolean):void {
			if (value) this.touchTargetDiscoveryMode = TOUCH_TARGET_DISCOVERY_MOUSE_ENABLED;
			this._dispatchNativeTouchEvents = value;
		}
		
		public function get dispatchNativeTouchEvents():Boolean {
			return this._dispatchNativeTouchEvents;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioObject));
			if(triggerTouchOnObject) this.handleAdd(tuioObject);
			
			/////////////////////added from TuioFiducialDispatcher///////////////////////
			for each(var receiverObject:Object in fiducialReceivers){
				if(receiverObject.source != null){
					//TUIO 1.1
					if(receiverObject.classID == tuioObject.classID && receiverObject.source == tuioObject.source){
						notifyReceiverAdded(receiverObject, tuioObject);
					}
				}else{
					//TUIO 1.0
					if(receiverObject.classID == tuioObject.classID){
						notifyReceiverAdded(receiverObject, tuioObject);
					}
				}
			}
			
			var stagePos:Point = new Point(stage.stageWidth * tuioObject.x, stage.stageHeight * tuioObject.y);
			var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			firstFiducialTarget[tuioObject.sessionID] = target;
			lastFiducialTarget[tuioObject.sessionID] = target;
			
			//dispatch ADD event on DisplayObject under fiducial
			target.dispatchEvent(createFiducialEvent(
				TuioFiducialEvent.ADD, 
				tuioObject));
			
			//dispatch OVER event on DisplayObject under fiducial
			target.dispatchEvent(createFiducialEvent(
				TuioFiducialEvent.OVER, 
				tuioObject));
			////////////////////////////////////////////
		}
		
		/**
		 * @inheritDoc
		 */
		public function updateTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioObject));
			if(triggerTouchOnObject) this.handleUpdate(tuioObject);
			
			/////////////////////added from fiducial dispatcher///////////////////////
			var stagePos:Point = new Point(stage.stageWidth * tuioObject.x, stage.stageHeight * tuioObject.y);
			var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			for each(var receiverObject:Object in fiducialReceivers){
				if(receiverObject.source != null){
					//TUIO 1.1
					if(receiverObject.classID == tuioObject.classID && receiverObject.source == tuioObject.source){
						//compare rotation, movement and so on and call according callback methods
						callUpdateMethods(receiverObject, receiverObject.tuioObject, tuioObject);
					}
				}else{
					//TUIO 1.0
					if(receiverObject.classID == tuioObject.classID){
						//compare rotation, movement and so on and call according callback methods
						callUpdateMethods(receiverObject, receiverObject.tuioObject, tuioObject);
					}
				}
			}
			dispatchUpdateEvents(tuioObject);
			
			if(target != lastFiducialTarget[tuioObject.sessionID]){
				target.dispatchEvent(createFiducialEvent(
					TuioFiducialEvent.OVER, 
					tuioObject));
				
				lastFiducialTarget[tuioObject.sessionID].dispatchEvent(createFiducialEvent(
					TuioFiducialEvent.OUT, 
					tuioObject));
			}
			lastFiducialTarget[tuioObject.sessionID] = target;
			////////////////////////////////////////////
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeTuioObject(tuioObject:TuioObject):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_OBJECT, tuioObject));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioObject));
			if(triggerTouchOnObject) this.handleRemove(tuioObject);
			
			/////////////////////added from fiducial dispatcher///////////////////////
			var stagePos:Point = new Point(stage.stageWidth * tuioObject.x, stage.stageHeight * tuioObject.y);
			var target:DisplayObject = DisplayListHelper.getTopDisplayObjectUnderPoint(stagePos, stage);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			for each(var receiverObject:Object in fiducialReceivers){
				if(receiverObject.source != null){
					if(receiverObject.classID == tuioObject.classID && receiverObject.source == tuioObject.source){
						notifyReceiverRemoved(receiverObject, tuioObject);
					}
				}else{
					if(receiverObject.classID == tuioObject.classID){
						notifyReceiverRemoved(receiverObject, tuioObject);
					}
				}
			}
			
			//dispatch REMOVED event on DisplayObject under fiducial
			target.dispatchEvent(createFiducialEvent(
				TuioFiducialEvent.REMOVED, 
				tuioObject));
			if(target != lastFiducialTarget[tuioObject.sessionID]){
				target.dispatchEvent(createFiducialEvent(
					TuioFiducialEvent.OUT, 
					tuioObject));
			}
			lastFiducialTarget[tuioObject.sessionID].dispatchEvent(createFiducialEvent(
				TuioFiducialEvent.OUT, 
				tuioObject));
			////////////////////////////////////////////
		}
		
		/**
		 * @inheritDoc
		 */
		public function addTuioCursor(tuioCursor:TuioCursor):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_CURSOR, tuioCursor));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioCursor));
			this.handleAdd(tuioCursor);
		}
		
		/**
		 * @inheritDoc
		 */
		public function updateTuioCursor(tuioCursor:TuioCursor):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_CURSOR, tuioCursor));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioCursor));
			this.handleUpdate(tuioCursor);
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeTuioCursor(tuioCursor:TuioCursor):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_CURSOR, tuioCursor));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioCursor));
			this.handleRemove(tuioCursor);
		}
		
		/**
		 * @inheritDoc
		 */
		public function addTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.ADD, tuioBlob));
			if(triggerTouchOnBlob) this.handleAdd(tuioBlob);
		}

		/**
		 * @inheritDoc
		 */
		public function updateTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.UPDATE, tuioBlob));
			if(triggerTouchOnBlob) this.handleUpdate(tuioBlob);
		}

		/**
		 * @inheritDoc
		 */
		public function removeTuioBlob(tuioBlob:TuioBlob):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE_BLOB, tuioBlob));
			this.dispatchEvent(new TuioEvent(TuioEvent.REMOVE, tuioBlob));
			if(triggerTouchOnBlob) this.handleRemove(tuioBlob);
		}
		
		/**
		 * @inheritDoc
		 */
		public function newFrame(id:uint):void {
			this.dispatchEvent(new TuioEvent(TuioEvent.NEW_FRAME, null));
		}
		
		/////////////////////fiducial functions///////////////////////
		private function dispatchUpdateEvents(newTuioObject:TuioObject):void{
			//dispatch MOVE event on DisplayObject under fiducial
			var stagePos:Point = new Point(stage.stageWidth * newTuioObject.x, stage.stageHeight * newTuioObject.y);
			getTopDisplayObjectUnderPoint(stagePos).dispatchEvent(createFiducialEvent(
				TuioFiducialEvent.MOVE, 
				newTuioObject));
			//dispatch ROTATE event on DisplayObject under fiducial
			getTopDisplayObjectUnderPoint(stagePos).dispatchEvent(createFiducialEvent(
				TuioFiducialEvent.ROTATE, 
				newTuioObject));
		}
		
		private function notifyReceiverAdded(receiverObject:Object, tuioObject:TuioObject):void{
			if(receiverObject.tuioObject != null){
				//object is still existing because it had been lost while tracking
				//update object and stop timer
				(receiverObject.receiver as ITuioFiducialReceiver).onNotifyReturned(createFiducialEvent(
					TuioFiducialEvent.NOTIFY_RETURNED, 
					tuioObject)
				);
				//stop return timeout for this fiducial
				for(var i:Number = 0; i <  fiducialRemovalTimes.length; i++){
					var removalTimeObject:Object = fiducialRemovalTimes[i]; 
					if(removalTimeObject.receiverObject.classId == receiverObject.classId){
						clearTimeout(removalTimeObject.timeoutId);
						fiducialRemovalTimes.splice(i,1);
					}
				}
				callUpdateMethods(receiverObject, receiverObject.tuioObject, tuioObject);
			}else{
				//object does not exist yet. call add, move and rotation method callbacks.
				receiverObject.tuioObject = tuioObject.clone();
				(receiverObject.receiver as ITuioFiducialReceiver).onAdd(createFiducialEvent(
					TuioFiducialEvent.ADD, 
					tuioObject)
				);
				receiverObject.receiver.onMove(createFiducialEvent(TuioFiducialEvent.MOVE, tuioObject));
				receiverObject.receiver.onRotate(createFiducialEvent(TuioFiducialEvent.ROTATE,tuioObject));
			}
		}
		
		private function notifyReceiverRemoved(receiverObject:Object, tuioObject:TuioObject):void{
			(receiverObject.receiver as ITuioFiducialReceiver).onNotifyRemoved(
				createFiducialEvent(TuioFiducialEvent.NOTIFY_REMOVED, tuioObject), 
				_timeoutTime);
			var timeoutId:Number = setTimeout(checkTimeouts, _timeoutTime);
			var removalObject:Object = new Object();
			removalObject.timeout = getTimer()+_timeoutTime;
			removalObject.receiverObject = receiverObject;
			removalObject.timeoutId = timeoutId;
			fiducialRemovalTimes.push(removalObject);
		}
		
		private function callUpdateMethods(receiverObject:Object, oldTuioObject:TuioObject, newTuioObject:TuioObject):void{
			if(oldTuioObject){
				//check for movement and rotation
				var distX:Number = oldTuioObject.x*stage.stageWidth-newTuioObject.x*stage.stageWidth;
				var distY:Number = oldTuioObject.y*stage.stageHeight-newTuioObject.y*stage.stageHeight;
				var dist:Number = Math.sqrt(distX*distX+distY*distY);
				var angleDist:Number = Math.abs(oldTuioObject.a - newTuioObject.a);
				
				//to prevent flickering of fiducial graphics updates are 
				//only triggered if movement or rotation exceed threshold
				if(dist > MOVEMENT_MINIMUM || angleDist > ROTATION_MINIMUM){
					if(dist > 0){
						receiverObject.receiver.onMove(createFiducialEvent(TuioFiducialEvent.MOVE, newTuioObject));
					}
					if(angleDist > 0){
						receiverObject.receiver.onRotate(createFiducialEvent(TuioFiducialEvent.ROTATE, newTuioObject));
					}
					receiverObject.tuioObject = newTuioObject.clone();
				}
			}else{
				//call move callback function
				receiverObject.receiver.onMove(createFiducialEvent(TuioFiducialEvent.MOVE, newTuioObject));
				//call rotate callback function
				receiverObject.receiver.onRotate(createFiducialEvent(TuioFiducialEvent.ROTATE, newTuioObject));
				//update tuioObject to be able to check for movement and rotation
				receiverObject.tuioObject = newTuioObject.clone();
			}
			
		}
		
		private function checkTimeouts():void{
			var firstTimeout:Number = fiducialRemovalTimes[0].timeout;
			
			if(firstTimeout <= getTimer()){
				var removalTimeObject:Object = fiducialRemovalTimes.shift(); 
				(removalTimeObject.receiverObject.receiver as ITuioFiducialReceiver).onRemove(null);
				for(var i:Number = 0; i < fiducialReceivers.length; i++){
					if(removalTimeObject.receiverObject.classID == fiducialReceivers[i].classID){
						fiducialReceivers[i].tuioObject = null;
					}
				}
			}
			if(fiducialRemovalTimes.length == 0){
				removeEventListener(Event.ENTER_FRAME, checkTimeouts);
			}
		}
		
		/**
		 * adds a callback object to TuioFiducialDispatcher.
		 * 
		 * @param receiver object that should be notified if a fiducial with the id fiducialId is changed.
		 * @param fiducialId fiducial id on which TuioFiducialDispatcher should listen
		 * 
		 */
		public function registerFiducialReceiver(receiver:ITuioFiducialReceiver, fiducialId:Number, src:String = null):void{
			var receiverObject:Object = new Object();
			receiverObject.receiver = receiver;
			receiverObject.classID = fiducialId;
			receiverObject.source = src;
			fiducialReceivers.push(receiverObject);
		}
		
		/**
		 * removes a callback object from TuioFiducialDispatcher.
		 * 
		 * @param receiver object that should be notified if a fiducial with the id fiducialId is changed.
		 * @param fiducialId fiducial id on which TuioFiducialDispatcher should listen.
		 * 
		 */
		public function removeFiducialReceiver(receiver:ITuioFiducialReceiver, fiducialId:Number, src:String = null):void{
			var i:Number = 0;
			for each(var receiverObject:Object in fiducialReceivers){
				if(receiverObject.receiver == receiver && receiverObject.classID == fiducialId && receiverObject.source == src){
					fiducialReceivers.splice(i,1);
					break;
				}
				i = i+1;
			}
			
		}
		private function createFiducialEvent(type:String, tuioObject:TuioObject):TuioFiducialEvent{
			var stagePos:Point = new Point(stage.stageWidth * tuioObject.x, stage.stageHeight * tuioObject.y);
			var target:DisplayObject = getTopDisplayObjectUnderPoint(stagePos);
			var local:Point = target.globalToLocal(new Point(stagePos.x, stagePos.y));
			
			var fiducialEvent:TuioFiducialEvent = new TuioFiducialEvent(type, 
				local.x,
				local.y,
				stagePos.x,
				stagePos.y,
				target,
				tuioObject);
			
			//calculate rotation
			if(!_invertRotation){
				fiducialEvent.rotation = tuioObject.a * 180 / Math.PI+_rotationShift;
			}else{
				var invertedValue:Number = 2*Math.PI - tuioObject.a; 
				fiducialEvent.rotation = invertedValue * 180 / Math.PI+_rotationShift;
			}
			
			return fiducialEvent;
		}
		
		/**
		 * time, which TuioManager should wait until it calls the onRemove callback function
		 * of a receiver object after a tuio object has been removed from stage.
		 * 
		 * @return timeout time
		 * 
		 * @see ITuioFiducialReceiver
		 * 
		 */
		public function get timeoutTime():Number{
			return _timeoutTime;
		}
		public function set timeoutTime(timeoutTime:Number):void{
			_timeoutTime = timeoutTime;
		}
		
		
		/**
		 * Fixed degree value, which is added to the rotation value. Trackers behave differently in how they calculate
		 * the rotation of a fiducial on their surface. Thus, rotationShift can be set according to a 
		 * tracker's properties. The simulator does not need any shift.
		 * 
		 * @return rotationShift as degree value.
		 * 
		 */
		public function get rotationShift():Number{
			return _timeoutTime;
		}
		public function set rotationShift(rotationShift:Number):void{
			_rotationShift = rotationShift;
		}
		
		/**
		 * Some trackers invert the rotation of a fiducial. Thus, by setting invertRotation true
		 * the rotation of a fiducial will be inverted.
		 *  
		 * @return invertRotation
		 * 
		 */
		public function get invertRotation():Boolean{
			return _invertRotation;
		}
		public function set invertRotation(invertRotation:Boolean):void{
			_invertRotation = invertRotation;
		}
		
		
		////////////////////////////////////////////////////////
		
	}
	
}

import flash.display.DisplayObject;
import flash.utils.getTimer;

internal class DoubleTapStore {
	
	internal var target:DisplayObject;
	internal var time:int;
	internal var x:Number;
	internal var y:Number;
	
	function DoubleTapStore(target:DisplayObject, time:int, x:Number, y:Number) {
		this.target = target;
		this.time = time;
		this.x = x;
		this.y = y;
	}
	
	internal function check(timeout:int):Boolean {
		if (time > getTimer() - timeout) return true;
		else return false;
	}
	
}