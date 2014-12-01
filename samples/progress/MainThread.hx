import ProgressBarThread;
import WorkerThread;

import flash.display.Sprite;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.MultiProgress;
import org.libspark.thread.utils.SerialExecutor;
import org.libspark.thread.utils.IProgressNotifier;

/**
	 * このスレッドは、複数の WorkerThread を実行すると共に、 ProgressBarThread を用いてその進捗状況をプログレスバーとして表示します。
	 */
class MainThread extends Thread
{
    public function new(layer : Sprite)
    {
        super();
        _layer = layer;
    }
    
    private var _layer : Sprite;
    
    /**
		 * スレッドの処理は run メソッドをオーバーライドして記述します
		 */
    override private function run() : Void
    {
        // WorkerThread を順次実行するための SerialExecutor を作成します
        var executor : SerialExecutor = new SerialExecutor();
        
        // 4つの WorkerThread を追加します
        executor.addThread(new WorkerThread("Worker1"));
        executor.addThread(new WorkerThread("Worker2"));
        executor.addThread(new WorkerThread("Worker3"));
        executor.addThread(new WorkerThread("Worker4"));
        
        // 複数の進捗状況をひとつにまとめるための MultiProgress を作成します
        var progress : MultiProgress = new MultiProgress();
        
        // 4つの WorkerThread の進捗状況をひとつにまとめます
        // 第二引数には、その仕事の重みを設定します。ここでは、 Worker2 と Worker3 の占める割合を、
        // Worker1 と Worker4 より多くしています。
        progress.addProgress(cast((executor.getThreadAt(0)), IProgressNotifier).progress, 1.0);
        progress.addProgress(cast((executor.getThreadAt(1)), IProgressNotifier).progress, 2.0);
        progress.addProgress(cast((executor.getThreadAt(2)), IProgressNotifier).progress, 3.0);
        progress.addProgress(cast((executor.getThreadAt(3)), IProgressNotifier).progress, 1.0);
        
        trace("Start!");
        
        // WorkerThraed を開始します
        executor.start();
        // 終了を待ちます
        executor.join();
        
        // ProgressBarThread を開始します
        new ProgressBarThread(progress, _layer.graphics, _layer.stage.stageWidth).start();
        
        // 次に実行するメソッドを設定します
        next(complete);
    }
    
    private function complete() : Void
    {
        trace("Complete!");
    }
}
