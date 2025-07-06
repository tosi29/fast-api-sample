from fastapi import FastAPI, HTTPException
from typing import Dict, List
from .models import Item, ItemCreate, HealthResponse

app = FastAPI(
    title="FastAPI Sample",
    description="A sample FastAPI application for AWS Lambda",
    version="1.0.0",
)

# In-memory storage for demo purposes
items_db: Dict[int, Item] = {
    1: Item(id=1, name="Laptop", description="High-performance laptop", price=999.99, tax=99.99),
    2: Item(id=2, name="Mouse", description="Wireless mouse", price=29.99, tax=3.00),
    3: Item(id=3, name="Keyboard", description="Mechanical keyboard", price=89.99, tax=9.00),
}

next_id = 4


@app.get("/", response_model=HealthResponse)
async def health_check():
    """ヘルスチェック用エンドポイント"""
    return HealthResponse(status="ok", message="FastAPI is running!")


@app.get("/items/{item_id}", response_model=Item)
async def get_item(item_id: int):
    """指定されたIDのアイテムを取得"""
    if item_id not in items_db:
        raise HTTPException(status_code=404, detail="Item not found")
    return items_db[item_id]


@app.post("/items", response_model=Item)
async def create_item(item: ItemCreate):
    """新しいアイテムを作成"""
    global next_id
    new_item = Item(
        id=next_id,
        name=item.name,
        description=item.description,
        price=item.price,
        tax=item.tax,
    )
    items_db[next_id] = new_item
    next_id += 1
    return new_item


@app.get("/items", response_model=List[Item])
async def list_items():
    """全てのアイテムを取得"""
    return list(items_db.values())