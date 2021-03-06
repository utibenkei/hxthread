/*
 * Haxe port of ActionScript Thread Library
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2014 utibenkei
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
package org.libspark.thread.threads.tweenx;


import flash.display.DisplayObject;
import org.libspark.thread.IMonitor;
import org.libspark.thread.Monitor;
import org.libspark.thread.Thread;
import tweenx909.TweenX;


/**
 * TweenX を実行するためのスレッドです.
 * 
 * <p>スレッドが開始されると、コンストラクタで指定されたターゲットと引数を用いて TweenX の実行を開始し、
 * トゥイーンが終了するとスレッドの実行も終了します。</p>
 * 
 * <p>スペシャルプロパティとして、以下のプロパティが拡張されています。</p>
 * <ul>
 * <li>show: true にすると、トゥイーン開始時に visible プロパティを true にします</li>
 * <li>hide: true にすると、トゥイーン終了時に visible プロパティを false にします</li>
 * </ul>
 * 
 * @author	utibenkei
 */
class TweenXThread extends Thread
{
	public var time(get, never):Int;

	/**
	 * 新しい TweenXThread クラスのインスタンスを作成します.
	 * 
	 * @param	target	TweenX に渡す、トゥイーンのターゲット
	 * @param	args	TweenX に渡す、トゥイーンの引数。複数渡すと、全てを連続して実行します
	 */
	public function new(target:Dynamic, args:Array<Dynamic>)
	{
		super();
		_target = target;
		_args = args;
		_specialArgs = splitSpecialArgs(args);
		_startTime = 0;
		_monitor = new Monitor();
	}
	
	private var _target:Dynamic;
	private var _args:Array<Dynamic>;
	private var _specialArgs:Dynamic;
	private var _startTime:UInt;
	private var _monitor:IMonitor;
	private var _currentTween:TweenX;
	
	/**
	 * トゥイーンが開始されてからの経過時間を返します.
	 * 
	 * <p>まだトゥイーンが開始されていない場合は 0 を返します。</p>
	 */
	private function get_time():UInt
	{
		return (_startTime != 0) ? Math.round(haxe.Timer.stamp() * 1000) - _startTime : 0;
	}
	
	/**
	 * トゥイーンの実行をキャンセルします.
	 * 
	 * <p>トゥイーンのキャンセルは、 _currentTween.stop() の呼び出しによって実現されます。</p>
	 */
	public function cancel():Void
	{
		interrupt();
	}
	
	/**
	 * @private
	 */
	private function splitSpecialArgs(args:Dynamic):Dynamic
	{
		var result:Dynamic = { };
		
		moveSpecialArg("show", args, result);
		moveSpecialArg("hide", args, result);
		moveSpecialArg("delay", args, result);
		moveSpecialArg("time", args, result);
		moveSpecialArg("ease", args, result);
		
		return result;
	}
	
	/**
	 * @private
	 */
	private function moveSpecialArg(name:String, from:Dynamic, to:Dynamic):Void
	{
		if (Reflect.hasField(from, name)) {
			Reflect.setField(to, name, Reflect.field(from, name));
			Reflect.deleteField(from, name);
		}
	}
	
	/**
	 * @private
	 */
	override private function run():Void
	{
		if (_args.length == 0) {
			return;
		}
		
		_startTime = Math.round(haxe.Timer.stamp() * 1000);
		
		_monitor.wait();
		Thread.interrupted(interruptedHandler);
		
		nextTween();
	}
	
	/**
	 * @private
	 */
	private function nextTween():Void
	{
		if (_args.length == 0) {
			_monitor.notifyAll();
			return;
		}
		
		var a:Dynamic = _args.shift();
		var delay:Float = TweenX.defaultDelay;
		var time:Float = TweenX.defaultTime;
		var ease:Float->Float = TweenX.defaultEase;
		
		_specialArgs = splitSpecialArgs(a);
		
		if (Reflect.hasField(_specialArgs, "show") && (_specialArgs.show == true)) {
			if (Std.is(_target, DisplayObject)) {
				cast((_target), DisplayObject).visible = true;
			}
			else {
				if (Reflect.hasField(_target, "visible")) {
					_target.visible = true;
				}
			}
		}
		
		if (Reflect.hasField(_specialArgs, "delay")) {
			delay = _specialArgs.delay;
		}
		
		if (Reflect.hasField(_specialArgs, "time")) {
			time = _specialArgs.time;
		}
		
		if (Reflect.hasField(_specialArgs, "ease")) {
			ease = _specialArgs.ease;
		}
		
		_currentTween = TweenX.to(_target, a).delay(delay).time(time).ease(ease).onFinish(completeHandler);
	}
	
	/**
	 * @private
	 */
	private function completeHandler():Void
	{
		if (Reflect.hasField(_specialArgs, "hide") && (_specialArgs.hide == true)) {
			if (Std.is(_target, DisplayObject)) {
				cast((_target), DisplayObject).visible = false;
			}
			else {
				if (Reflect.hasField(_target, "visible")) {
					_target.visible = false;
				}
			}
		}
		
		nextTween();
	}
	
	/**
	 * @private
	 */
	private function interruptedHandler():Void
	{
		if (_currentTween != null && _currentTween.playing) {
			_currentTween.stop();
		}
	}
}

