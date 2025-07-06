#!/bin/bash
set -e

echo "🚀 Deploying FastAPI to AWS Lambda..."

# プロジェクトルートディレクトリに移動
cd "$(dirname "$0")/.."

# 引数の処理
ENVIRONMENT=${1:-dev}
AWS_REGION=${2:-ap-northeast-1}

echo "📋 Deployment configuration:"
echo "  Environment: $ENVIRONMENT"
echo "  AWS Region: $AWS_REGION"

# パッケージが存在するかチェック
if [ ! -f "dist/lambda.zip" ]; then
    echo "❌ Lambda package not found. Running build first..."
    ./scripts/build.sh
fi

# Terraformディレクトリに移動
cd terraform

# Terraform初期化
echo "🔧 Initializing Terraform..."
terraform init

# Terraformプラン
echo "📋 Planning deployment..."
terraform plan \
    -var="environment=$ENVIRONMENT" \
    -var="aws_region=$AWS_REGION" \
    -out=tfplan

# デプロイ確認
echo "❓ Do you want to proceed with deployment? (y/N)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "🚀 Deploying infrastructure..."
    terraform apply tfplan
    
    echo "✅ Deployment completed successfully!"
    echo ""
    echo "📋 Deployment information:"
    terraform output
    
    # API Gateway URLを取得
    API_URL=$(terraform output -raw api_gateway_url)
    echo ""
    echo "🌐 Your API is available at:"
    echo "  $API_URL"
    echo ""
    echo "🧪 Test your API:"
    echo "  curl $API_URL/"
    echo "  curl $API_URL/items"
    echo "  curl $API_URL/items/1"
else
    echo "❌ Deployment cancelled."
    rm -f tfplan
fi

cd - > /dev/null