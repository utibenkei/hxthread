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
package org.libspark.flickrsphere.pv3d;


import flash.display.BitmapData;
import flash.display.Graphics;
import flash.geom.Matrix;
import org.papervision3d.materials.special.ParticleMaterial;
import org.papervision3d.core.geom.renderables.Particle;
import org.papervision3d.core.render.data.RenderSessionData;
import org.papervision3d.core.render.draw.IParticleDrawer;

/**
	 * ScalableBitmapParticleMaterial クラスは、Particle クラスの userData['scale'] を用いて、パーティクルの拡大縮小を可能にした
	 * BitmapParticleMaterial です.
	 */
class ScalableBitmapParticleMaterial extends ParticleMaterial implements IParticleDrawer
{
    
    private var scaleMatrix : Matrix;
    
    public function new(bitmap : BitmapData)
    {
        super(0, 0);
        this.bitmap = bitmap;
        this.scaleMatrix = new Matrix();
    }
    
    override public function drawParticle(particle : Particle, graphics : Graphics, renderSessionData : RenderSessionData) : Void
    {
        var scale : Float = ((particle.userData != null && Lambda.has(particle.userData.data, "scale"))) ? particle.userData.data["scale"] : 1.0;
        scaleMatrix.a = particle.renderScale * scale;
        scaleMatrix.d = particle.renderScale * scale;
        scaleMatrix.tx = particle.vertex3D.vertex3DInstance.x;
        scaleMatrix.ty = particle.vertex3D.vertex3DInstance.y;
        graphics.beginBitmapFill(bitmap, scaleMatrix, false, smooth);
        graphics.drawRect(particle.vertex3D.vertex3DInstance.x, particle.vertex3D.vertex3DInstance.y, particle.renderScale * particle.size * scale, particle.renderScale * particle.size * scale);
        graphics.endFill();
        renderSessionData.renderStatistics.particles++;
    }
}
