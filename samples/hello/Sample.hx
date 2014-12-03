
import flash.display.Sprite;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

/**
 * このサンプルでは最も単純なスレッドの実行の仕方を学びます
 *
 * このサンプルを実行すると、
 *	Hello,
 *	Thread
 *	!!
 * と出力されます
 */
class Sample extends Sprite
{
	public static function main()
	{
		
		// スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
		// Thread#initialize には、IThreadExecutor のインスタンスを渡します
		// ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
		Thread.initialize(new EnterFrameThreadExecutor());
		
		// HelloThread を起動します
		var hello:HelloThread = new HelloThread();
		hello.start();
	}
}


