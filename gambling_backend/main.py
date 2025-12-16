#start server with:
#go into gambling_backend folder and run:
#uvicorn main:app --reload --host 0.0.0.0

#imports
from fastapi import FastAPI, Depends, HTTPException, status
from sqlalchemy.orm import Session
from database import engine, Base, get_db
from models import User
from schemas import DiceRollRequest, DiceRollResponse, UserCreate, UserResponse
from passlib.context import CryptContext
from sqlalchemy import text
from datetime import datetime, timedelta, timezone
from jose import jwt
from schemas import Token, UserLogin
from uuid import uuid4
import random
import collections

#create database tables
Base.metadata.create_all(bind=engine)
app = FastAPI()

# Security settings
pwd_context = CryptContext(schemes=["argon2"], deprecated="auto")
SECRET_KEY = "123456789abcdef123456789abcdef"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

# Utility/helper functions
def get_random_secret_key():
    return uuid4().hex

def get_password_hash(password):
    return pwd_context.hash(password)

def verify_password(plain_password, hashed_password):
    return pwd_context.verify(plain_password, hashed_password)

def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def get_current_user(token: str = Depends(lambda: None), db: Session = Depends(get_db)):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise HTTPException(status_code=401, detail="Invalid token")
    except:
        raise HTTPException(status_code=401, detail="Invalid token")
    
    user = db.query(User).filter(User.username == username).first()
    if user is None:
        raise HTTPException(status_code=401, detail="User not found")
    return user

#auth endpoints
@app.post("/login", response_model=Token)
def login_for_access_token(user_login: UserLogin, db: Session = Depends(get_db)):
    
    user = db.query(User).filter(User.username == user_login.username).first()
    
    if not user or not verify_password(user_login.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect username or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}

@app.post("/guest-login", response_model=Token)
def guest_login(db: Session = Depends(get_db)):
    guest_id = str(uuid4().hex[:8])
    guest_username = f"guest_{guest_id}"
    guest_password = uuid4().hex
    
    hashed_pw = get_password_hash(guest_password)
    
    new_user = User(username=guest_username, hashed_password=hashed_pw)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    access_token = create_access_token(data={"sub": new_user.username})
    
    return {"access_token": access_token, "token_type": "bearer"}
    
 
@app.post("/register", response_model=UserResponse)
def register(user: UserCreate, db: Session = Depends(get_db)):
    
    existing_user = db.query(User).filter(User.username == user.username).first()
    if existing_user:
        raise HTTPException(status_code=400, detail="Username already registered")
    
    hashed_pw = get_password_hash(user.password)
    
    new_user = User(username=user.username, hashed_password=hashed_pw)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    
    return new_user

#game endpoint & logic
@app.post("/roll", response_model=DiceRollResponse)
def roll_dice(bets: DiceRollRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    #validation
    total_bet = sum(bets.bets.values())
    if total_bet > current_user.balance:
        raise HTTPException(status_code=400, detail="Insufficient balance for the bets placed.")
    #buy-in deduction
    current_user.balance -= total_bet
    
    # Roll 5 dice
    dice = [random.randint(1, 6) for _ in range(5)]
    diceCounter =  collections.Counter(dice)
    
    PAYOUT_HAND = {
        "Five of a Kind": 50,
        "Four of a Kind": 25,
        "Straight": 15,
        "Full House": 10,        
        "Three of a Kind": 5,
        "Two Pair": 3,
        "One Pair": 1,
        "Bust": 0,
    }
    
    #logic rules 
    DEFINE_HAND = {
        "Five of a Kind": lambda c: 5 in c.values(),
        "Four of a Kind": lambda c: 4 in c.values(),
        "Full House": lambda c: sorted(c.values()) == [2, 3],
        "Straight": lambda c: set(c.keys()) == {1, 2, 3, 4, 5} or set(c.keys()) == {2, 3, 4, 5, 6},
        "Three of a Kind": lambda c: 3 in c.values(),
        "Two Pair": lambda c: list(c.values()).count(2) == 2,
        "One Pair": lambda c: 2 in c.values(),
    }
    
    #highest hand evaluation    
    def evaluate_hand(counter):
        for hand, check in DEFINE_HAND.items():
            if check(counter):
                return hand
        return "Bust"
    
    #determine highest hand for UI display
    highest_hand_rank = evaluate_hand(diceCounter)
    
    #calculate winnings (check All bets)
    total_winnings = 0    
    for bet_name, bet_amount in bets.bets.items():
        if bet_name in DEFINE_HAND and DEFINE_HAND[bet_name](diceCounter):
            payout = PAYOUT_HAND[bet_name]
            total_winnings += bet_amount * payout
    
    #update user balance
    current_user.balance += total_winnings
    db.commit()
    
    #return response
    return DiceRollResponse(
        dice=dice, 
        hand_rank=highest_hand_rank, 
        total_payout=total_winnings, 
        new_balance=current_user.balance
    )