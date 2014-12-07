
import flash.display.Graphics;
import org.libspark.thread.Thread;
import org.libspark.thread.utils.IProgress;

/*
 * * このスレッドは、与えられた IProgress インターフェイスのインスタンスが示す進捗状況を、プログレスバーとして描画します。
 */
class ProgressBarThread extends Thread
{
	/**
	 * @param	progress	進捗状況
	 * @param	graphics	プログレスバーの描画先
	 * @param	width	プログレスバーの最大幅
	 */
	public function new(progress:IProgress, graphics:Graphics, width:Int)
	{
		super();
		_progress = progress;
		_graphics = graphics;
		_width = width;
		// 表示用
		_displayWidth = 0;
	}
	
	private var _progress:IProgress;
	private var _graphics:Graphics;
	private var _width:Int;
	private var _displayWidth:Float;
	
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// 現在のプログレスバーの幅を算出します
		var w:Float = _width * _progress.percent;
		
		// 表示用の幅を算出します
		// これは、プログレスバーがだんだん伸びるアニメーションを実現するために必要です
		_displayWidth += (w - _displayWidth) / 3;
		
		// プログレスバーを描画します
		_graphics.clear();
		_graphics.beginFill(0x000000);
		_graphics.drawRect(0, 0, _displayWidth, 20);
		_graphics.endFill();
		
		// 仕事が完了/失敗/キャンセルされていて
		if (_progress.isCompleted || _progress.isFailed || _progress.isCanceled) {
			// プログレスバーの伸びるアニメーションが完了していたら終了します
			if (_displayWidth == w) {
				return;
			}
		}
		
		
		// 次もまたこのメソッドを実行します
		Thread.next(run);
	}
}
