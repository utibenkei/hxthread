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
class MainThread extends Thread
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
		moveRight();
	}
	
	/**
	 * 右にアニメーション
	 */
	private function moveRight():Void
	{
		// TweenXThread を作成
		var tween:Thread = new TweenXThread(_shape, [{
			x:460,
			y:10,
			time:1.0
		}]);
		// 開始
		tween.start();
		// 終了を待つ
		tween.join();
		// 次は下へ
		Thread.next(moveDown);
	}
	
	/**
	 * 下にアニメーション
	 */
	private function moveDown():Void
	{
		// TweenXThread を作成
		var tween:Thread = new TweenXThread(_shape, [{
			x:460,
			y:460,
			time:1.0,
			delay:1
		}]);
		// 開始
		tween.start();
		// 終了を待つ
		tween.join();
		// 次は左へ
		Thread.next(moveLeft);
	}
	
	/**
	 * 左にアニメーション
	 */
	private function moveLeft():Void
	{
		// TweenXThread を作成
		var tween:Thread = new TweenXThread(_shape, [{
			x:10,
			y:460,
			time:1.0,
			ease:EaseX.linear
		}]);
		// 開始
		tween.start();
		// 終了を待つ
		tween.join();
		// 次は上へ
		Thread.next(moveUp);
	}
	
	/**
	 * 上にアニメーション
	 */
	private function moveUp():Void
	{
		// TweenXThread を作成
		var tween:Thread = new TweenXThread(_shape, [{
			x:10,
			y:10,
			time:1.0
		}]);
		// 開始
		tween.start();
		// 終了を待つ
		tween.join();
		// 次は右へ
		Thread.next(moveRight);
	}
}
