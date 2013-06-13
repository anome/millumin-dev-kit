package org.tuio.adapters
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.InteractiveObject;
	import flash.display.NativeMenuItem;
	import flash.display.SpreadMethod;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.utils.Dictionary;
	
	import org.tuio.*;
	import org.tuio.debug.*;
	import org.tuio.util.DisplayListHelper;
	
	/**
	 * Listens on MouseEvents, "translates" them to the analog TuioTouchEvents and TuioFiducialEvents and dispatches
	 * them on <code>DisplayObject</code>s under the mouse pointer.
	 * 
	 * Additionally, it provides means to simulate multi-touch input with a single mouse.
	 * By pressing the 'Shift' key a touch can be added permanently. Pressing the 'Ctrl' key
	 * in Windows or the 'Command' key in Mac OS X while clicking a touch, will add the touch to a group. 
	 * Furthermore, object interaction can be simulated by choosing a fiducial id from the context menu and
	 * manipulating the debug representation of the fiducial subsequently. It can be dragged around
	 * or if 'r' is pressed it can be rotated. If 'Shift' is pressed a fiducial will be removed.
	 * 
	 * A group of touches will be moved around together. To rotate a group of touches, hold
	 * the 'r' key, while dragging. To move the touches apart from or towards each other (e.g., to perform pinch/scale
	 * gestures) hold the 's' key while dragging. To make a group disappear after dragging hold the 'Space'
	 * key while dragging. The latter is handy if you want to test physical properties like inertia of a group of objects.  
	 * 
	 * 
	 * @author Johannes Luderschmidt
	 * 
	 * @see org.tuio.TuioTouchEvent
	 * @see org.tuio.TuioFiducialEvent
	 * 
	 */
	public class MouseTuioAdapter extends AbstractTuioAdapter{
		private var stage:Stage;
		private var tuioSessionId:uint;
		private var touchMoveId:Number;
		private var touchMoveSrc:String;
		private var movedObject:ITuioDebugObject;
		private var shiftKey:Boolean;
		private var groups:Dictionary;
		
		private var frameId:uint = 0;
		private var lastSentFrameId:Number = 0;
		private var lastX:Number;
		private var lastY:Number;
		
		private var spaceKey:Boolean;
		private var rKey:Boolean;
		private var sKey:Boolean;
		private var centerOfGroupedTouchesX:Number;
		private var centerOfGroupedTouchesY:Number;
		private var fiducialX:Number;
		private var fiducialY:Number;
		
		private var fiducialContextMenu:ContextMenu;
		
		private const TWO_D_CUR:String = "2Dcur";
		private const TWO_D_OBJ:String = "2Dobj";
		
		private var src:String = "_mouse_tuio_adapter_";
		
		/**
		 * initializes MouseToTouchDispatcher by adding appropriate event listeners to it. Basically, MouseToTouchDispatcher
		 * listens on mouse events and translates them to touches. However, additionally keyboard listeners are being added
		 * that listen on keyboard events to control certain actions like rotation of a touches group by holding 'r'.
		 * 
		 * @param stage 
		 * @param useTuioManager call the add, move and remove functions of the TuioManager instead of simply dispatching TuioTouchEvents. You have to initialize TuioManager before.
		 * @param useTuioDebug show the touches as debug cursors. You have to initialize TuioDebug before.
		 * 
		 */
		public function MouseTuioAdapter(stage:Stage){
			super(this);
			this.stage = stage; 
			enableAdapter();
			
			if (!this._tuioBlobs[this.src]){ this._tuioBlobs[this.src] = [];}
			if (!this._tuioCursors[this.src]){ this._tuioCursors[this.src] = [];}
			if (!this._tuioObjects[this.src]){ this._tuioObjects[this.src] = [];}

			tuioSessionId = 0;
			
			lastX = stage.mouseX;
			lastY = stage.mouseY;
			
			groups = new Dictionary();
			
			spaceKey = false;
			rKey = false;
			centerOfGroupedTouchesX = 0;
			centerOfGroupedTouchesY = 0;
			
			//Flash does not have MouseEvent.RIGHT_CLICK
			if(MouseEvent.RIGHT_CLICK){
				createContextMenu();
			}else{
				addFlashContextMenu();
			}
		}
		
		public function enableAdapter():void{
			stage.addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			//Flash does not have MouseEvent.RIGHT_CLICK
			if(MouseEvent.RIGHT_CLICK){
				stage.addEventListener(MouseEvent.RIGHT_CLICK, contextMenuClick);
			}else{
				addFlashContextMenu();
			}
			
			stage.addEventListener(Event.EXIT_FRAME, sendFrameEvent);
		}
		
		public function disableAdapter():void{
			stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyUp);
			
			//Flash does not have MouseEvent.RIGHT_CLICK
			if(MouseEvent.RIGHT_CLICK){
				stage.removeEventListener(MouseEvent.RIGHT_CLICK, contextMenuClick);
			}else{
				removeFlashContextMenu();
			}
			
			stage.removeEventListener(Event.EXIT_FRAME, sendFrameEvent);
		}
		
		/**
		 * Causes a Tuio update event to be sent. Is, e.g., used in gesture API.
		 */
		private function sendFrameEvent(event:Event):void{
			if(this.frameId != this.lastSentFrameId){
				for each(var l:ITuioListener in this.listeners) {
					l.newFrame(this.frameId);
				}
				this.lastSentFrameId = this.frameId;
			}
		}
		
		/**
		 * If there is no existing touch 
		 * under the mouse pointer, a new touch will be added. However, if there already is one it will be marked
		 * for movement and no new touch is being added. Alternatively, if there is a fiducial underneath the mouse 
		 * pointer it will be selected for movement. If the 'Shift' key is pressed and there is an 
		 * existing touch beneath the mouse cursor this touch will be removed. Alternatively, If the 'Shift' key is pressed
		 * and there is a fiducial underneath the mouse pointer, the fiducial will be removed. 
		 * 
		 * If the 'Ctrl/Command' key is pressed 
		 * the touch will be added to a group (marked by a dot in the center of a touch) if it does not belong to a 
		 * group already. If it does it will be removed from the group.
		 * 
		 * NOTE: Adding touches permanently does only work if TuioDebug is being used and useTuioDebug is switched on.
		 *  
		 * @param event
		 * 
		 */
		private function handleMouseDown(event:MouseEvent):void{
			var cursorUnderPoint:ITuioDebugCursor = getCursorUnderPointer(event.stageX, event.stageY); 
			var objectUnderPoint:ITuioDebugObject = getObjectUnderPointer(event.stageX, event.stageY);
			
			if(cursorUnderPoint != null){
				startMoveCursor(cursorUnderPoint, event);
			}else if(objectUnderPoint != null){
				startMoveObject(objectUnderPoint, event);
			}else{
				//add new mouse pointer
				var frameId:uint = this.frameId++;	
				var tuioCursor:TuioCursor= createTuioCursor(event.stageX, event.stageY, 0, 0, this.tuioSessionId, frameId);
				_tuioCursors[this.src].push(tuioCursor);
				dispatchAddCursor(tuioCursor);
				
				this.touchMoveId = this.tuioSessionId;
				this.touchMoveSrc = this.src;
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
				
				//takes care that the cursor will not be removed on mouse up
				this.shiftKey = event.shiftKey;
			}
		}
		
		//==========================================  CONTEXT MENU STUFF ==========================================  
		/**
		 * 
		 * creates a context menu with 100 context menu items that allows to choose
		 * to add a debug fiducial with the fiducialId of the chosen menu item. 
		 */
		private function createContextMenu():void{
			fiducialContextMenu = new ContextMenu();
			
			for(var i:Number = 0; i < 100; i++){
				var item:NativeMenuItem = new NativeMenuItem("Add Fiducial "+i);
				fiducialContextMenu.addItem(item);
				item.addEventListener(Event.SELECT, contextMenuSelected); 
			}
		}
		
		/**
		 * shows the context menu
		 *  
		 * @param event mouse event.
		 * 
		 */
		private function contextMenuClick(event:MouseEvent):void{
			this.fiducialX = event.stageX;
			this.fiducialY = event.stageY;
			fiducialContextMenu.display(stage, this.fiducialX, this.fiducialY);
		}
		
		/**
		 * adds a debug fiducial with the fiducialId of the chosen menu item to the stage.
		 *  
		 * @param event
		 * 
		 */
		private function contextMenuSelected(event:Event):void{
			var itemLabel:String = (event.target as NativeMenuItem).label;
			var fiducialId:Number = int(itemLabel.substring(itemLabel.lastIndexOf(" ")+1, itemLabel.length));
			dispatchAddFiducial(this.fiducialX, this.fiducialY, fiducialId);
			this.tuioSessionId = this.tuioSessionId+1;
		}
		
		/**
		 * 
		 * @param stageX x position of mouse 
		 * @param stageY y position of mouse
		 * @param fiducialId chosen fiducialId
		 * 
		 */
		private function dispatchAddFiducial(stageX:Number, stageY:Number, fiducialId:uint):void{
			var frameId:uint = this.frameId++;	
			var tuioObject:TuioObject = createTuioObject(fiducialId, stageX,stageY, this.tuioSessionId, 0, frameId);
			_tuioObjects[this.src].push(tuioObject);
			dispatchAddObject(tuioObject);
		}
		
		//==========================================  TOUCH STUFF ==========================================
		
		/**
		 * decides whether a TUIO debug cursor should be removed, added to a cursor group or it should be moved around.
		 * 
		 * @param cursorUnderPoint TUIO debug cursor under the mouse pointer.
		 * @param event
		 * 
		 */
		private function startMoveCursor(cursorUnderPoint:ITuioDebugCursor, event:MouseEvent):void{
			//update or remove cursor under mouse pointer
			if(event.shiftKey){
				//remove cursor
				if(cursorUnderPoint.source == this.src){
					removeCursor(event, cursorUnderPoint.sessionId, cursorUnderPoint.source);
					deleteFromGroup(cursorUnderPoint);
				}else{
					trace("You can only remove touches that you created via mouse clicks.");
				}
			}else if(event.ctrlKey){
				var cursorObject:Object = this.groups[cursorUnderPoint.sessionId];
				
				//add cursor to group
				if(cursorObject == null){
					//add to group
					if(cursorUnderPoint.source == this.src){
						addToGroup(cursorUnderPoint);
					}else{
						trace("You can only add those touches to groups that have been created via mouse clicks.");
					}
				}else{
					//remove from group
					(cursorObject.cursor as DisplayObjectContainer).removeChild(cursorObject.markerSprite);
					deleteFromGroup(cursorUnderPoint);
				}
			}else{
				//take care that cursor is not removed after mouse up
				if(this.groups[this.touchMoveId] == null){
					this.shiftKey = true;
				}
				//move cursor
				this.touchMoveId = cursorUnderPoint.sessionId;
				this.touchMoveSrc = cursorUnderPoint.source;
				
				//take care that cursor is moved around the middle
				this.lastX = stage.mouseX;
				this.lastY = stage.mouseY;
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
			}
		}
		
		/**
		 *adds a cursor to a group.
		 *  
		 * @param cursorUnderPoint the cursor that should be added to the group.  
		 * 
		 */
		private function addToGroup(cursorUnderPoint:ITuioDebugCursor):void{
			var cursorObject:Object = this.groups[cursorUnderPoint.sessionId];
			
			cursorObject = new Object();
			cursorObject.cursor = cursorUnderPoint;
			
			var markerSprite:Sprite = new Sprite();
			markerSprite.graphics.beginFill(0xff0000);
			markerSprite.graphics.drawCircle(0,0,3);
			markerSprite.graphics.endFill();
			(cursorUnderPoint as DisplayObjectContainer).addChild(markerSprite);
			
			cursorObject.markerSprite = markerSprite;
			
			this.groups[cursorUnderPoint.sessionId] = cursorObject;
		}
		
		/**
		 * deletes a cursor from the group dictionary.
		 *  
		 * @param cursorUnderPoint the cursor that should be removed from the group.
		 * 
		 */
		private function deleteFromGroup(cursorUnderPoint:ITuioDebugCursor):void{
			delete this.groups[cursorUnderPoint.sessionId];
		}
		
		/**
		 * moves a touch or a group of touches (depending if dragged touch is member of a group). 
		 * 
		 * If the 'r' key is pressed and a touch that is member of a group is 
		 * moved around, the group will be rotated around its berycenter. To rotate the touches, 
		 * drag the mouse up and down while 'r' is pressed.
		 * 
		 * If the 's' key is pressed and a touch that is member of a group is 
		 * moved around, the group will be rotated around its berycenter. To scale the touches, 
		 * drag the mouse left and right while 's' is pressed.
		 * 
		 * 'r' and 's' can be used in combination. 
		 *  
		 * @param event
		 * 
		 */
		private function dispatchTouchMove(event:MouseEvent):void{
			var xDiff:Number =  stage.mouseX-this.lastX;
			var yDiff:Number = stage.mouseY-this.lastY;
			
			if(this.groups[this.touchMoveId] != null){
				
				this.lastX = stage.mouseX;
				this.lastY = stage.mouseY;
				var cursorObject:Object;
				var cursor:DisplayObjectContainer
				
				var xPos:Number;
				var yPos:Number;
				var cursorMatrix:Matrix;
				
				//simply move grouped touches if neither 'r' nor 's' key is pressed
				if(!this.rKey && !this.sKey){
					for each(cursorObject in this.groups){
						cursor = cursorObject.cursor as DisplayObjectContainer;
						xPos = cursor.x + xDiff;
						yPos = cursor.y + yDiff;
						moveCursor(xPos, yPos, xDiff, yDiff, cursorObject.cursor.sessionId,cursorObject.cursor.source);
					}
				}else{
					//rotate grouped touches if 'r' key is pressed
					for each(cursorObject in this.groups){
						cursor = cursorObject.cursor as DisplayObjectContainer;
						
						cursorMatrix = cursor.transform.matrix;
						cursorMatrix.translate(-this.centerOfGroupedTouchesX, -this.centerOfGroupedTouchesY);
						if(this.rKey){
							cursorMatrix.rotate(0.01 * yDiff);							
						}
						if(this.sKey){
							var finalScaleFactor:Number = 1;
							var scaleFactor:Number = 1;
							var i:Number;
							var scaleTimes:Number = 0;
							if(xDiff > 0){
								scaleFactor = 1.01;	
								scaleTimes = xDiff;
							}else if(xDiff < 0){
								scaleFactor = 0.99;
								scaleTimes = -xDiff;
							}
							//apply scaling as often as mouse have been moved in x direction since the last frame
							for(i = 0; i < scaleTimes; i++){
								finalScaleFactor = finalScaleFactor*scaleFactor;
							}
							cursorMatrix.scale(finalScaleFactor,finalScaleFactor);
						}
						cursorMatrix.translate(this.centerOfGroupedTouchesX, this.centerOfGroupedTouchesY);
						xPos = cursorMatrix.tx;
						yPos = cursorMatrix.ty;
						moveCursor(xPos, yPos, xDiff, yDiff, cursorObject.cursor.sessionId, cursorObject.cursor.source);
					}
				}
			}else{
				//if no touch from group has been selected, simply move single touch
				if(this.src == this.touchMoveSrc){
					moveCursor(stage.mouseX, stage.mouseY, xDiff, yDiff, this.touchMoveId, this.touchMoveSrc);
				}else{
					trace("You can only move touches that have been created via mouse clicks.");
				}
			}
		}
		
		/**
		 * takes care of the touch movement by dispatching an appropriate TuioTouchEvent or using the TuioManager and 
		 * adjusts the display of the touch in TuioDebug.
		 *  
		 * @param stageX the x coordinate of the touch 
		 * @param stageY the y coordinate of the touch 
		 * @param sessionId the session id of the touch 
		 * 
		 */
		private function moveCursor(stageX:Number, stageY:Number, diffX:Number, diffY:Number, sessionId:uint, source:String):void{
			var frameId:uint = this.frameId++;
			
			updateTuioCursor(getTuioCursor(sessionId, source), stageX, stageY, diffX, diffY, sessionId, frameId);
			dispatchUpdateCursor(getTuioCursor(sessionId, source));
		}
		
		/**
		 * removes the touch that is being dragged around from stage if no key has been pressed.
		 * 
		 * If the 'Shift' key has been pressed the touch will remain on the stage. 
		 * 
		 * If the 'Ctrl/Command' key has been pressed the touch will remain on stage and will be 
		 * added to a group.
		 * 
		 * If the 'Space' key is being pressed and a group of touches is being moved around the 
		 * whole group of touches will be removed.
		 *   
		 * @param event
		 * 
		 */
		private function dispatchTouchUp(event:MouseEvent):void{
			if(this.groups[this.touchMoveId] == null){
				//keep touch if shift key has been pressed
				if(!this.shiftKey && !event.ctrlKey){
					removeCursor(event, tuioSessionId, this.src);
				}else if(event.ctrlKey){
					var cursorUnderPoint:ITuioDebugCursor = getCursorUnderPointer(event.stageX, event.stageY);
					addToGroup(cursorUnderPoint);
				}
			}else{
				if(this.spaceKey){
					//remove all touches from group if space key is pressed
					for each(var cursorObject:Object in this.groups){
						var cursor:DisplayObjectContainer = cursorObject.cursor as DisplayObjectContainer;
						removeCursor(event, cursorObject.cursor.sessionId,cursorObject.cursor.source);
						deleteFromGroup(cursorObject.cursor);
					}
				}
			}
			
			tuioSessionId = tuioSessionId+1;
			touchMoveId = tuioSessionId;
			
			lastX = 0;
			lastY = 0;
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dispatchTouchMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, dispatchTouchUp);
		}
		
		private function deleteTuioCursorFromGlobalList(cursorID:Number):void{
			var i:Number = 0;
			for each(var tuioCursor:TuioCursor in _tuioCursors[this.src]){
				if(tuioCursor.sessionID == cursorID){
					_tuioCursors[this.src].splice(i, 1);
				}
				i = i+1;
			}
		}
		
		/**
		 * removes a touch from stage by dispatching an appropriate TuioTouchEvent or using the TuioManager and 
		 * removes the display of the touch in TuioDebug.
		 *  
		 * @param event
		 * @param sessionId session id of touch
		 * 
		 */
		private function removeCursor(event:MouseEvent, sessionId:uint, source:String):void{
			var frameId:uint = this.frameId++;
			
			dispatchRemoveCursor(getTuioCursor(sessionId,source));
			deleteTuioCursorFromGlobalList(sessionId);
		}
		/**
		 * returns the touch under the mouse pointer if there is one. Otherwise null will be returned.
		 * If the mouse pointer is above the red dot of a touch that beloings to a group still the
		 * touch will be returned.
		 *   
		 * @param stageX
		 * @param stageY
		 * @return the touch under the mouse pointer if there is one. Otherwise null will be returned.
		 * 
		 */
		private function getCursorUnderPointer(stageX:Number, stageY:Number):ITuioDebugCursor{
			var cursorUnderPointer:ITuioDebugCursor = null;
			
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(new Point(stageX, stageY));
			
			if(objectsUnderPoint[objectsUnderPoint.length-1] is ITuioDebugCursor){
				cursorUnderPointer = objectsUnderPoint[objectsUnderPoint.length-1];
			}else if(objectsUnderPoint.length > 1 && objectsUnderPoint[objectsUnderPoint.length-2] is ITuioDebugCursor){
				//if mouse pointer is above marker sprite, return ITuioDebugCursor beneath marker sprite
				cursorUnderPointer = objectsUnderPoint[objectsUnderPoint.length-2];
			}
			
			return cursorUnderPointer; 
		}
		
		
		/**
		 * 
		 * @param stageX
		 * @param stageY
		 * @return 
		 * 
		 */
		private function getObjectUnderPointer(stageX:Number, stageY:Number):ITuioDebugObject{
			var objectUnderPointer:ITuioDebugObject = null;
			
			var objectsUnderPoint:Array = stage.getObjectsUnderPoint(new Point(stageX, stageY));
			
			if(objectsUnderPoint[objectsUnderPoint.length-1] is ITuioDebugObject){
				objectUnderPointer = objectsUnderPoint[objectsUnderPoint.length-1];
			}else if(objectsUnderPoint.length > 1 && objectsUnderPoint[objectsUnderPoint.length-2] is ITuioDebugObject){
				//if mouse pointer is above marker sprite, return ITuioDebugCursor beneath marker sprite
				objectUnderPointer = objectsUnderPoint[objectsUnderPoint.length-2];
			}
			
			return objectUnderPointer; 
		}
		
		/**
		 * created a TuioCursor instance from the submitted parameters.
		 *  
		 * @param stageX an x coordinate in global coordinates.
		 * @param stageY a y coordinate in global coordinates.
		 * @param touchId the session id of a touch.
		 * 
		 * @return the TuioCursor.
		 * 
		 */
		private function createTuioCursor(stageX:Number, stageY:Number, diffX:Number, diffY:Number, sessionId:uint, frameId:uint):TuioCursor {
			return new TuioCursor(TWO_D_CUR,sessionId,stageX/stage.stageWidth, stageY/stage.stageHeight,0,diffX/stage.stageWidth,diffY/stage.stageHeight,0,0,frameId,this.src);
		}
		
		/**
		 * created a TuioContainer instance from the submitted parameters.
		 *  
		 * @param stageX an x coordinate in global coordinates.
		 * @param stageY a y coordinate in global coordinates.
		 * @param touchId the session id of a touch.
		 * 
		 * @return the TuioContainer.
		 * 
		 */
		/*private function createTuioContainer(type:String, stageX:Number, stageY:Number, sessionId:uint, frameId:uint):TuioContainer{
		return new TuioContainer(type,sessionId,stageX/stage.stageWidth, stageY/stage.stageHeight,0,0,0,0,0,frameId);
		}*/
		
		private function updateTuioCursor(tuioCursor:TuioCursor, stageX:Number, stageY:Number, diffX:Number, diffY:Number, sessionId:uint, frameId:uint):void {
			tuioCursor.update(stageX/stage.stageWidth, stageY/stage.stageHeight,0,diffX/stage.stageWidth,diffY/stage.stageHeight,0,0,frameId);
		}
		
		//==========================================  FIDUCIAL STUFF ==========================================
		
		/**
		 * decides whether a TUIO debug object should be removed or moved around.
		 * 
		 * @param cursorUnderPoint TUIO debug object under the mouse pointer.
		 * @param event
		 * 
		 */
		private function startMoveObject(objectUnderPoint:ITuioDebugObject, event:MouseEvent):void{
			//update or remove cursor under mouse pointer
			if(event.shiftKey){
				//remove cursor
				removeObject(event);
			}else{
				//move cursor
				this.movedObject = objectUnderPoint;
				
				//store start position in order to move object around the point where it has been clicked
				this.lastX = stage.mouseX;
				this.lastY = stage.mouseY;
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, dispatchObjectMove);
				stage.addEventListener(MouseEvent.MOUSE_UP, dispatchObjectUp);
			}
		}
		
		/**
		 * moves a fiducial. 
		 * 
		 * If the 'r' key is being pressed the TUIO object will be rotated.
		 *  
		 * @param event
		 * 
		 */
		private function dispatchObjectMove(event:MouseEvent):void{
			var stageX:Number = (this.movedObject as DisplayObjectContainer).x + stage.mouseX - this.lastX;
			var stageY:Number = (this.movedObject as DisplayObjectContainer).y + stage.mouseY - this.lastY;
			if(!this.rKey){
				if(this.movedObject.source == this.src){
					moveObject(stageX, stageY, this.movedObject.sessionId, this.movedObject.fiducialId, this.movedObject.objectRotation);
				}else{
					trace("You can only move objects that have been created via mouse clicks.");
				}
			}else{
				var rotationVal:Number = this.movedObject.objectRotation + (0.01 * (stage.mouseY-this.lastY));
				if(this.movedObject.source == this.src){
					moveObject((this.movedObject as DisplayObjectContainer).x,(this.movedObject as DisplayObjectContainer).y, this.movedObject.sessionId, this.movedObject.fiducialId, rotationVal);
				}else{
					trace("You can only rotate objects that have been created via mouse clicks.");
				}
			}
			this.lastX = stage.mouseX;
			this.lastY = stage.mouseY;
		}
		
		/**
		 * takes care of the fiducial movement by dispatching an appropriate FiducialEvent or using the TuioManager and
		 * the TuioFiducialDispatcher to adjust the display of the fiducial in TuioDebug.
		 *  
		 * @param stageX the x coordinate of the mouse pointer 
		 * @param stageY the y coordinate of the mouse pointer 
		 * @param sessionId the session id of the fiducial 
		 * 
		 */
		private function moveObject(stageX:Number, stageY:Number, sessionId:uint, fiducialId:uint, rotation:Number):void{
			var frameId:uint = this.frameId++;
			var updateTuioObject:TuioObject = getTuioObject(sessionId, this.src); 
			updateTuioObject.update(stageX/stage.stageWidth, stageY/stage.stageHeight,0,rotation,0,0,0,0,0,0,0,0,0,0,frameId);
			dispatchUpdateObject(updateTuioObject);
		}
		
		/**
		 * Removes the move and up listener for fiducial movement.
		 *   
		 * @param event
		 * 
		 */
		private function dispatchObjectUp(event:MouseEvent):void{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, dispatchObjectMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, dispatchObjectUp);
		}
		
		/**
		 * removes a fiducial from stage by dispatching an appropriate FiducialEvent and 
		 * removes the display of the fiducial in TuioDebug.
		 *  
		 * @param event
		 * 
		 */
		private function removeObject(event:MouseEvent):void{
			var frameId:uint = this.frameId++;
			if(this.movedObject.source == this.src){
				dispatchRemoveObject(getTuioObject(this.movedObject.sessionId, this.movedObject.source));
			}else{
				trace("You can only remove objects that have been created via mouse clicks.");
			}
		}
		
		private function createTuioObject(fiducialId:Number, stageX:Number, stageY:Number, sessionId:uint, rotation:Number, frameId:uint):TuioObject{
			return new TuioObject(TWO_D_OBJ,sessionId,fiducialId, stageX/stage.stageWidth, stageY/stage.stageHeight,0,rotation,0,0,0,0,0,0,0,0,0,0,frameId,this.src);
		}
		
		//==========================================  KEYBOARD STUFF ==========================================
		
		/**
		 * if the 'Space' key is being pressed spaceKey is set to true in this instance. 
		 * 
		 * If the 'r' key is being pressed rKey is set to true in this instance and the 
		 * barycentric coordinates of the touch group is being calculated. 
		 *  
		 * @param event
		 * 
		 */
		private function keyDown(event:KeyboardEvent):void{
			//if space has been pressed, all touches will be released
			if(event.keyCode == 32){//space
				this.spaceKey = true;
			}
			
			//if 's' or 'r' has been pressed while a grouped touch has been
			//clicked, touches will be 's'caled or 'r'otated
			if(event.keyCode == 82 || event.keyCode == 83){
				if(event.keyCode == 82){//r
					//caused by some very odd bug, an error appears when applying the rotation
					//if this.rKey is set to true again if it has been already set to true (remove
					//if statement and try it out to see what i mean)
					if(!this.rKey){
						this.rKey = true;
					}
				}
				if(event.keyCode == 83){//s
					//the same mentioned above applies to this statement
					if(!this.sKey){
						this.sKey = true;
					}
				}
				var cursorUnderPoint:ITuioDebugCursor = getCursorUnderPointer(stage.mouseX, stage.mouseY);
				if(cursorUnderPoint != null && this.groups[cursorUnderPoint.sessionId] != null){
					//rotate around barycenter of touches
					var xPos:Number;
					var yPos:Number;
					var xPositions:Array = new Array();
					var yPositions:Array = new Array();
					var calcCenterPoint:Point = new Point();
					var touchAmount:Number = 0;
					
					calcCenterPoint.x = 0;
					calcCenterPoint.y = 0;
					
					
					for each(var cursorObject:Object in this.groups){
						var cursor:DisplayObjectContainer = cursorObject.cursor as DisplayObjectContainer;
						xPos = cursor.x;
						yPos = cursor.y;
						xPositions.push(xPos);
						yPositions.push(yPos);
						
						calcCenterPoint.x = calcCenterPoint.x + xPos;
						calcCenterPoint.y = calcCenterPoint.y + yPos;
						
						touchAmount = touchAmount+1;
					}
					
					this.centerOfGroupedTouchesX = calcCenterPoint.x/touchAmount;
					this.centerOfGroupedTouchesY = calcCenterPoint.y/touchAmount;
				}
			}
		}
		
		/**
		 * sets keyboard variables to false.
		 *  
		 * @param event
		 * 
		 */
		private function keyUp(event:KeyboardEvent):void{
			if(event.keyCode == 32){//space
				this.spaceKey = false;
			}
			if(event.keyCode == 82){//r
				this.rKey = false;
				this.centerOfGroupedTouchesX = 0;
				this.centerOfGroupedTouchesY = 0;
			}
			if(event.keyCode == 83){//s
				this.sKey = false;			
			}
		}
		
		//==========================================  FLASH CONTEXT MENU STUFF ==========================================
		
		private function addFlashContextMenu():void{
			//flash provides a ContextMenu class in flash.ui that enables to use
			//the context menu in an swf. however, ContextMenu is not provided 
			//in the flex sdk and thus not supported by TUIO AS3. so go ahead 
			//if you want to use flash and implement it yourself like this:
			//http://www.republicofcode.com/tutorials/flash/as3contextmenu/
		}
		
		private function removeFlashContextMenu():void{
			//flash provides a ContextMenu class in flash.ui that enables to use
			//the context menu in an swf. however, ContextMenu is not provided 
			//in the flex sdk and thus not supported by TUIO AS3. so go ahead 
			//if you want to use flash and implement it yourself like this:
			//http://www.republicofcode.com/tutorials/flash/as3contextmenu/
		}
		
	}
}