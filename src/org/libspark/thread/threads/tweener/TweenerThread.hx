/*
 * ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2008 BeInteractive! (www.be-interactive.org) and
 *                    Spark project  (www.libspark.org)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package org.libspark.thread.threads.tweener;


import caurina.transitions.Tweener;
import flash.display.DisplayObject;
import org.libspark.thread.IMonitor;
import org.libspark.thread.Monitor;
import org.libspark.thread.Thread;


/**
	 * Tweener を実行するためのスレッドです.
	 * 
	 * <p>スレッドが開始されると、コンストラクタで指定されたターゲットと引数を用いて Tweener の実行を開始し、
	 * トゥイーンが終了するとスレッドの実行も終了します。</p>
	 * 
	 * <p>スペシャルプロパティとして、以下のプロパティが拡張されています。</p>
	 * <ul>
	 * <li>show: true にすると、トゥイーン開始時に visible プロパティを true にします</li>
	 * <li>hide: true にすると、トゥイーン開始時に visible プロパティを false にします</li>
	 * </ul>
	 * 
	 * @author	yossy:beinteractive
	 */
class TweenerThread extends Thread
{
    public var time(get, never) : Int;

    /**
		 * 新しい TweenerThread クラスのインスタンスを作成します.
		 * 
		 * @param	target	Tweener に渡す、トゥイーンのターゲット
		 * @param	args	Tweener に渡す、トゥイーンの引数
		 */
    public function new(target : Dynamic, args : Dynamic)
    {
        super();
        _target = target;
        _args = args;
        _specialArgs = splitSpecialArgs(args);
        _startTime = 0;
        _monitor = new Monitor();
        
        args.onComplete = completeHandler;
    }
    
    private var _target : Dynamic;
    private var _args : Dynamic;
    private var _specialArgs : Dynamic;
    private var _startTime : Int;
    private var _monitor : IMonitor;
    
    /**
		 * トゥイーンが開始されてからの経過時間を返します.
		 * 
		 * <p>まだトゥイーンが開始されていない場合は 0 を返します。</p>
		 */
    private function get_time() : Int
    {
        return _startTime != (0) ? Math.round(haxe.Timer.stamp() * 1000) - _startTime : 0;
    }
    
    /**
		 * トゥイーンの実行をキャンセルします.
		 * 
		 * <p>トゥイーンのキャンセルは、 Tweener.removeTweens の呼び出しによって実現されます。</p>
		 */
    public function cancel() : Void
    {
        interrupt();
    }
    
    /**
		 * @private
		 */
    private function splitSpecialArgs(args : Dynamic) : Dynamic
    {
        var result : Dynamic = new Dynamic();
        
        moveSpecialArg("show", args, result);
        moveSpecialArg("hide", args, result);
        
        return result;
    }
    
    /**
		 * @private
		 */
    private function moveSpecialArg(name : String, from : Dynamic, to : Dynamic) : Void
    {
        if (Lambda.has(from, name)) {
            Reflect.setField(to, name, Reflect.field(from, name));
			Reflect.deleteField(from, name);
        }
    }
    
    /**
		 * @private
		 */
    override private function run() : Void
    {
        if (Lambda.has(_specialArgs, "show") && _specialArgs.show) {
            if (Std.is(_target, DisplayObject)) {
                cast((_target), DisplayObject).visible = true;
            }
            else {
                if (Lambda.has(_target, "visible")) {
                    _target.visible = true;
                }
            }
        }
        
        _startTime = Math.round(haxe.Timer.stamp() * 1000);
        
        Tweener.addTween(_target, _args);
        
        waitTween();
    }
    
    /**
		 * @private
		 */
    private function waitTween() : Void
    {
        _monitor.wait();
        interrupted(interruptedHandler);
    }
    
    /**
		 * @private
		 */
    private function completeHandler() : Void
    {
        if (Lambda.has(_specialArgs, "hide") && _specialArgs.hide) {
            if (Std.is(_target, DisplayObject)) {
                cast((_target), DisplayObject).visible = false;
            }
            else {
                if (Lambda.has(_target, "visible")) {
                    _target.visible = false;
                }
            }
        }
        
        _monitor.notifyAll();
    }
    
    /**
		 * @private
		 */
    private function interruptedHandler() : Void
    {
        if (Tweener.isTweening(_target)) {
            Tweener.removeTweens(_target);
        }
    }
}

