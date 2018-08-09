/**
 * シーン系統
 */

final int DEPTH_MAX = 10; //トレースの最大回数
final float VACUUM_REFRACTIVE_INDEX = 1.0; //真空中の屈折率


/**
 * シーン
 */
class Scene
{
  //交差可能オブジェクトリスト
  ArrayList<Intersectable> objList = new ArrayList<Intersectable>();
  //光源リスト
  ArrayList<Light> lightList = new ArrayList<Light>();
  Spectrum skyColor = BLACK;
  
  Scene() {}
  
  /**
   * 交差可能オブジェクトを追加
   */
  void addIntersectable(Intersectable obj)
  {
    this.objList.add(obj);
  }
  
  /**
   * 光源を追加
   */
  void addLight(Light light)
  {
    this.lightList.add(light);
  }
  
  /**
   * 空の色を設定
   */
  void setSkyColor(Spectrum c)
  {
    this.skyColor = c;
  }
  
  /**
   * 物体の表面情報から次のレイを射出する
   */
  Spectrum interactSurface(Vector rayDir, Vector p, Vector n, Material m, float eta, int depth)
  {
    float ks = m.reflective;
    float kt = m.refractive;
    
    float t = random(0.0, 1.0);
    //鏡面反射
    if(t < ks)
    {
      Vector r = rayDir.reflect(n);
      Spectrum c = trace(new Ray(p, r), depth+1);
      return c.mul(m.diffuse);
    }
    //屈折
    else if(t < ks+kt)
    {
      Vector r = rayDir.refract(n, eta);
      Spectrum c = trace(new Ray(p, r), depth+1);
      return c.mul(m.diffuse);
    }
    //拡散反射
    else
    {
      Vector r = n.randomHemisphere();
      Spectrum li = trace(new Ray(p, r), depth+1);
      
      Spectrum fr = m.diffuse.scale(1.0/PI);
      float factor = TAU * n.dot(r);
      Spectrum l = li.mul(fr).scale(factor);
      
      return l;
    }
  }
  
  /**
   * レイを射出して色を求める
   */
  Spectrum trace(Ray ray, int depth)
  {
    //トレースが最大回数に達した場合は計算を中断する
    if(DEPTH_MAX < depth) {return BLACK;}
    
    //交点を求める
    Intersection isect = findNearestIntersection(ray);
    if(!isect.hit()) {return this.skyColor;}
    
    Material m = isect.material;
    float dot = isect.n.dot(ray.dir);
    
    //物体外部からレイが侵入する場合
    if(dot < 0)
    {
      Spectrum col = interactSurface(ray.dir, isect.p, isect.n, m, VACUUM_REFRACTIVE_INDEX / m.refractiveIndex, depth);
      return col.add(m.emissive.scale(-dot));
    }
    //物体内部からレイが出て行く場合
    else
    {
      return interactSurface(ray.dir, isect.p, isect.n.neg(), m, m.refractiveIndex / VACUUM_REFRACTIVE_INDEX, depth);
    }
  }
  
  /**
   * 最も近いレイの交差点情報を交差可能オブジェクトリストから見つける
   */
  Intersection findNearestIntersection(Ray ray)
  {
    Intersection isect = new Intersection();
    //シーンに存在する全てのオブジェクトを走査
    for(int i = 0; i<this.objList.size(); i++)
    {
      Intersectable obj = this.objList.get(i);
      Intersection tisect = obj.intersect(ray);
      if(tisect.t < isect.t) {isect = tisect;}
    }
    return isect;
  }
}
