from datetime import date
from pydantic import BaseModel, ConfigDict
from enum import Enum as PyEnum

class ReadingStatusSchema(PyEnum):
    WANT_TO_READ = "want_to_read"
    READING = "reading"
    COMPLETED = "completed"

class BookBase(BaseModel):
    title: str
    author: str
    published_date: date | None = None
    summary: str | None = None
    reading_status: ReadingStatusSchema
    page_count = int | None = None
    cover_image_url = str | None = None
    isbn = str | None = None

class BookUpdate(BaseModel):
    title: str
    author: str
    published_date: date | None = None
    summary: str | None = None
    reading_status: ReadingStatusSchema
    page_count = int | None = None
    cover_image_url = str | None = None
    isbn = str | None = None

class BookStatusUpdate(BaseModel):
    reading_status: ReadingStatusSchema

class BookCreate(BookBase):
    pass

class Book(BookBase):
    id: int

    model_config = ConfigDict(from_attributes=True)