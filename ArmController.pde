import controlP5.*; // GUIのライブラリ
import processing.serial.*; // シリアル通信用

Serial port; // ポート
ControlP5 cp5; // GUI用
Slider slider; // スライダ
Button grab,release,up,down,right,left; // ボタン
Toggle[] toggle = new Toggle[5]; // トグルスイッチ

int delta = 12; // サーボの角度の更新量
int[] pos = {512,512,512,512,512}; // サーボの角度
int[] center = {512,512,512,512,512}; // アームの直立姿勢時の角度
boolean[] toggleState = {true,true,true,true,true}; // 動かすモータを決めるトグルスイッチの状態

String[] com = Serial.list(); // ポートのリスト

void setup()
{
  size(700,700); // ウインドウのサイズ

  // 接続できるポートを探して接続
  for (int i=0; i < com.length ; i++)
  {
    print(com[i]+"     ");
    try {
      port = new Serial(this, com[i], 9600); // シリアル通信の開始
      println("connected!");
    }
    catch(Exception e)
    {
      println("failed");
      continue;
    }
  }  

  cp5 = new ControlP5(this);

  // 直立姿勢にするボタン
  cp5.addButton("moveCenter")
     .setLabel("Move to Center")
     .setPosition(300,height-150)
     .setSize(100,100);

  // posの確認用
  cp5.addButton("checkArray")
     .setLabel("Check Array")
     .setPosition(100,height-150)
     .setSize(100,100);

  // 掴むボタン
  grab = cp5.addButton("grab")
            .setLabel("grab")
            .setPosition(width-200,50)
            .setSize(200,200);

  // 離すボタン
  release = cp5.addButton("release")
            .setLabel("release")
            .setPosition(width-200,height-350)
            .setSize(200,200);

  // 上ボタン
  up = cp5.addButton("up")
            .setLabel("UP")
            .setPosition(200,50)
            .setSize(100,200);

  // 下ボタン
  down = cp5.addButton("down")
            .setLabel("DOWN")
            .setPosition(200,height-350)
            .setSize(100,200);

  // 右ボタン
  right = cp5.addButton("right")
            .setLabel("RIGHT")
            .setPosition(300,250)
            .setSize(200,100);

  // 左ボタン
  left = cp5.addButton("left")
            .setLabel("LEFT")
            .setPosition(0,250)
            .setSize(200,100);

  // 動かすモータを決めるトグルスイッチ
  for(int i = 0; i < 5; i++)
  {
    toggle[i] = cp5.addToggle(str(i+1))
              .setLabel(str(i+1))
              .setPosition(10, 400 + 45*i)
              .setValue(true)
              .setSize(40, 30);
  }

  // 角度の初期化
  moveCenter();
  
  // データの送信
  send();
}

void draw()
{
  background(0);

  // トグルの状態を取得
  for(int i = 0; i < toggle.length; i++)
  {
    toggleState[i] = toggle[i].getBooleanValue();
  }

  // サーボ1が有効のとき
  if(toggleState[0])
  {
    // 右ボタンが押されたとき
    if(right.isPressed())
    {
      if(pos[0] > 0)
        pos[0] -= delta;
    }

    // 左ボタンが押されたとき
    if(left.isPressed())
    {      
      if(pos[0] < 1023)
        pos[0] += delta;
    }
  }

  // 上ボタンが押されたとき
  if(up.isPressed())
  {
    for(int i = 1; i < 4; i++)
    {
      // サーボが有効で角度が1023より小さいとき
      if(pos[i] < 1023 && toggleState[i])
        pos[i] += delta;
    }
  }

  // 下ボタンが押されたとき
  if(down.isPressed())
  {
    for(int i = 1; i < 4; i++)
    {
      // サーボが有効で角度が0より大きいとき
      if(pos[i] > 0 && toggleState[i])
        pos[i] -= delta;
    }
  }

  // サーボ5が有効のとき
  if(toggleState[4])
  {
    // 掴むボタンが押されたとき
    if(grab.isPressed())
    {
      if(pos[pos.length-1] < 1024)
        pos[pos.length-1] += 30;
    }

    // 離すボタンが押されたとき
    if(release.isPressed())
    {
      if(pos[pos.length-1] >= 512)
        pos[pos.length-1] -= 30;
    }
  }

  correct(); // 値の補正
  send(); // Arduinoへのデータの送信
  delay(100);
}

// アームを直立姿勢にする
void moveCenter()
{
  for(int i = 0; i < center.length; i++)
  {
    pos[i] = center[i];
  }
}

// データ送信
// シリアル通信では8ビットずつデータが送られるため，角度はそのまま送れない
// 角度を8ビットの範囲に変換送信
void send()
{
  port.write(255); // フラグの送信

  // データの送信
  for(int i = 0; i < pos.length; i++)
  {
    int data = int(map(pos[i],0,1023,0,254)); // データの変換
    port.write(data);    
  }
}


// posの確認
void checkArray()
{
  for(int elem:pos)
  {
    int data = int(map(elem,0,1023,0,254));
    println(elem,data,int(map(data,0,254,0,1023)));
  }
}

// サーボの角度を範囲内に補正
void correct()
{
  for(int i = 0; i < pos.length; i++)
  {
    if(pos[i] < 0)
      pos[i] = 0;

    if(pos[i] > 1023)
      pos[i] = 1023;
  }
}
