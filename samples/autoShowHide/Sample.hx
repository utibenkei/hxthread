
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

/**
 * このサンプルでは「ロールオーバーするとフェードしながら現れて、しばらくマウスを動かさずに放っておくか、
 * ロールアウトするとフェードしながら消える、よくあるアレ」をスレッドを使って実現します。
 */
@:meta(SWF(width=300,height=300,frameRate=30,backgroundColor=0xffffff))

class Sample extends Sprite
{
	public function new()
	{
		super();
		// スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
		// Thread#initialize には、IThreadExecutor のインスタンスを渡します
		// ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
		Thread.initialize(new EnterFrameThreadExecutor());
		
		// ターゲットとなるシェイプを作ります
		var border:DisplayObject = createBorder();
		var shape:Sprite = createShape();
		shape.x = border.x = 100;
		shape.y = border.y = 105;
		
		// シェイプをコントロールするためのスレッドを起動します
		new AutoShowHideThread(shape).start();
	}
	
	private function createShape():Sprite
	{
		var sprite:Sprite = new Sprite();
		
		sprite.graphics.beginFill(0x000000);
		sprite.graphics.drawRect(0, 0, 100, 100);
		sprite.graphics.endFill();
		
		addChild(sprite);
		
		return sprite;
	}
	
	private function createBorder():DisplayObject
	{
		var shape:Shape = new Shape();
		
		shape.graphics.lineStyle(2, 0xcccccc);
		shape.graphics.drawRect(0, 0, 100, 100);
		
		addChild(shape);
		
		return shape;
	}
}
