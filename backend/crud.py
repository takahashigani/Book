from os import read
from typing import Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
import models
import schemas

## POSTメソッドで書籍情報を登録する関数
## POSTメソッドは、リソースを新規に作成するために使用されます。
## 例えば、新しい書籍をデータベースに追加したい場合に使用します。
## ただし、書籍のタイトルと著者が既に登録されている場合は、エラーを返します。
def create_book(db: Session, book: schemas.BookCreate):
    ## book.titleとbook.authorが既に登録していないかをチェック
    exiting_book = db.query(models.BookModel).filter(
        models.BookModel.title == book.title,
        models.BookModel.author == book.author
    ).first()

    if exiting_book:
        raise HTTPException(
             status_code=status.HTTP_400_BAD_REQUEST,
             detail="Book with the same title and author already exists."
         )
    
    book_data = book.model_dump()
    if 'reading_status' in book_data and isinstance(book_data['reading_status'], schemas.ReadingStatusSchema):
        book_data['reading_status'] = models.ReadingStatusEnum(book_data['reading_status'].value)
    
    db_book = models.BookModel(**book_data)
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return schemas.Book.model_validate(db_book)

## GETメソッドで書籍情報を取得する関数
## GETメソッドは、リソースの情報を取得するために使用されます。
## 例えば、書籍の一覧を取得したい場合に使用します。
## ただし、書籍の読書状況でフィルタリングすることもできます。
def get_books(db: Session, reading_status: Optional[str] = None, skip: int = 0, limit: int = 1000):
    query = db.query(models.BookModel)
    if(reading_status):
        status_enum = models.ReadingStatusEnum(reading_status)
        query = query.filter(models.BookModel.reading_status == status_enum)
    db_books = query.offset(skip).limit(limit).all()
    return [schemas.Book.model_validate(book) for book in db_books]

## GETメソッドで書籍情報を取得する関数
## GETメソッドは、リソースの情報を取得するために使用されます。
## 例えば、書籍の詳細情報を取得したい場合に使用します。
def get_book(db: Session, book_id: int):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if db_book is None:
        return None
    return schemas.Book.model_validate(db_book)

## Updateメソッドで書籍の状態を更新する関数
## Updateメソッドは、リソースの状態を更新するために使用されます。
## 例えば、書籍の読書状況を変更したい場合に使用します。
def update_book_status(db: Session, book_id: int, status: schemas.ReadingStatusSchema):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if(db_book):
        db_book.reading_status = models.ReadingStatusEnum(status.value)
        db.commit()
        db.refresh(db_book)
        return schemas.Book.model_validate(db_book)
    return None

## DELETEメソッドで書籍を削除する関数
## DELETEメソッドは、リソースを削除するために使用されます。
## 例えば、書籍をデータベースから完全に削除したい場合に使用します。
def delete_book(db: Session, book_id: int):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if db_book:
        deleted_book_schema = schemas.Book.model_validate(db_book)
        db.delete(db_book)
        db.commit()
        return deleted_book_schema
    return None

## PATCHメソッドで部分更新を行う関数
## PATCHメソッドは、リソースの一部を更新するために使用されます。
## 例えば、書籍のタイトルや著者だけを変更したい場合に便利です。
def patch_book(db: Session, book_id: int, book_update: schemas.BookUpdate):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if(db_book):
        update_book = book_update.model_dump(exclude_unset=True)
        for key, value in update_book.items():
            if key == 'reading_status' and isinstance(value, schemas.ReadingStatusSchema):
                 setattr(db_book, key, models.ReadingStatusEnum(value.value))
            else:
                 setattr(db_book, key, value)
        db.commit()
        db.refresh(db_book)
        return schemas.Book.model_validate(db_book)
    return None