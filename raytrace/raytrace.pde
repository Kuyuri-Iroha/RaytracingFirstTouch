/**
 * raytrace.pde
 * Kuyuri Iroha
 */

//パストレーシングオブジェクト
PathTracing pathTracing = new PathTracing();
//レイマーチングオブジェクト
Raymarching raymarching = new Raymarching();

//パストレーシングとレイマーチングの切り替え用
boolean runningPathTracing = false;
boolean isSwitchRequest = false;
void resetAlgorithm(boolean pathT)
{
  runningPathTracing = pathT;
  pathTracing.init();
  raymarching.init();
}

//スレッド間の競合状態を防ぐために描画中ピクセルを別で用意
Spectrum[] renderingPixels;

//描画スレッド
ArrayList<Thread> renderer = new ArrayList<Thread>();

/**
 * サブスレッドの起動
 */
void launchSubthread()
{
  renderedThreadNum = 0;
  renderer.clear();
  for(int i=0; i<THREAD_NUM; i++)
  {
    renderer.add(new Thread(new RenderThread(height/THREAD_NUM*i, height/THREAD_NUM, runningPathTracing)));
  }
  for(int i=0; i<renderer.size(); i++)
  {
    renderer.get(i).start();
  }
}


//描画時間計測用
final boolean DEBUG = false; //デバッグモードで実行するか
int sumUppedTime = 0;
int timeCount = 0;
int renderingTimePerFrame = 0;
boolean atFirst = true;
void updateTimeForDebug(boolean atFirst)
{
  if(atFirst)
  {
    sumUppedTime = 0;
    timeCount = 0;
  }
  else
  {
    sumUppedTime += millis() - renderingTimePerFrame;
    timeCount++;
    println("経過時間: "+sumUppedTime/timeCount+"ms");
  }
  renderingTimePerFrame = millis();
}


/**
 * 初期化
 */
void setup()
{
  size(500, 500);
  renderingPixels = new Spectrum[width*height];
  for(int i=0; i<renderingPixels.length; i++)
  {
    renderingPixels[i] = new Spectrum(0.0);
  }
  resetAlgorithm(true);
  
  //サブスレッド起動
  launchSubthread();
}


/**
 * メインループ
 */
synchronized void draw()
{
  //全てのサブスレッドで描画が完了したら
  if(renderedThreadNum == THREAD_NUM)
  {
    if(runningPathTracing)
    {
      pathTracing.addSample();
    }
    else
    {
      raymarching.updateMarchingPixels();
    }
    
    if(DEBUG)
    {
      updateTimeForDebug(atFirst);
      atFirst = false;
    }
    
    if(isSwitchRequest)
    {
      resetAlgorithm(!runningPathTracing);
      isSwitchRequest =false;
    }
    
    //サブスレッドの再起動
    launchSubthread();
  }
  
  //描画
  if(runningPathTracing)
  {
    pathTracing.draw();
  }
  else
  {
    raymarching.draw();
  }
}


/**
 * キー検出
 */
void keyPressed()
{
  if(key == 't')
  {
    isSwitchRequest = true;
  }
  
  if(key == CODED)
  {
    if(keyCode == UP)
    {
      pathTracing.switchTime(true);
    }
    else if(keyCode == DOWN)
    {
      pathTracing.switchTime(false);
    }
  }
}
