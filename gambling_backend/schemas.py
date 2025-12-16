from pydantic import BaseModel
from typing import List, Dict

class UserCreate(BaseModel):
    username: str
    password: str

class UserResponse(BaseModel):
    id: int
    username: str
    balance: int

    class Config:
        from_attributes = True

class DiceRollRequest(BaseModel):
    bets: Dict[str, int]

class DiceRollResponse(BaseModel):
    dice: List[int]  
    hand_rank: str   
    total_payout: int
    new_balance: int
        
class Token(BaseModel):
    access_token: str
    token_type: str

class UserLogin(BaseModel):
    username: str
    password: str