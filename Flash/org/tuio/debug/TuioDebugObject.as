package org.tuio.debug
{
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * <p>Default implementation of the debug object square that is being shown by <code>TuioDebug</code> for
	 * each tuio object.</p>
	 * 
	 * <p><code>TuioDebugObject</code> implements <code>ITuioDebugObject</code> in order to be marked as debug
	 * information and not as the content of the actual application. This is necessary for the event dispatching
	 * mechanism in <code>TuioManager</code>.</p>
	 *  
	 * @see ITuioDebugObject
	 *   
	 * @author Johannes Luderschmidt
	 * 
	 */
	public class TuioDebugObject extends Sprite implements ITuioDebugObject
	{
		private var _sessionId:uint;
		private var _fiducialId:uint;
		private var _objectRotation:Number;
		private var _source:String;
		
		/**
		 * 
		 * @param objectId fiducial id
		 * @param width of the square
		 * @param height of the square
		 * @param color of the square's fill.
		 * @param alpha of the square's fill.
		 * @param lineThickness thickness of the line around the square.
		 * @param lineColor color of the line around the square.
		 * @param lineAlpha alpha of the line around the square.
		 * 
		 */
		public function TuioDebugObject(fiducialId:Number, sessionId:Number, objectRotation:Number, width:Number, height:Number, color:Number, alpha:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number, source:String){
			super();
			this.sessionId = sessionId;
			this.fiducialId = fiducialId;
			this.objectRotation = objectRotation;
			this.source = source;
			adjustGraphics(fiducialId, width, height, color, alpha, lineThickness, lineColor, lineAlpha);
		}
		
		/**
		 * draws the Graphics.
		 * 
		 * @param objectId fiducial id
		 * @param width of the square
		 * @param height of the square
		 * @param color of the square's fill.
		 * @param alpha of the square's fill.
		 * @param lineThickness thickness of the line around the square.
		 * @param lineColor color of the line around the square.
		 * @param lineAlpha alpha of the line around the square.
		 * 
		 */
		public function adjustGraphics(objectId:Number, width:Number, height:Number, color:Number, alpha:Number, lineThickness:Number, lineColor:Number, lineAlpha:Number):void{
			//draw object rect
			this.graphics.clear();
			this.graphics.beginFill(color,alpha);
			this.graphics.lineStyle(lineThickness, lineColor, lineAlpha);
			this.graphics.drawRect(-0.5*width, -0.5*height, width,height);
			this.graphics.endFill();
			
			//draw direction line
			this.graphics.lineStyle(3, 0x0, 1);
			this.graphics.moveTo(0,0);
			this.graphics.lineTo(0,-0.5*height+5);
			
			//draw objectid label
			var fiducialIdLabel:TextField = new TextField();
            fiducialIdLabel.autoSize = TextFieldAutoSize.LEFT;
            fiducialIdLabel.background = false;
            fiducialIdLabel.border = false;
			fiducialIdLabel.text = ""+objectId;
			fiducialIdLabel.width/2+5;
            fiducialIdLabel.defaultTextFormat = fiducialIdTextFormat();
            fiducialIdLabel.setTextFormat(fiducialIdTextFormat());
            
            var translationX:Number = -0.5*width+0.5*fiducialIdLabel.width;
            var translationY:Number = 0.5*height-0.5*fiducialIdLabel.height;
            //copy TextField into a bitmap
			var typeTextBitmap : BitmapData = new BitmapData(fiducialIdLabel.width, 
			                                fiducialIdLabel.height,true,0x00000000);
			typeTextBitmap.draw(fiducialIdLabel);
			 
			//calculate center of TextField
			var typeTextTranslationX:Number = -0.5*fiducialIdLabel.width+translationX+5;
			var typeTextTranslationY:Number = -0.5*fiducialIdLabel.height+translationY-5;
			 
			//create Matrix which moves the TextField to the center
			var matrix:Matrix = new Matrix();
			matrix.translate(typeTextTranslationX, typeTextTranslationY);
			
			//actually draw the text on the stage (with no-repeat and anti-aliasing)
			this.graphics.beginBitmapFill(typeTextBitmap,matrix,false,true);
			this.graphics.lineStyle(0,0,0);
			this.graphics.drawRect(typeTextTranslationX, typeTextTranslationY, 
			                                fiducialIdLabel.width, fiducialIdLabel.height);
			this.graphics.endFill();
		}
		
		private function fiducialIdTextFormat():TextFormat{
			var format:TextFormat = new TextFormat();
            format.font = "Arial";
            format.color = 0xffffff;
            format.size = 11;
            format.underline = false;
	            
        	return format;
		}
		
		public function get sessionId():uint{
			return this._sessionId;
		}
		public function set sessionId(sessionId:uint):void{
			this._sessionId = sessionId;
		}
		public function get fiducialId():uint{
			return _fiducialId;
		}
		public function set fiducialId(fiducialId:uint):void{
			this._fiducialId = fiducialId;	
		}
		public override function set rotation(value:Number):void{
			super.rotation = value;
			this.objectRotation = value/180*Math.PI;
		}
		public function get objectRotation():Number{
			return this._objectRotation; 
		}
		public function set objectRotation(objectRotation:Number):void{
			this._objectRotation = objectRotation;	
		}
		public function get source():String{
			return this._source;
		}
		public function set source(source:String):void{
			this._source = source;
		}
	}
}