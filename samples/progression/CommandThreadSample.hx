
import flash.display.Sprite;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

/**
	 * このサンプルでは CommandThread を利用して、 Progression のコマンドをスレッドを組み込んで使う方法を学びます。
	 */

import jp.progression.commands.SerialList;
import jp.progression.commands.Trace;
import jp.progression.commands.Wait;
import jp.progression.core.commands.Command;

import org.libspark.thread.threads.progression.CommandThread;

class CommandThreadSample extends Sprite
{
    public function new()
    {
        super();
        // スレッドを実行するには、まずはじめに Thread#initialize をコールし、スレッドライブラリを初期化します
        // Thread#initialize には、IThreadExecutor のインスタンスを渡します
        // ここでは EnterFrameExecutor を渡し、毎フレームスレッドが実行されるようにします
        Thread.initialize(new EnterFrameThreadExecutor());
        
        // サンプルのスレッドを実行
        new CommandThreadSampleThread().start();
    }
}



class CommandThreadSampleThread extends Thread
{
    override private function run() : Void
    {
        trace("Command の実行を開始します");
        
        // コマンドを実行するためのスレッドを生成
        var t : Thread = new CommandThread(
        // コマンドを順番に実行します
        new SerialList(null, 
        // 「コマンドその1」 を出力
        new Trace("コマンドその1"), 
        // 1秒待つ
        new Wait(1000), 
        // 「コマンドその2」を出力
        new Trace("コマンドその2"), 
        ), 
        );
        
        // スレッドを開始
        t.start();
        // 終了するまで待つ
        t.join();
        // 次
        next(run2);
    }
    
    private function run2() : Void
    {
        trace("Command の実行が完了しました");
        trace("次の Command の実行を開始します");
        
        // コマンドを実行するためのスレッドを生成
        var t : Thread = new CommandThread(
        // このコマンドはタイムアウトして例外を発生する
        new Command(function() : Void
        {
            
        }, null, {
            timeOut : 1000

        }), 
        );
        
        // スレッドを開始
        t.start();
        // 終了するまで待つ
        t.join();
        // 例外ハンドラ
        error(Dynamic, errorHandler);
        // 次
        next(run3);
    }
    
    private function errorHandler(e : Dynamic, t : Thread) : Void
    {
        trace("例外が発生しました: " + Std.string(e));
    }
    
    private function run3() : Void
    {
        trace("次の Command の実行が完了しました");
        trace("おわります");
    }

    public function new()
    {
        super();
    }
}