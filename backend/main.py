import logging
from fastapi import FastAPI, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from typing import List, Optional
import database
import schemas
import crud
import models

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# --- アプリケーション起動時にテーブルを作成 ---
@app.on_event("startup")
def on_startup():
    logger.info("Application startup: Crating database tables (if they dont exist)...")
    try:
        models.Base.metadata.create_all(bind=database.engine)
    except Exception as e:
        logger.error(f"Error creating database tables during startup: {e}", exc_info=True)
        
# --- データベースセッションを取得する Dependency ---
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- API エンドポイント ---

@app.post("/books/", response_model=schemas.Book, status_code=status.HTTP_201_CREATED)
def create_book_endpoint(book: schemas.BookCreate, db: Session = Depends(get_db)):
    try:
        created_book = crud.create_book(db=db, book=book)
        return created_book
    except Exception as e:
        print(f"Error creating books: {e}")
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Could not create book")

@app.get("/books/", response_model=List[schemas.Book])
def read_books_endpoint(
    reading_status: Optional[str] = Query(None, description="Filter books by reading status (e.g., 'reading', 'completed', 'want_to_read')"),
    skip: int=0, limit: int=100, db: Session = Depends(get_db)):
    books = crud.get_books(db=db, skip=skip, limit=limit)
    return books

@app.get("/books/{book_id}", response_model=schemas.Book )
def read_book_endpoint(book_id: int, db: Session = Depends(get_db)):
    book = crud.get_book(db=db, book_id=book_id)
    if book is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
    return book

@app.put("/books/{book_id}", response_model=schemas.Book)
def update_book_endpoint(book_id: int, book: schemas.BookCreate, db: Session = Depends(get_db)):
    updated_book = crud.update_book(db=db, book_id=book_id, book=book)
    if updated_book is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
    return updated_book

@app.delete("/books/{book_id}", response_model=schemas.Book)
def delete_book_endpoint(book_id: int, db: Session = Depends(get_db)):
    deleted_book = crud.delete_book(db=db, book_id=book_id)
    if deleted_book is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Book not found")
    return deleted_book