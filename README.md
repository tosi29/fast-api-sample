# FastAPI Sample for AWS Lambda

uvとTerraformを使用したFastAPIサンプルアプリケーションです。AWS Lambdaで動作し、API Gateway経由でアクセスできます。

## 🏗️ アーキテクチャ

- **FastAPI**: Python Web API フレームワーク
- **uv**: 高速なPythonパッケージマネージャー
- **Mangum**: FastAPIをAWS Lambda用に変換するASGIアダプター
- **Terraform**: インフラストラクチャのコード管理
- **AWS Lambda**: サーバーレス実行環境
- **API Gateway**: RESTful API エンドポイント

## 📁 プロジェクト構成

```
fast-api-sample/
├── src/
│   ├── main.py              # FastAPIアプリケーション
│   ├── lambda_handler.py    # Lambda用ハンドラー
│   ├── models.py           # データモデル
│   └── __init__.py
├── terraform/
│   ├── main.tf             # AWSリソース定義
│   ├── variables.tf        # 変数定義
│   └── outputs.tf          # 出力定義
├── scripts/
│   ├── build.sh            # ビルドスクリプト
│   └── deploy.sh           # デプロイスクリプト
├── pyproject.toml          # プロジェクト設定
└── .python-version         # Pythonバージョン
```

## 🚀 API エンドポイント

| メソッド | パス | 説明 |
|---------|------|------|
| GET | `/` | ヘルスチェック |
| GET | `/items` | 全アイテム取得 |
| GET | `/items/{item_id}` | 指定IDのアイテム取得 |
| POST | `/items` | 新規アイテム作成 |

## 🛠️ セットアップ

### 前提条件

- Python 3.9+
- uv (Python パッケージマネージャー)
- Terraform 1.0+
- AWS CLI 設定済み

### インストール

1. **uvのインストール**
   ```bash
   curl -LsSf https://astral.sh/uv/install.sh | sh
   ```

2. **プロジェクトのクローン**
   ```bash
   git clone <repository-url>
   cd fast-api-sample
   ```

3. **依存関係のインストール**
   ```bash
   uv sync
   ```

## 🧪 ローカル開発

```bash
# 開発用サーバーの起動
uv run uvicorn src.main:app --reload

# API確認
curl http://localhost:8000/
curl http://localhost:8000/items
```

## 🚀 デプロイ

### 1. ビルド

```bash
./scripts/build.sh
```

### 2. デプロイ

```bash
./scripts/deploy.sh [environment] [aws-region]
```

例:
```bash
./scripts/deploy.sh dev ap-northeast-1
```

### 3. API テスト

デプロイ後、出力されるAPI Gateway URLを使用してテストできます:

```bash
# ヘルスチェック
curl https://xxxxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/dev/

# アイテム一覧取得
curl https://xxxxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/dev/items

# 特定アイテム取得
curl https://xxxxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/dev/items/1

# 新規アイテム作成
curl -X POST https://xxxxxxxxxx.execute-api.ap-northeast-1.amazonaws.com/dev/items \
  -H "Content-Type: application/json" \
  -d '{"name": "新しいアイテム", "description": "説明", "price": 100.0}'
```

## 🧰 開発コマンド

```bash
# 依存関係の更新
uv sync

# コードフォーマット
uv run black src/

# リンター実行
uv run ruff src/

# テスト実行
uv run pytest
```

## 🔧 カスタマイズ

### 環境変数

`terraform/variables.tf`で以下を設定できます:

- `aws_region`: デプロイ先AWSリージョン
- `project_name`: プロジェクト名
- `environment`: 環境名（dev/staging/prod）

### Lambda設定

`terraform/main.tf`でLambda関数の設定を変更できます:

- `timeout`: タイムアウト時間
- `memory_size`: メモリサイズ
- `runtime`: Pythonランタイム

## 🗑️ リソース削除

```bash
cd terraform
terraform destroy
```
