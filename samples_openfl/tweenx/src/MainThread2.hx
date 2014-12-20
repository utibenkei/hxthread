import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Shape;
import org.libspark.thread.Thread;
import org.libspark.thread.threads.tweenx.TweenXThread;
import tweenx909.EaseX;
import tweenx909.TweenX;

/**
 * このスレッドは、TweenXThread を用いて、シェイプをアニメーションさせます
 */
class MainThread2 extends Thread
{
	public function new(layer:DisplayObjectContainer)
	{
		super();
		_layer = layer;
	}
	
	private var _layer:DisplayObjectContainer;
	private var _shape:DisplayObject;
	
	/**
	 * スレッドの処理は run メソッドをオーバーライドして記述します
	 */
	override private function run():Void
	{
		// シェイプを作成
		var shape:Shape = new Shape();
		shape.graphics.beginFill(0x000000);
		shape.graphics.drawRect(0, 0, 30, 30);
		shape.graphics.endFill();
		shape.x = 10;
		shape.y = 10;
		_shape = _layer.addChild(shape);
		
		//TweenXのデフォルト値設定
		TweenX.defaultEase = EaseX.quartOut;
		
		// アニメーションさせる
		move();
	}
	
	/**
	 * 出たり消えたりしながらランダムに動く
	 */
	private function move():Void
	{
		// TweenXThread を作成
		var tween:Thread = new TweenXThread(_shape, [{
			x: Math.random() * 450,
			y: Math.random() * 450,
			time: 1.0,
			show: true, // 特殊プロパティshow: true にするとトゥイーン開始時に visible が true になる
			hide: true  // 特殊プロパティhide: true にするとトゥイーン終了時に visible が false　になる
		}]);
			
		// 開始
		tween.start();
		// 終了を待つ
		tween.join();
		// 次
		Thread.next(afterMove);
	}
	
	/**
	 * 動いた後
	 */
	private function afterMove():Void
	{
		// 1秒待って
		Thread.sleep(1 * 1000);
		// また動く
		Thread.next(move);
	}
}
