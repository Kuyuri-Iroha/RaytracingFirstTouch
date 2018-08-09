/**
 * 交差情報系統
 */

//無限遠の定義
final float NO_HIT = Float.POSITIVE_INFINITY;

/**
 * 交差情報
 */
class Intersection
{
  float t = NO_HIT; //レイの発射点から交差点までの距離
  Vector p; //交差点
  Vector n; //法線
  Material material; //交差点のマテリアル
  
  Intersection() {}
  
  /**
   * 交差したかどうか
   */
  boolean hit() {return this.t != NO_HIT;}
}
