from os import read
from typing import Optional
from sqlalchemy.orm import Session
import models
import schemas

def create_book(db: Session, book: schemas.BookCreate):
    ## book.titleとbook.authorが既に登録していないかをチェック
    exiting_book = db.query(models.BookModel).filter(
        models.BookModel.title == book.title,
        models.BookModel.author == book.author
    ).first()

    if exiting_book:
        raise ValueError("Book with the same title and author already exists.")

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

def update_book(db: Session, book_id: int, book_update_data: schemas.BookCreate):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if db_book:
        for Key, value in update_book.items():
            setattr(db_book, Key, value)
        db.commit()
        db.refresh(db_book)
    return db_book

def update_book_status(db: Session, book_id: int, status: schemas.ReadingStatusSchema):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if(db_book):
        db_book.reading_status = status
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

def patch_book(db: Session, book_id: int, book_update: schemas.BookUpdate):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if(db_book):
        update_book = book_update.model_dump(exclude_unset=True)
        for key, value in update_book.items():
            setattr(db_book, key, value)
        db.commit()
        db.refresh(db_book)
    return db_book