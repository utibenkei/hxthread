import ProgressTraceThread;

import flash.events.Event;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.Executor;
import org.libspark.thread.utils.ParallelExecutor;
import org.libspark.thread.threads.net.URLLoaderThread;

import flash.net.URLRequest;
import flash.net.URLLoader;

import flash.errors.IOError;

/**
	 * このスレッドは、URLLoaderThread を用いてデータをダウンロードします。
	 * 同時に、 ProgressTraceThread を用いて進捗状況も表示します。
	 */
class MainThreadWithProgress extends Thread
{
    private var _loader : URLLoaderThread;
    
    /**
		 * スレッドの処理は run メソッドをオーバーライドして記述します
		 */
    override private function run() : Void
    {
        // データを読み込むための URLLoaderThread を作成します
        _loader = new URLLoaderThread(new URLRequest("http://as-users.jp/index.html"));
        
        // 進捗を表示するための ProgressTraceThread を作成します
        var tracer : Thread = new ProgressTraceThread(_loader.progress);
        
        trace("begin loading.");
        
        // ロード処理を開始 （= URLLoaderThread スレッドを開始） します
        _loader.start();
        // スレッドが終了 （= ロードが完了） するまで、次のメソッドが実行されないように待ちます
        _loader.join();
        
        // 進捗表示を開始 (= ProgressTraceThread スレッドを開始) します
        tracer.start();
        
        // 次に実行されるメソッドをセットしておきます
        next(executeComplete);
        // 例外ハンドラを設定しておきます
        error(IOError, errorHandler);
        error(SecurityError, errorHandler);
    }
    
    /**
		 * executeComplete メソッドには、ロード完了後の処理を書く事にします
		 */
    private function executeComplete() : Void
    {
        trace("complete loading.");
        
        // 読み込んだ loader.data を使って何かする
        trace(_loader.loader.data.substr(0, 10));
    }
    
    /**
		 * スレッドの終了処理は finalize メソッドをオーバーライドして記述します
		 */
    override private function finalize() : Void
    {
        _loader = null;
        
        trace("end.");
    }
    
    /**
		 * 例外ハンドラ
		 *
		 * @param	e	発生した例外
		 * @param	thread	発生元のスレッド
		 */
    private function errorHandler(e : IOError, t : Thread) : Void
    {
        trace("error!!");
        
        // 例外を出力して終了
        trace(e.getStackTrace());
        // 例外ハンドラから終了するには、明示的に next(null) を呼び出します
        next(null);
    }

    public function new()
    {
        super();
    }
}
