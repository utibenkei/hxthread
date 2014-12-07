import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.net.FileDownloadThread;
import ProgressBarThread;


/**
 * このスレッドは、ステージをマウスでクリックされるのを待ち、FileDownloadThread を用いてファイルをダウンロードするすると共に、
 * ProgressBarThread を用いてその進捗状況をプログレスバーとして表示します。
 */
class MainThread extends Thread
{
	// ダウンロード元の URL
	private static inline var DOWNLOAD_URL:String = "file.txt";
	
	public function new(layer:Sprite)
	{
		super();
		_layer = layer;
	}
	
	private var _layer:Sprite;
	
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// ステージがクリックされたら stageClickHandler を実行します
		Thread.event(_layer.stage, MouseEvent.CLICK, stageClickHandler);
	}
	
	private function stageClickHandler(e:MouseEvent):Void
	{
		// ファイルアップロード用のスレッドを作成します
		var fileDownload:FileDownloadThread = new FileDownloadThread(new URLRequest(DOWNLOAD_URL));
		
		// プログレスバーを描画する ProgressBarThread を開始します
		new ProgressBarThread(fileDownload.progress, _layer.graphics, _layer.stage.stageWidth).start();
		
		trace("Download Start!");
		
		// ファイルのアップロードを開始します
		fileDownload.start();
		// 完了を待ちます
		fileDownload.join();
		// 完了したら complete を実行します
		Thread.next(complete);
	}
	
	private function complete():Void
	{
		trace("Download Complete!");
		
		// run メソッドを呼び出して再びイベントを待ちます
		run();
	}
}
