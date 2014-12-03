package;


import flash.display.Sprite;
import flash.events.Event;
import flash.Lib;
import org.libspark.thread.EnterFrameThreadExecutor;
import org.libspark.thread.Thread;

/**
 * このサンプルでは IProgress による進捗状況の表示や通知方法などを学びます
 *
 * 詳細は MainThread を見てください
 */
//@:meta(SWF(width=400,height=200,frameRate=30,backgroundColor=0xffffff))

class Sample extends Sprite
{
	private function init() 
	{
		// スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
		// Thread#initialize には、IThreadExecutor のインスタンスを渡します
		// ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
		Thread.initialize(new EnterFrameThreadExecutor());
		
		// MainThread を起動します
		var main:MainThread = new MainThread(this);
		main.start();
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
		Lib.current.addChild(new Sample());
	}
}
