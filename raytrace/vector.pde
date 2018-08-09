/**
 * ベクトルおよび汎用算術系
 * 参考：http://www.shaderific.com/glsl-functions
 */


/**
 * 算術関数追加クラス
 */
class MathPlus
{
  /**
   * Floored Divisionによる剰余演算（GLSLではこの実装のため追加）
   */
  float mod(float x, float y)
  {
    return x - y*floor(x/y);
  }
}
MathPlus math = new MathPlus();


/**
 * 3次元ベクトル
 */
class Vector {
  float x, y, z;
  Vector(float x, float y, float z) 
  {
    this.x = x;
    this.y = y;
    this.z = z;
  }
  Vector(float xyz)
  {
    this.x = xyz;
    this.y = xyz;
    this.z = xyz;
  }
  
  /**
   * 文字列化
   */
  String toString() 
  {
    return "Vector("+this.x+", "+this.y+", "+this.z+")";
  }
  
  /**
   * 加算
   */
  Vector add(Vector v) 
  {
    return new Vector(this.x+v.x, this.y+v.y, this.z+v.z);
  }
  
  /**
   * 減算
   */
  Vector sub(Vector v)
  {
    return new Vector(this.x-v.x, this.y-v.y, this.z-v.z);
  }
  
  /**
   * スカラー倍
   */
  Vector scale(float s)
  {
    return new Vector(this.x*s, this.y*s, this.z*s);
  }
  
  /**
   * 各要素に対しての乗算
   */
  Vector mul(Vector v)
  {
    return new Vector(this.x * v.x, this.y * v.y, this.z * v.z);
  }
  
  /**
   * 各要素に対しての累乗
   */
  Vector pow(Vector v)
  {
    return new Vector((float)Math.pow(this.x, v.x), (float)Math.pow(this.y, v.y), (float)Math.pow(this.z, v.z));
  }
  
  /**
   * 各要素に対しての除算
   */
  Vector div(Vector v)
  {
    return new Vector(this.x / v.x, this.y / v.y, this.z / v.z);
  }
  
  /**
   * 逆ベクトル
   */
  Vector neg()
  {
    return new Vector(-this.x, -this.y, -this.z);
  }
  
  /**
   * 長さ
   */
  float length()
  {
    return dist(this.x, this.y, this.z, 0, 0, 0);
  }
  
  /**
   * 各要素に対しての絶対値
   */
  Vector abs()
  {
    return new Vector(Math.abs(this.x), Math.abs(this.y), Math.abs(this.z));
  }
  
  /**
   * 最大の要素を返す
   */
  float maxComp()
  {
    return Math.max(this.x, Math.max(this.y, this.z));
  }
  
  /**
   * ベクトルに対してのmax
   */
  Vector max(Vector v)
  {
    return (this.length() < v.length()) ? v : this;
  }
  
  /**
   * 正規化
   */
  Vector normalize()
  {
    return scale(1.0/length());
  }
  
  /**
   * 内積
   */
  float dot(Vector v)
  {
    return this.x*v.x + this.y*v.y + this.z*v.z;
  }
  
  /**
   * 外積
   */
  Vector cross(Vector v)
  {
    return new Vector(this.y*v.z-v.y*this.z,
                     this.z*v.x-v.z*this.x,
                     this.x*v.y-v.x*this.y);
  }
  
  /**
   * 各要素に対しての床関数
   */
  Vector floor()
  {
    return new Vector((float)Math.floor(this.x), (float)Math.floor(this.y), (float)Math.floor(this.z));
  }
  
  /**
   * 各要素に対しての剰余演算
   */
  Vector mod(Vector v)
  {
    return new Vector(math.mod(this.x, v.y), math.mod(this.y, v.y), math.mod(this.z, v.z));
  }
  
  /**
   * 反射ベクトルの算出
   */
  Vector reflect(Vector n)
  {
    return this.sub(n.scale(2*this.dot(n)));
  }
  
  /**
   * 屈折ベクトルの算出
   */
  Vector refract(Vector n, float eta)
  {
    float dot = this.dot(n);
    float d = 1.0 - sq(eta) * (1.0 - sq(dot));
    if(0 < d)
    {
      Vector a = this.sub(n.scale(dot)).scale(eta);
      Vector b = n.scale(sqrt(d));
      return a.sub(b);
    }
    return this.reflect(n);
  }
  
  /**
   * 半球状のランダムな方向を選択
   */
  Vector randomHemisphere()
  {
    Vector dir = new Vector(0.0, 0.0, 0.0);
    
    for(int i=0; i<100; i++)
    {
      dir = new Vector(
        random(-1.0, 1.0),
        random(-1.0, 1.0),
        random(-1.0, 1.0)
      );
      
      if(dir.length() < 1.0) {break;}
    }
    dir = dir.normalize();
    
    if(dir.dot(this) < 0) {dir = dir.neg();}
    
    return dir;
  }
}
