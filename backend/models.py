import enum
from sqlalchemy import Column, Integer, String, Date, Enum, UniqueConstraint
from database import Base

class ReadingStatusEnum(enum.Enum):
    WANT_TO_READ = "want_to_read"
    READING = "reading"
    COMPLETED = "completed"

class BookModel(Base):
    __tablename__ = "books"
    id = Column(Integer, primary_key = True, index = True)
    title = Column(String, index = True)
    author = Column(String)
    published_date = Column(Date)
    summary = Column(String)
    reading_status = Column(Enum(ReadingStatusEnum))
    page_count = Column(Integer)
    cover_image_url = Column(String)
    isbn = Column(String, index = True)
    
    __table_args__ = (UniqueConstraint('title', 'author', name='_title_author_uc'),)
    