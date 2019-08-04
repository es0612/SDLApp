# SDL sample app for swift


### Description

[SDL(Smart Device Link)](https://smartdevicelink.com/)に対応したiOSアプリケーションを開発するためのサンプル


### エミュレータの準備

以下の３パターンを検討する

+ Web上のエミュレータを利用する：[Manticore](https://smartdevicelink.com/resources/manticore/)

+ Dockerイメージを利用する
  - dockerを[インストール](https://qiita.com/kurkuru/items/127fa99ef5b2f0288b81)
  - 下記コマンドを実施してコンテナ作成および実行：[参考](https://github.com/hisayan/sdl_core_docker)

  ```
  #初回のみ実行
  docker run -d -p 12345:12345 -p 8080:8080 -p 8087:8087 -p 3001:3001 --name core smartdevicelink/core:latest

  #下記URLへアクセス
  http://localhost:8080/

  #停止
  docker container stop

  #起動
  docker container start

  #確認
  docker container ls

  ```

+ Ubuntu上に環境を構築する
  - Web版は共用のため待ち時間が発生するなどする場合がある
  - Docker版は対応されていない機能などが含まれる（らしい）


### サンプルアプリでの動作確認

公式に用意されているサンプルアプリを動かしてみる：[参考](https://ascii.jp/elem/000/001/789/1789204/index-4.html)
+ コードのクローン
```
#関連するリポも含め、再帰的に取得
git clone --recursive https://github.com/smartdevicelink/sdl_ios.git
```
+ Xcodeでプロジェクトを開き、ビルドする (targetはExample-Swifwを選ぶ)
+ エミュレータで動作確認 (下記をアプリ起動時の初期画面で入力する。値はdockerの場合の例)
  - IP: localhost
  - port: 12345
+ エミュレータ画面にアプリが表示されるのでクリックして起動する


### 一からアプリを作成するサンプル

[この記事](https://ascii.jp/elem/000/001/789/1789268/)を参考にXcodeプロジェクトを作成


### Requirement for Carthage
for product
- github "Thomvis/BrightFutures"
- github "PureLayout/PureLayout"
- github

for test
- github "Quick/Quick"
- github "Quick/Nimble"
- github "derekleerock/Succinct"


### atom上でmarkDownのプレビュー
ctl+shift+m


### Licence
Copyright 2019 by Author

### Author

[hyai](https://github.com/hyai0323)
