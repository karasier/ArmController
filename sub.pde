import controlP5.*; // GUIのライブラリ
import processing.serial.*; // シリアル通信用

Serial port; // ポート
ControlP5 cp5; // GUI用
Slider slider; // スライダ
Button grab,release,up,down,right,left; // ボタン
Toggle[] toggle = new Toggle[5]; // トグルスイッチ

int delta = 12; // サーボの角度の更新量
int[] pos = {512,512,512,512,0}; // サーボの角度
int[] center = {512,512,512,512,0}; // アームの直立姿勢時の角度
int[] pos2 = {512,512,1000,216,0};
boolean[] toggleState = {true,true,true,true,true}; // 動かすモータを決めるトグルスイッチの状態

String[] com = Serial.list();

void setup()
{
  size(700,700);

  // 接続できるポートを探して接続
  for (int i=0; i < com.length ; i++)
  {
    print(com[i]+"     ");
    try {
      port = new Serial(this, com[i], 9600);
      println("connected!");
    }
    catch(Exception e)
    {
      println("failed");
      continue;
    }
  }
  //port = new Serial(this, "COM20", 9600);

  cp5 = new ControlP5(this);

  // 直立姿勢にするボタン
  cp5.addButton("pose1")
     .setLabel("pose 1")
     .setPosition(width/2-200,height/2)
     .setSize(100,100);

  // posの確認用
  cp5.addButton("pose2")
     .setLabel("pose 2")
     .setPosition(width/2+200,height/2)
     .setSize(100,100);

  // 初期化
}

void draw()
{
  background(0);
  delay(100);
}

// アームを直立姿勢にする
void pose1()
{
  for(int i = 0; i < center.length; i++)
  {
    pos[i] = center[i];
  }
  correct(); // 値の補正
  send(); // Arduinoへのデータの送信
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
    println(data);
  }

  // 確認用
  println("sent!");
}


// ポーズ2
void pose2()
{
  for(int i = 0; i < center.length; i++)
  {
    pos[i] = pos2[i];
  }
  correct(); // 値の補正
  send(); // Arduinoへのデータの送信
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

// 正しいデータが送信できたか確認
void serialEvent(Serial p){
  int x = p.read();
  println(int(map(x,0,254,0,1023)));
}
