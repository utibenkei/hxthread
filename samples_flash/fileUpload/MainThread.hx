import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.net.URLRequest;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.net.FileUploadThread;
import ProgressBarThread;


/**
 * このスレッドは、ステージをマウスでクリックされるのを待ち、FileUploadThread を用いてファイルをアップロードするすると共に、
 * ProgressBarThread を用いてその進捗状況をプログレスバーとして表示します。
 */
class MainThread extends Thread
{
	// アップロード先の URL
	private static inline var UPLOAD_URL:String = "upload.php";
	
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
		var fileUpload:FileUploadThread = new FileUploadThread(new URLRequest(UPLOAD_URL));
		
		// プログレスバーを描画する ProgressBarThread を開始します
		new ProgressBarThread(fileUpload.progress, _layer.graphics, _layer.stage.stageWidth).start();
		
		trace("Upload Start!");
		
		// ファイルのアップロードを開始します
		fileUpload.start();
		// 完了を待ちます
		fileUpload.join();
		// 完了したら complete を実行します
		Thread.next(complete);
	}
	
	private function complete():Void
	{
		trace("Upload Complete!");
		
		// run メソッドを呼び出して再びイベントを待ちます
		run();
	}
}
