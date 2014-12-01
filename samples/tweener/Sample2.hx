import MainThread2;

import flash.display.Sprite;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

/**
	 * このサンプルでは TweenerThread の使用方法などを学びます
	 *
	 * 詳細は MainThread を見てください
	 */
@:meta(SWF(width=500,height=500,frameRate=30))

class Sample2 extends Sprite
{
    public function new()
    {
        super();
        // スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
        // Thread#initialize には、IThreadExecutor のインスタンスを渡します
        // ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
        Thread.initialize(new EnterFrameThreadExecutor());
        
        // MainThread を起動します
        var main : MainThread2 = new MainThread2(this);
        main.start();
    }
}
