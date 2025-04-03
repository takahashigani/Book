from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_helloWorld():
    pass

def test_create_book():
    response = client.post("/books/", json={"title": "Book A", "author": "Author", "published_date": "2023-01-01", "summary": "A"})
    assert response.status_code == 201
    assert response.json()["title"] == "Book A"
    
def test_read_books():
    book1_data = {"title": "Book A", "author": "Author A", "published_date": "2023-01-01", "summary": "A"}
    book2_data = {"title": "Book A", "author": "Author A", "published_date": "2023-01-01", "summary": "A"}
    client.post("/books/", json=book1_data)
    client.post("/books/", json=book2_data)
    
    response = client.get("/books/")
    assert response.status_code == 200
    assert response.json()[0]["title"] == "Book A"
    assert response.json()[1]["title"] == "Book A"

def test_put_book():
    book_data = {"title": "Book A", "author": "Author A", "published_date": "2023-01-01", "summary": "A"}
    response = client.post("/books/", json=book_data)
    book_id = response.json()["id"]
    
    response = client.put(f"/books/{book_id}", json={"title": "Book A Updated", "author": "Author A", "published_date": "2023-01-01", "summary": "A"})
    assert response.status_code == 200
    assert response.json()["title"] == "Book A Updated"

    
