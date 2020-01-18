#include <ax12.h>

int flag = 0; // シリアル通信のデータ受信フラグ
int count = 0; // シリアル通信でデータを受信した回数

int pos[5] = {512,512,512,512,0}; // サーボモータの角度

void setup()
{
    Serial.begin(9600);
    delay(1000);
}

void loop()
{
    // データ受信のフラグとして255を使用
    // 255が送られてきた場合，データを受信する
    if(flag == 255)
    {
      // データが送られているかどうか確認
      if(Serial.available() > 0)
      {
        // データの読み取り
        pos[count] = Serial.read();

        // 確認用
        Serial.write(pos[count]);
        count++;
      }

      // データの受信が終わったら，受信した回数とフラグを0に戻す
      if(count >= 5)
      {
        count = 0;
        flag = 0;

        convert(); // データの変換
        setServo(); // サーボを動かす
      }
    }
    else
    {
      // フラグの読み取り
      if(Serial.available() > 0)
      {
        flag = Serial.read();
      }
    }
}

// 受信した8ビットデータを10ビットに戻す
// そこまで精度が必要ないため，上位ビットと下位ビットに分けるより
// 8ビットデータで受信して変換した方が効率が良い
void convert()
{
  for(int i = 0; i < 5; i++)
  {
    pos[i] = int(map(pos[i],0,254,0,1023));
  }
}

// サーボに角度を設定
void setServo()
{
  for(int i = 0; i < 5; i++)
  {
    SetPosition(i,pos[i]);
    delay(10);
  }
}
