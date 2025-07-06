from mangum import Mangum
from .main import app

# Lambda用のハンドラー (HTTP API Gateway v2.0対応)
handler = Mangum(app, lifespan="off", api_gateway_base_path="/dev")