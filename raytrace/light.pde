/**
 * 光源系統
 */


/**
 * 点光源
 */
class Light
{
  Vector pos; //光源位置
  Spectrum power; //光の強度
  
  Light(Vector pos, Spectrum power)
  {
    this.pos = pos;
    this.power = power;
  }
}

/**
 * 平行光源
 */
class DirectionalLight
{
  Vector dir; //方向
  Spectrum col; //光の色
  
  DirectionalLight(Vector dir, Spectrum col)
  {
    this.dir = dir.normalize();
    this.col = col;
  }
}
