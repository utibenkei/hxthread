import nme.errors.Error;

import flash.display.Sprite;
import jp.progression.commands.SerialList;
import jp.progression.commands.Trace;
import jp.progression.commands.Wait;
import org.libspark.thread.threads.progression.ThreadCommand;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

/**
 * このサンプルでは ThreadCommand を利用して、 Progression のコマンドにスレッドを組み込んで使う方法を学びます。
 */



class ThreadCommandSample extends Sprite
{
	public function new()
	{
		super();
		// スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
		// Thread#initialize には、IThreadExecutor のインスタンスを渡します
		// ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
		Thread.initialize(new EnterFrameThreadExecutor());
		
		// コマンドを順番に実行
		new SerialList(null, 
				// Start! を出力
				new Trace("Start!"), 
				// 1秒待つ
				new Wait(1000), 
				// HogeThread を実行 (「ほげ」 と 「ほげほげ!!」 が出力される)
				new ThreadCommand(new HogeThread()), 
				// HogeComplete を出力
				new Trace("HogeComplete"), 
				// ErrorThread を実行 (このスレッドでは例外が発生する)
				new ThreadCommand(new ErrorThread()).error(function(e:Error):Void
						{
							// その例外を捕捉して出力 (「Error: えららー」 が出力される)
							trace("Error: " + e.message);
							
							// 処理を続行
							this.executeComplete();
						}), 
				// Complete! を出力
				new Trace("Complete!"), 
				).execute();
	}
}



class HogeThread extends Thread
{
	override private function run():Void
	{
		trace("ほげ");
		
		next(hogehoge);
	}
	
	private function hogehoge():Void
	{
		trace("ほげほげ!!");
	}

	public function new()
	{
		super();
	}
}

class ErrorThread extends Thread
{
	override private function run():Void
	{
		throw new Error("えららー");
	}

	public function new()
	{
		super();
	}
}