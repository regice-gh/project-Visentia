from sqlalchemy import Column, Float, Integer, String
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(Float, primary_key=True, index=True)
    username = Column(String(50), unique=True, index=True)
    hashed_password = Column(String(255))
    balance = Column(Integer, default=1000)