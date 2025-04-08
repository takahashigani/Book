from os import read
from typing import Optional
from sqlalchemy.orm import Session
import models
import schemas

def create_book(db: Session, book: schemas.BookCreate):
    db_book = models.BookModel(**book.model_dump())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return db_book

def get_books(db: Session, reading_status: Optional[str] = None, skip: int = 0, limit: int = 1000):
    query = db.query(models.BookModel)
    if(reading_status):
        query = query.filter(models.BookModel.reading_status == reading_status)
    return query.offset(skip).limit(limit).all()

def get_book(db: Session, book_id: int):
    return db.query(models.BookModel).filter(models.BookModel.id == book_id).first()

def update_book(db: Session, book_id: int, book: schemas.BookCreate):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if db_book:
        db_book.title = book.title
        db_book.author = book.author
        db_book.published_date = book.published_date
        db_book.summary = book.summary
        
        db.commit()
        db.refresh(db_book)
    return db_book

def delete_book(db: Session, book_id: int):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if db_book:
        db.delete(db_book)
        db.commit()
        return db_book
    return None