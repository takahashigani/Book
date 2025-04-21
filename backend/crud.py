from os import read
from typing import Optional
from sqlalchemy.orm import Session
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
        raise ValueError("Book with the same title and author already exists.")

    db_book = models.BookModel(**book.model_dump())
    db.add(db_book)
    db.commit()
    db.refresh(db_book)
    return db_book

## GETメソッドで書籍情報を取得する関数
## GETメソッドは、リソースの情報を取得するために使用されます。
## 例えば、書籍の一覧を取得したい場合に使用します。
## ただし、書籍の読書状況でフィルタリングすることもできます。
def get_books(db: Session, reading_status: Optional[str] = None, skip: int = 0, limit: int = 1000):
    query = db.query(models.BookModel)
    if(reading_status):
        query = query.filter(models.BookModel.reading_status == reading_status)
    return query.offset(skip).limit(limit).all()

## GETメソッドで書籍情報を取得する関数
## GETメソッドは、リソースの情報を取得するために使用されます。
## 例えば、書籍の詳細情報を取得したい場合に使用します。
def get_book(db: Session, book_id: int):
    return db.query(models.BookModel).filter(models.BookModel.id == book_id).first()

## Updateメソッドで書籍の状態を更新する関数
## Updateメソッドは、リソースの状態を更新するために使用されます。
## 例えば、書籍の読書状況を変更したい場合に使用します。
def update_book_status(db: Session, book_id: int, status: schemas.ReadingStatusSchema):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if(db_book):
        db_book.reading_status = status
        db.commit()
        db.refresh(db_book)
    return db_book

## DELETEメソッドで書籍を削除する関数
## DELETEメソッドは、リソースを削除するために使用されます。
## 例えば、書籍をデータベースから完全に削除したい場合に使用します。
def delete_book(db: Session, book_id: int):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if db_book:
        db.delete(db_book)
        db.commit()
        return db_book
    return None

## PATCHメソッドで部分更新を行う関数
## PATCHメソッドは、リソースの一部を更新するために使用されます。
## 例えば、書籍のタイトルや著者だけを変更したい場合に便利です。
def patch_book(db: Session, book_id: int, book_update: schemas.BookUpdate):
    db_book = db.query(models.BookModel).filter(models.BookModel.id == book_id).first()
    if(db_book):
        update_book = book_update.model_dump(exclude_unset=True)
        for key, value in update_book.items():
            setattr(db_book, key, value)
        db.commit()
        db.refresh(db_book)
    return db_book