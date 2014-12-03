
import flash.events.Event;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.events.ProgressEvent;
import org.libspark.thread.utils.IProgress;

/**
 * このスレッドは、進捗状況を出力します
 */
class ProgressTraceThread extends Thread
{
	public function new(progress:IProgress)
	{
		super();
		_progress = progress;
	}
	
	private var _progress:IProgress;
	
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// 開始を待ちます
		event(_progress, ProgressEvent.START, startHandler);
	}
	
	private function startHandler(e:Event):Void
	{
		// 仕事が開始されました
		trace("[Progress] Start...");
		
		// いずれかのイベントを待ちます
		event(_progress, ProgressEvent.UPDATE, updateHandler);
		event(_progress, ProgressEvent.COMPLETED, completeHandler);
		event(_progress, ProgressEvent.FAILED, failedHandler);
		event(_progress, ProgressEvent.CANCELED, canceledHandler);
	}
	
	private function updateHandler(e:Event):Void
	{
		// 進捗が更新されました
		trace("[Progress] " + (_progress.percent * 100) + "%");
		
		// いずれかのイベントを待ちます
		event(_progress, ProgressEvent.UPDATE, updateHandler);
		event(_progress, ProgressEvent.COMPLETED, completeHandler);
		event(_progress, ProgressEvent.FAILED, failedHandler);
		event(_progress, ProgressEvent.CANCELED, canceledHandler);
	}
	
	private function completeHandler(e:Event):Void
	{
		// 仕事が完了しました
		trace("[Progress] Complete");
	}
	
	private function failedHandler(e:Event):Void
	{
		// 仕事が失敗しました
		trace("[Progress] Failed");
	}
	
	private function canceledHandler(e:Event):Void
	{
		// 仕事がキャンセルされました
		trace("[Progress] Cancel");
	}
}
