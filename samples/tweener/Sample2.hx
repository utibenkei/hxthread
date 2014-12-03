package;


import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import MainThread2;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;



/**
 * このサンプルでは TweenerThread の使用方法などを学びます
 *
 * 詳細は MainThread を見てください
 */
//@:meta(SWF(width=500,height=500,frameRate=30))

class Sample2 extends Sprite
{
	
	private function init():Void
	{
		// スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
		// Thread#initialize には、IThreadExecutor のインスタンスを渡します
		// ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
		Thread.initialize(new EnterFrameThreadExecutor());
		
		// MainThread を起動します
		var main:MainThread2 = new MainThread2(this);
		main.start();
	}
	
	private function createShape():Sprite
	{
		var sprite:Sprite = new Sprite();
		
		sprite.graphics.beginFill(0x000000);
		sprite.graphics.drawRect(0, 0, 100, 100);
		sprite.graphics.endFill();
		
		addChild(sprite);
		
		return sprite;
	}
	
	private function createBorder():DisplayObject
	{
		var shape:Shape = new Shape();
		
		shape.graphics.lineStyle(2, 0xcccccc);
		shape.graphics.drawRect(0, 0, 100, 100);
		
		addChild(shape);
		
		return shape;
	}
	
	public function new() 
	{
		super();
		addEventListener(Event.ADDED_TO_STAGE, added);
	}

	function added(e) 
	{
		removeEventListener(Event.ADDED_TO_STAGE, added);
		init();
	}
	
	/**
	 * コンストラクタ
	 *
	 * @access public
	 * @param
	 * @return
	 */
	public static function main() 
	{
		// static entry point
		Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		Lib.current.addChild(new Sample2());
	}
}
