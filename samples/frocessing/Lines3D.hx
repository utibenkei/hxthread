
import flash.display.DisplayObject;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageQuality;
import flash.display.StageScaleMode;

import org.libspark.thread.Thread;
import org.libspark.thread.EnterFrameThreadExecutor;

/**
	 * このサンプルでは Frcoessing と Thread を使ってそれっぽい何かが表示されます
	 */
@:meta(SWF(width=300,height=300,frameRate=30,backgroundColor=0x333333))


import flash.display.Graphics;
import org.libspark.thread.threads.frocessing.Frocessing3DThread;

class Lines3D extends Sprite
{
    public function new()
    {
        super();
        // ステージの設定をします
        stage.scaleMode = StageScaleMode.NO_SCALE;
        stage.quality = StageQuality.MEDIUM;
        
        // スレッドを初期化します
        Thread.initialize(new EnterFrameThreadExecutor());
        
        // ターゲットとなるシェイプを作ります
        var shape : Shape = cast((addChild(new Shape())), Shape);
        
        // 開始します
        new Lines3DThread(shape.graphics).start();
    }
}



class Lines3DThread extends Frocessing3DThread
{
    public function new(target : Graphics)
    {
        super(target);
    }
    
    override private function setup() : Void
    {
        fg.size(300, 300);
        fg.noFill();
        fg.perspective(Math.PI / 2.4);
    }
    
    private var _rot : Float = 0;
    private var _c : Float = 0;
    
    override private function draw() : Void
    {
        fg.clear();
        
        fg.translate(150, 150, -150);
        
        drawLines(_rot, _c, 0.3);
        drawLines(_rot + Math.PI / 90, _c + Math.PI / 45, 0.6);
        drawLines(_rot + Math.PI / 45, _c + Math.PI / 22.5, 1.0);
        
        _rot += Math.PI / 180;
        _c += Math.PI / 90;
    }
    
    private function drawLines(rot : Float, c : Float, a : Float) : Void
    {
        fg.pushMatrix();
        fg.rotateY(rot);
        fg.rotateZ(rot / 4);
        fg.rotateX(rot / 16);
        
        var cc : Float = (Math.cos(c) + 1) / 2;
        var size : Float = (cc + 1) / 2 * 400;
        var l : Int = 12 * cc + 4;
        for (j in 0...l){
            var y : Float = (size / l * j) - (size / 2);
            var s : Float = Math.sin(Math.PI / l * j) * size / 2;
            fg.beginShape();
            fg.stroke(0xff * cc, 0x66, 0x33, a);
            for (i in 0...l + 1){
                var r : Float = Math.PI * 2 / l * (i == (l != 0) ? 0 : i);
                fg.vertex3d(Math.cos(r) * s, y, Math.sin(r) * s);
            }
            fg.endShape();
        }
        
        fg.popMatrix();
    }
}