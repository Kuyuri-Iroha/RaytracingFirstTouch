/**
 * スペクトラム系統
 */

//ガンマ補正値
final float DISPLAY_GAMMA = 2.2;

/**
 * シェーダーに感覚を近づけるために正規化した値で色を定義
 */
class Spectrum
{
  float r, g, b;
  
  Spectrum(float r, float g, float b)
  {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  Spectrum(float rgb)
  {
    this.r = rgb;
    this.g = rgb;
    this.b = rgb;
  }
  Spectrum(Spectrum original)
  {
    Spectrum o = new Spectrum(original.r, original.g, original.b);
    this.r = o.r;
    this.g = o.g;
    this.b = o.b;
  }

  /**
   * 加算合成
   */
  Spectrum add(Spectrum v)
  {
    return new Spectrum(this.r+v.r, this.g+v.g, this.b+v.b);
  }
  
  /**
   * 乗算合成
   */
  Spectrum mul(Spectrum v)
  {
    return new Spectrum(this.r*v.r, this.g*v.g, this.b*v.b);
  }
  
  /**
   * 乗算合成（スカラー）
   */
  Spectrum scale(float s)
  {
    return new Spectrum(this.r*s, this.g*s, this.b*s);
  }
  
  /**
   * 累乗
   */
  Spectrum pow(Spectrum sp)
  {
    return new Spectrum((float)Math.pow(this.r, sp.r), (float)Math.pow(this.g, sp.g), (float)Math.pow(this.b, sp.b));
  }
  
  /**
   * 0~255のRGB値に変換
   */
  color toColor()
  {
    int ir = (int)min((float)Math.pow(this.r, 1.0 / DISPLAY_GAMMA) * 255, 255);
    int ig = (int)min((float)Math.pow(this.g, 1.0 / DISPLAY_GAMMA) * 255, 255);
    int ib = (int)min((float)Math.pow(this.b, 1.0 / DISPLAY_GAMMA) * 255, 255);
    return color(ir, ig, ib);
  }
}


//黒の定義
final Spectrum BLACK = new Spectrum(0, 0, 0);
