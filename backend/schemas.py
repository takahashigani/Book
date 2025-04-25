from datetime import date
from typing import Optional
from pydantic import BaseModel, ConfigDict
from enum import Enum as PyEnum

class ReadingStatusSchema(PyEnum):
    WANT_TO_READ = "want_to_read"
    READING = "reading"
    COMPLETED = "completed"

class BookBase(BaseModel):
    title: str
    author: str
    # 以下、デフォルト値がNoneのフィールドはOptional[型] = None または 型 | None = None の形式で記述します
    published_date: Optional[date] = None # または published_date: date | None = None
    summary: Optional[str] = None         # または summary: str | None = None
    reading_status: ReadingStatusSchema # Enum型も指定できます
    page_count: Optional[int] = None      # ここが元のSyntaxErrorの原因箇所
    cover_image_url: Optional[str] = None # または cover_image_url: str | None = None
    isbn: Optional[str] = None            # または isbn: str | None = None

class BookUpdate(BaseModel):
    # PUTやPATCHで部分的な更新を許可する場合、フィールドをOptionalにします
    title: Optional[str] = None
    author: Optional[str] = None
    published_date: Optional[date] = None
    summary: Optional[str] = None
    # reading_statusも更新対象にするならOptionalにします
    reading_status: Optional[ReadingStatusSchema] = None
    page_count : Optional[int] = None
    cover_image_url : Optional[str] = None
    isbn : Optional[str] = None

class BookStatusUpdate(BaseModel):
    # ステータスのみを更新する場合
    reading_status: ReadingStatusSchema

class BookCreate(BookBase):
    # 作成時はBookBaseの必須フィールド（title, author, reading_status）が必要です
    pass

class Book(BookBase):
    id: int

    model_config = ConfigDict(from_attributes=True)