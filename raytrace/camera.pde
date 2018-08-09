/**
 * カメラ制御系統
 */
class Camera
{
  Vector eye,   //視点
         origin,//投影面の左上
         xAxis, //投影面のX軸
         yAxis; //投影面のY軸
  
  /**
   * 垂直画角で投影面を定義
   */
  void lookAt(Vector eye, Vector target, Vector up, float fov, int width, int height)
  {
    this.eye = eye;
    float imagePlane = (height/2) / tan(fov/2);
    Vector v = target.sub(eye).normalize();
    xAxis = v.cross(up).normalize();
    yAxis = v.cross(xAxis);
    Vector center = v.scale(imagePlane);
    this.origin = center.sub(xAxis.scale(0.5*width))
                        .sub(yAxis.scale(0.5*height));
  }
  
  /**
   * スクリーン座標からレイを作成
   */
  Ray ray(float x, float y)
  {
    Vector p = origin.add(xAxis.scale(x)).add(yAxis.scale(y));
    Vector dir = p.normalize();
    return new Ray(eye, dir);
  }
}
