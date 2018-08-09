/**
 * マルチスレッド系統
 */

//スレッド数
final int THREAD_NUM = 4;

//1フレーム分の描画が完了したThread数
int renderedThreadNum = 0;

/**
 * サブスレッド
 */
class RenderThread implements Runnable
{
  int startY;
  int height;
  boolean runningPathTracing;
  
  RenderThread(int y, int height, boolean runningPathTracing)
  {
    this.startY = y;
    this.height = height;
    this.runningPathTracing = runningPathTracing;
  }
  
  /**
   * サブスレッドで実行する関数
   */
  public void run()
  {
    int offset = this.startY * width;
    int max = (this.startY + this.height) * width;

    if(runningPathTracing)
    {
      for(int i=offset; i<max; i++)
      {
        renderingPixels[i] = pathTracing.drawPixel(i%width, i/width);
      }
    }
    else
    {
      for(int i=offset; i<max; i++)
      {
        renderingPixels[i] = raymarching.drawPixel(i%width, i/width);
      }
    }
    renderedThreadNum++;
  }
}
