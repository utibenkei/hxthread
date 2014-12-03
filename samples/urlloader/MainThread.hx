package;


import flash.errors.IOError;
import flash.errors.SecurityError;
import flash.net.URLLoader;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.net.URLLoaderThread;
import org.libspark.thread.utils.Executor;
import org.libspark.thread.utils.ParallelExecutor;


/**
 * このスレッドは、URLLoaderThread と ParallelExecutor を用いて、平行して三つの URL からデータをダウンロードします
 */
class MainThread extends Thread
{
	private var _loaders:Executor;
	
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// 並列してスレッドを実行するための ParallelExecutor を作成します
		_loaders = new ParallelExecutor();
		
		// これに、三つのURLLoaderThreadを追加します
		_loaders.addThread(new URLLoaderThread(new URLRequest("http://www.google.co.jp/")));
		_loaders.addThread(new URLLoaderThread(new URLRequest("http://www.yahoo.co.jp/")));
		_loaders.addThread(new URLLoaderThread(new URLRequest("http://www.adobe.com/jp/")));
		
		trace("begin loading.");
		
		// ロード処理を開始 （= SerialExecutor スレッドを開始） します
		_loaders.start();
		// スレッドが終了 （= ロードが完了） するまで、次のメソッドが実行されないように待ちます
		_loaders.join();
		
		// 次に実行されるメソッドをセットしておきます
		Thread.next(executeComplete);
		// 例外ハンドラを設定しておきます
		Thread.error(IOError, errorHandler);
		Thread.error(SecurityError, errorHandler);
	}
	
	/**
	 * executeComplete メソッドには、ロード完了後の処理を書く事にします
	 */
	private function executeComplete():Void
	{
		trace("complete loading.");
		
		for (i in 0..._loaders.numThreads){
			var loader:URLLoader = cast((_loaders.getThreadAt(i)), URLLoaderThread).loader;
			
			// 読み込んだloader.dataを使って何かする
			trace(loader.data.substr(0, 10));
		}  // 終了の前には finalize が呼び出されます	// next を設定しなければスレッドは終了します  
	}
	
	/**
	 * スレッドの終了処理は finalize メソッドをオーバーライドして記述します
	 */
	override private function finalize():Void
	{
		_loaders = null;
		
		trace("end.");
	}
	
	/**
	 * 例外ハンドラ
	 *
	 * @param	e	発生した例外
	 * @param	thread	発生元のスレッド
	 */
	private function errorHandler(e:IOError, t:Thread):Void
	{
		trace("error!!");
		
		// 例外を出力して終了
		trace(e.getStackTrace());
		// 例外ハンドラから終了するには、明示的に next(null) を呼び出します
		Thread.next(null);
	}

	public function new()
	{
		super();
	}
}
