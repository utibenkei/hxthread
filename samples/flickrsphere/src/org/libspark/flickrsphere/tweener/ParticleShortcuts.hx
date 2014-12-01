/*
 * Flickr Sphere (Sample of the ActionScript Thread Library)
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
package org.libspark.flickrsphere.tweener;


import caurina.transitions.Tweener;
import org.papervision3d.core.geom.renderables.Particle;

/**
	 * ParticleShortcuts クラスは、Particle のための Tweener スペシャルプロパティを定義します.
	 */
class ParticleShortcuts
{
    public static function initialize() : Void
    {
        Tweener.registerSpecialProperty("particleScale", getParticleScale, setParticleScale);
    }
    
    private static function getParticleScale(obj : Dynamic, param : Array<Dynamic>, extra : Dynamic = null) : Float
    {
        var p : Particle = try cast(obj, Particle) catch(e:Dynamic) null;
        if (p != null && p.userData != null) {
            return p.userData.data["scale"];
        }
        return NaN;
    }
    
    private static function setParticleScale(obj : Dynamic, value : Float, param : Array<Dynamic>, extra : Dynamic = null) : Void
    {
        var p : Particle = try cast(obj, Particle) catch(e:Dynamic) null;
        if (p != null && p.userData != null) {
            p.userData.data["scale"] = value;
        }
    }

    public function new()
    {
    }
}
