from fastapi import FastAPI, Depends
from sqlalchemy.orm import Session
from database import engine, Base, get_db
from sqlalchemy import text

# Create tables automatically (if they don't exist)
Base.metadata.create_all(bind=engine)

app = FastAPI()

@app.get("/")
def read_root():
    return {"message": "Welcome to the Dice Poker API!"}

# Test the DB connection
@app.get("/test-db")
def test_db(db: Session = Depends(get_db)):
    try:
        # Try to run a simple query
        result = db.execute(text("SELECT 1"))
        return {"status": "Database Connected Successfully", "result": result.scalar()}
    except Exception as e:
        return {"status": "Connection Failed", "error": str(e)}