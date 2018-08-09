/**
 * レイ系統
 */

//極小値の定義
final float EPSILON = 0.001;

/**
 * レイ
 */
class Ray
{
  Vector origin; //発射点
  Vector dir; //方向
  
  Ray(Vector origin, Vector dir)
  {
    this.dir = dir.normalize();
    this.origin = origin.add(this.dir.scale(EPSILON));
  }
}
