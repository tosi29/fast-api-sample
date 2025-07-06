#!/bin/bash
set -e

echo "🚀 Building FastAPI Lambda package..."

# プロジェクトルートディレクトリに移動
cd "$(dirname "$0")/.."

# distディレクトリを作成
mkdir -p dist
rm -rf dist/*

# プロジェクトルートの絶対パスを取得
PROJECT_ROOT=$(pwd)

# 一時ディレクトリを作成
TEMP_DIR=$(mktemp -d)
echo "📦 Using temporary directory: $TEMP_DIR"

# uvを使用して依存関係をインストール
echo "📥 Installing dependencies with uv..."
uv pip install --python 3.9 --target "$TEMP_DIR" -r <(uv pip compile pyproject.toml --quiet)

# ソースコードをコピー
echo "📄 Copying source code..."
cp -r src "$TEMP_DIR/"

# Lambda用のzipファイルを作成
echo "📦 Creating Lambda zip package..."
cd "$TEMP_DIR"
zip -r "$PROJECT_ROOT/dist/lambda.zip" . -x "*.pyc" "*/__pycache__/*" "*.dist-info/*"

# 一時ディレクトリを削除
cd - > /dev/null
rm -rf "$TEMP_DIR"

# パッケージサイズを表示
PACKAGE_SIZE=$(du -h "$PROJECT_ROOT/dist/lambda.zip" | cut -f1)
echo "✅ Lambda package created: dist/lambda.zip ($PACKAGE_SIZE)"

# Lambda制限チェック
PACKAGE_SIZE_BYTES=$(stat -f%z "$PROJECT_ROOT/dist/lambda.zip" 2>/dev/null || stat -c%s "$PROJECT_ROOT/dist/lambda.zip" 2>/dev/null)
if [ "$PACKAGE_SIZE_BYTES" -gt 52428800 ]; then
    echo "⚠️  Warning: Package size exceeds 50MB Lambda limit"
else
    echo "✅ Package size is within Lambda limits"
fi

echo "🎉 Build completed successfully!"