/**
 * レイが交差できる物体の定義系統
 */


/**
 * 交差可能物体のインターフェイス
 */
interface Intersectable
{
  /**
   * レイとの交差判定
   */
  Intersection intersect(Ray ray);
}


/**
 * 球の形状
 */
class Sphere implements Intersectable
{
  Vector center;
  float radius;
  Material material;
  
  Sphere(Vector center, float radiuse, Material material)
  {
    this.center = center;
    this.radius = radiuse;
    this.material = material;
  }
  
  Intersection intersect(Ray ray)
  {
    Intersection isect = new Intersection();
    Vector v = ray.origin.sub(this.center);
    float b = ray.dir.dot(v);
    float c = v.dot(v) - sq(this.radius);
    float d = b * b - c;
    if(0 <= d) //交差していたら
    {
      float s = sqrt(d);
      float t = -b -s;
      if(t <= 0) {t = -b + s;}
      if(0 < t)
      {
        isect.t = t;
        isect.p = ray.origin.add(ray.dir.scale(t));
        isect.n = isect.p.sub(this.center).normalize();
        isect.material = this.material;
      }
    }
    return isect;
  }
}


/**
 * 無限平面
 */
class Plane implements Intersectable
{
  Vector n; //面法線
  float d; //原点からの距離
  Material material;
  
  Plane(Vector p, Vector n, Material material)
  {
    this.n = n.normalize();
    this.d = -p.dot(this.n);
    this.material = material;
  }
  
  Intersection intersect(Ray ray)
  {
    Intersection isect = new Intersection();
    float v = this.n.dot(ray.dir);
    float t = -(this.n.dot(ray.origin)+this.d)/v;
    if(0 < t) //交差していたら
    {
      isect.t = t;
      isect.p = ray.origin.add(ray.dir.scale(t));
      isect.n = this.n;
      isect.material = this.material;
    }
    return isect;
  }
}


/**
 * チェック柄の物体
 */
class CheckedObj implements Intersectable
{
  Intersectable obj; //ベースの物体
  float gridWidth; //チェック柄のサイズ
  Material material2; //もう１つのマテリアル
  
  CheckedObj(Intersectable obj, float gridWidth, Material material2)
  {
    this.obj = obj;
    this.gridWidth = gridWidth;
    this.material2 = material2;
  }
  
  Intersection intersect(Ray ray)
  {
    Intersection isect = obj.intersect(ray);
    if(isect.hit()) //交差したら
    {
      int i = (
        round(isect.p.x/this.gridWidth) +
        round(isect.p.y/this.gridWidth) +
        round(isect.p.z/this.gridWidth)
      );
      if(i%2 == 0)
      {
        //ベースの物体のマテリアルとは違うマテリアルを適用
        isect.material = this.material2;
      }
    }
    return isect;
  }
}
