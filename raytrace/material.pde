/**
 * マテリアル系統
 */
class Material
{
  Spectrum diffuse; //基本色
  float reflective = 0; //反射強度
  float refractive = 0; //屈折強度
  float refractiveIndex = 1; //屈折率
  Spectrum emissive = BLACK; //発光色
  
  Material(Spectrum diffuse)
  {
    this.diffuse = diffuse;
  }
}
