# Noccaro Flutter MVP (Mock-first)

Noccaro の Flutter モバイルアプリ MVP 実装です。  
現時点ではバックエンド未接続で、ローカル Mock/Stub データで主要フローを動作させています。

## 実装済み（モック）

- 認証: メール登録 / ログイン / ログアウト
- スペース参加: `space_code` 入力、承認待ち (`pending`) / 自動承認 (`active`) の分岐
- ホーム: 参加状態表示、機能導線
- 投稿: 一覧 / 詳細 / リアクション
- ウィスパー: 30文字制限、位置許可フロー（モック）、作成 / 一覧 / 通報
- 設定: 通知トグル（モック）、メンバー状態デバッグ切り替え
- ルーティングガード: 未認証・未参加・pending・blocked を反映

## モック用スペースコード

- `NOC2026`: 承認制（参加後に pending）
- `AUTO2026`: 自動承認（参加後に active）

## 技術スタック

- Flutter / Dart 3
- Riverpod
- go_router
- Dio
- flutter_secure_storage
- shared_preferences
- google_maps_flutter（MVPではプレースホルダ表示をデフォルト）
- firebase_messaging（MVPではモック通知サービス）

## 開発コマンド

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## 注意

- API 連携部分は今後 backend 契約確定後に差し替え前提です。
- 位置情報の表示座標は「サーバーが丸めた座標を描画する」前提を守るよう、ローカルモックでも丸め処理を模擬しています。
- `Google Maps API key` や Firebase 設定ファイルは `.gitignore` で除外しています。
