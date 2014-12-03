
import org.libspark.thread.Thread;

/**
 * このスレッドは、
 *	Hello,
 *	Thread
 *	!!
 * を出力します
 *
 * 独自のスレッドを作るには、まず Thread クラスを継承する必要があります
 */
class HelloThread extends Thread
{
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// まずは Hello, を出力します
		trace("Hello,");
		// next メソッドで、次に実行するメソッドを指定します
		Thread.next(run2);
	}
	
	private function run2():Void
	{
		// 続いて Thread を出力します
		trace("Thread");
		// next メソッドで、次に実行するメソッドを指定します
		Thread.next(run3);
	}
	
	private function run3():Void
	{
		// 最後に !! を出力します
		trace("!!");
	}

	public function new()
	{
		super();
	}
}

