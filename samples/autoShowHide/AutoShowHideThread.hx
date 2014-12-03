
import flash.display.InteractiveObject;
import flash.events.MouseEvent;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.tweener.TweenerThread;

/**
 * このスレッドは、「ロールオーバーするとフェードしながら現れて、しばらくマウスを動かさずに放っておくか、
 * ロールアウトするとフェードしながら消える、よくあるアレ」を実現します。
 */
class AutoShowHideThread extends Thread
{
	public function new(target:InteractiveObject)
	{
		super();
		_target = target;
	}
	
	private var _target:InteractiveObject;
	private var _tween:TweenerThread;
	
	override private function run():Void
	{
		// 予めアルファを 0 にしておきます
		_target.alpha = 0;
		
		// ロールオーバーを待ちます
		waitRollover();
	}
	
	private function waitRollover():Void
	{
		_tween = null;
		
		// ロールオーバーするか、(ターゲットの上で)マウスが動いたらフェードインに移行します
		event(_target, MouseEvent.ROLL_OVER, fadeIn);
		event(_target, MouseEvent.MOUSE_MOVE, fadeIn);
	}
	
	private function fadeIn(e:MouseEvent = null):Void
	{
		// トゥイーン時間
		var t:Float = 1.0;
		
		// 現在実行中のトゥイーンがある場合
		if (_tween != null) {
			// そのトゥイーンをキャンセルします
			_tween.cancel();
			// 時間を調整します
			t = _tween.time / 1000;
		}  // アルファが 1.0 になるようなトゥイーンを作成します	 
		
		
		
		_tween = new TweenerThread(_target, {
					alpha:1.0,
					time:t,

				});
		// トゥイーンを開始します
		_tween.start();
		// トゥイーンが終わるのを待ちます
		_tween.join();
		
		// トゥイーン中にロールアウトしたらフェードアウトに移行します
		event(_target, MouseEvent.ROLL_OUT, fadeOut);
		// ロールアウトせずにトゥイーンが終了した場合ロールアウト待ちに移行します
		next(waitRollout);
	}
	
	private function waitRollout(e:MouseEvent = null):Void
	{
		_tween = null;
		
		// ロールアウトしたらフェードアウトに移行します
		event(_target, MouseEvent.ROLL_OUT, fadeOut);
		
		// 2 秒待って何も起きなかった場合
		sleep(2000);
		// 自動的にフェードアウトに移行します
		next(fadeOut);
		
		// ただし、マウスが動いている場合はフェードアウトしないように再びこのメソッドを実行するようにします
		event(_target, MouseEvent.MOUSE_MOVE, waitRollout);
	}
	
	private function fadeOut(e:MouseEvent = null):Void
	{
		// トゥイーン時間
		var t:Float = 1.0;
		
		// 現在実行中のトゥイーンがある場合
		if (_tween != null) {
			// そのトゥイーンをキャンセルします
			_tween.cancel();
			// 時間を調整します
			t = _tween.time / 1000;
		}  // アルファが 0 になるようなトゥイーンを作成します  
		
		
		
		_tween = new TweenerThread(_target, {
					alpha:0,
					time:t,

				});
		// トゥイーンを開始します
		_tween.start();
		// トゥイーンが終わるのを待ちます
		_tween.join();
		
		// トゥイーン中にロールオーバーしたり
		event(_target, MouseEvent.ROLL_OVER, fadeIn);
		// マウスが動いたりした場合はフェードインに移行します
		event(_target, MouseEvent.MOUSE_MOVE, fadeIn);
		// 何事もなくトゥイーンが終了した場合、ロールオーバー待ちに移行します
		next(waitRollover);
	}
}
