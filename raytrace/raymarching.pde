/**
 * レイマーチングの処理系統
 * 参考：http://iquilezles.org/www/articles/menger/menger.htm
 */
class Raymarching
{
  Camera camera;
  Spectrum[] renderedPixels;
  final int MARCHING_MAX = 64;
  DirectionalLight directionalLight;
  float mengerTransParam;

  Raymarching()
  {
    camera = new Camera();
    directionalLight = new DirectionalLight(new Vector(1.0, 0.9, 0.3), new Spectrum(1.0));
    mengerTransParam = 3.0;
  }

  /**
   * ボックス形状
   */
  float sdBox(Vector p, Vector box)
  {
    Vector di = p.abs().sub(box);
    float mc = di.maxComp();
    return min(mc, di.max(new Vector(0.0)).length());
  }
  
  /**
   * 十字形状
   */
  float sdCross(Vector p)
  {
    float da = sdBox(p, new Vector(Float.POSITIVE_INFINITY, 1.0, 1.0));
    float db = sdBox(new Vector(p.y, p.z, p.x), new Vector(1.0, Float.POSITIVE_INFINITY, 1.0));
    float dc = sdBox(new Vector(p.z, p.x, p.y), new Vector(1.0, 1.0, Float.POSITIVE_INFINITY));
    return min(da, min(db, dc));
  }
  
  /**
   * 球形状
   */
  float sdSphere(Vector p, float s)
  {
    return p.length() - s;
  }

  /**
   * メンガーのスポンジ形状判定
   */
  Vector menger(Vector p)
  {
    float dist = sdBox(p, new Vector(1.0));
    Vector res = new Vector(dist, 0.0, 0.0);

    float s = 1.0;
    for(int m=0; m<4; m++) //メンガーのスポンジの精細度
    {
      Vector a = p.scale(s).mod(new Vector(2.0)).sub(new Vector(1.0));
      s *= 3.0 + (cos(mengerTransParam) + 1.0) / 2.0 * 0.95;
      Vector r = (new Vector(1.0)).sub(a.abs().scale(3.0)).abs();
      float da = max(r.x, r.y);
      float db = max(r.y, r.z);
      float dc = max(r.z, r.x);
      float c = (min(da, min(db, dc)) - 1.0) / s;
      
      if(dist < c)
      {
        dist = c;
        res = new Vector(dist, min(res.y, 0.2 * da * db * dc), (1.0 + (float)m) / 4.0);
      }
    }
    
    return res;
  }

  /**
   * 交点検出
   */
  Vector intersect(Ray ray)
  {
    float t = 0.0;
    Vector res = new Vector(-1.0);
    Vector h = new Vector(1.0);
    //マーチングループ
    for(int i=0; i<MARCHING_MAX; i++)
    {
      if(h.x < 0.002 || 10.0 < t) {break;}
      h = menger(ray.origin.add( ray.dir.scale(t) ));
      res = new Vector(t, h.y, h.z);
      t += h.x;
    }
    if(10.0 < t) {res = new Vector(-1.0, -1.0, -1.0);}
    return res;
  }

  /**
   * ソフトシャドウ
   */
  float softShadow(Vector ro, Vector rd, float mint, float k)
  {
    float res = 1.0;
    float t = mint;
    float h = 1.0;
    for(int i=0; i<8; i++)
    {
      h = menger(ro.add(rd.scale(t))).x;
      res = min(res, k*h/t);
      t += constrain(h, 0.005, 0.1);
    }
    return constrain(res, 0.0, 1.0);
  }

  /**
   * 法線算出
   */
  Vector calcNormal(Vector pos)
  {
    Vector ex = new Vector(EPSILON, 0.0, 0.0);
    Vector ey = new Vector(0.0, EPSILON, 0.0);
    Vector ez = new Vector(0.0, 0.0, EPSILON);
    Vector nor = new Vector(0.0);
    nor.x = menger(pos.add(ex)).x - menger(pos.sub(ex)).x;
    nor.y = menger(pos.add(ey)).x - menger(pos.sub(ey)).x;
    nor.z = menger(pos.add(ez)).x - menger(pos.sub(ez)).x;
    
    return nor.normalize();
  }

  /**
   * レイマーチングで色を求める
   */
  Spectrum marching(Ray ray, int x, int y)
  {
    Spectrum col = new Spectrum(map(y, 0, height, 0.01, 0.4));
    Vector t = intersect(ray);
    //ヒットチェック
    if(0.0 < t.x)
    {
      //シェーディング
      Vector pos = ray.dir.scale(t.x).add(ray.origin);
      Vector nor = calcNormal(pos);
      
      float occ = t.y;
      float shadow = softShadow(pos, directionalLight.dir, 0.01, 64.0);
      
      float diff = max(0.1  + 0.9 * nor.dot(directionalLight.dir), 0.0) * directionalLight.col.r;
      float sky = 0.5 + 0.5*nor.y;
      float bac = max(0.4 + 0.6*nor.dot(new Vector(-directionalLight.dir.x, directionalLight.dir.y, -directionalLight.dir.z)), 0.0);
      
      Spectrum shadowSp = new Spectrum(0.85);
      Spectrum skySp = new Spectrum(0.10, 0.20, 0.40);
      Spectrum bacSp = new Spectrum(1.00, 1.00, 1.00);
      Spectrum occSp = new Spectrum(0.15, 0.17, 0.20);
      
      Spectrum lin = new Spectrum(0.0);
      lin = lin.add( shadowSp.scale(diff).scale(shadow).scale(1.00) );
      lin = lin.add( skySp.scale(sky).scale(occ).scale(0.50));
      lin = lin.add( bacSp.scale(bac).scale(0.5 + 0.5 * occ).scale(0.10) );
      lin = lin.add( occSp.scale(occ).scale(0.25) );
      
      Spectrum material = new Spectrum(1.0);
      col = material.mul(lin);
    }
    
    return col;
  }

  /**
   * 初期化
   */
  void init()
  {
    //描画ピクセルの初期化
    renderedPixels = new Spectrum[width*height];
    for(int i=0; i<renderedPixels.length; i++)
    {
      renderedPixels[i] = new Spectrum(BLACK);
    }
    
    //カメラの初期化
    camera.lookAt(
      new Vector(2.0, 1.5, 4.0),
      new Vector(0.0),
      new Vector(0.0, 1.0, 0.0),
      radians(40.0),
      width,
      height
    );
  }

  /**
   * ピクセル単位の描画
   */
  Spectrum drawPixel(int x, int y)
  {
    Ray ray = camera.ray(x, y);
    return marching(ray, x, y);
  }

  /**
   * 描画
   */
  void draw()
  {
    loadPixels();
    for(int i=0; i<width*height; i++)
    {
      pixels[i] = renderedPixels[i].toColor();
    }
    updatePixels();
  }

  /**
   * 描画ピクセルの更新
   */
  void updateMarchingPixels()
  {
    for(int i=0; i<width*height; i++)
    {
      renderedPixels[i] = new Spectrum(renderingPixels[i]);
    }
    mengerTransParam += 0.5;
  }
}
