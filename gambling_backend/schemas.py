from pydantic import BaseModel
from typing import List, Dict

class UserCreate(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    balance: float

    class Config:
        from_attributes = True

class DiceRollRequest(BaseModel):
    bets: Dict[str, float]

class DiceRollResponse(BaseModel):
    dice: List[int]  
    hand_rank: str   
    total_payout: float
    new_balance: float

class Token(BaseModel):
    access_token: str
    token_type: str

class UserLogin(BaseModel):
    username: str
    password: str