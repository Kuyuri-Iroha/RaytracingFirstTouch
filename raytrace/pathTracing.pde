/**
 * パストレーシングの処理系統
 * 参考：http://raytracing.xyz
 */
class PathTracing
{
  Scene scene;
  Camera camera;
  Spectrum[] sumUppedPixels;
  int sampleNum;
  int timeIndex; //時間帯インデックス 0:昼間, 1:夕方, 2:夜
  Spectrum[] timeSkyColor;
  
  PathTracing()
  {
    scene = new Scene();
    camera = new Camera();
    timeIndex = 0;
    timeSkyColor = new Spectrum[3];
    timeSkyColor[0] = new Spectrum(0.902, 0.990, 0.982);
    timeSkyColor[1] = new Spectrum(0.937, 0.588, 0.255);
    timeSkyColor[2] = new Spectrum(0.023, 0.117, 0.255);
  }
  
  /**
   * 初期化
   */
  void init()
  {
    //サンプリングピクセルの初期化
    sumUppedPixels = new Spectrum[width*height];
    for(int i=0; i<sumUppedPixels.length; i++)
    {
      sumUppedPixels[i] = new Spectrum(0.0);
    }

    //シーンの初期化
    scene.setSkyColor(timeSkyColor[0]);

      //球
    Material mtlS1 = new Material(new Spectrum(0.7, 0.7, 0.7));
    mtlS1.reflective = 0.8;
    Material mtlS2 = new Material(new Spectrum(0.7, 0.7, 1.0));
    mtlS2.refractive = 0.8;
    mtlS2.refractiveIndex = 1.5;
    Material mtlS3 = new Material(new Spectrum(0.3, 0.9, 0.7));

    Sphere sphere1 = new Sphere(new Vector(-2.5, 0.0, 0.0), 1, mtlS1);
    Sphere sphere2 = new Sphere(new Vector(-0.5, 0.0, 0.0), 1, mtlS2);
    Sphere sphere3 = new Sphere(new Vector(1.7, 0.0, 0.0), 1, mtlS3);

    scene.addIntersectable(sphere1);
    scene.addIntersectable(sphere2);
    scene.addIntersectable(sphere3);

      //光源
    Material mtlL = new Material(new Spectrum(0.0));
    mtlL.emissive = new Spectrum(new Spectrum(30.0, 30.0, 30.0));
    scene.addIntersectable(new Sphere(
      new Vector(0.0, 4.0, 0.0),
      1,
      mtlL
    ));

      //床
    Material mtlF1 = new Material(new Spectrum(0.9));
    Material mtlF2 = new Material(new Spectrum(0.4));
    CheckedObj checkedFloor = new CheckedObj(
      new Plane(
        new Vector(0.0, -1.0, 0.0),
        new Vector(0.0, 1.0, 0.0),
        mtlF1
      ),
      1,
      mtlF2
    );

    scene.addIntersectable(checkedFloor);

    //カメラの初期化
    camera.lookAt(
      new Vector(4.0, 1.5, 6.0),
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
    Ray ray = camera.ray(
      x + random(-0.5, 0.5),
      y + random(-0.5, 0.5)
    );
    return scene.trace(ray, 0);
  }

  /**
   * 描画
   */
  void draw()
  {
     loadPixels();
     for(int i=0; i<width*height; i++)
     {
       pixels[i] = sumUppedPixels[i].scale(1.0 / sampleNum).toColor();
     }
     updatePixels();
  }

  /**
   * サンプルの追加
   */
  void addSample()
  {
    for(int i=0; i<sumUppedPixels.length; i++)
    {
      sumUppedPixels[i] = sumUppedPixels[i].add(renderingPixels[i]);
    }
    sampleNum++;
  }
  
  /**
   * サンプルのリセット
   */
   void resetSample()
   {
     for(int i=0; i<sumUppedPixels.length; i++)
     {
       sumUppedPixels[i] = new Spectrum(BLACK);
     }
     sampleNum = 0;
   }
   
   /**
    * 時間帯の切り替え
    */
   void switchTime(boolean forward)
   {
     if(forward)
     {
       timeIndex++;
     }
     else
     {
       timeIndex--;
     }
     scene.setSkyColor(timeSkyColor[abs(timeIndex%timeSkyColor.length)]);
     
     resetSample();
   }
}
