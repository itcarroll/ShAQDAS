"""Create the ORM for a database with two tables sharing a many-to-one
relationship: many posts for each topic. Learn more at
http://docs.sqlalchemy.org/en/latest/."""

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, String, Text, Integer, ForeignKey

Base = declarative_base()

class Topic(Base):
    __tablename__ = 'topic'
    id = Column(Integer, primary_key=True)
    url = Column(String)
    posts = relationship('Post')

class Post(Base):
    __tablename__ = 'post'
    id = Column(Integer, primary_key=True)
    topic_id = Column(Integer, ForeignKey('topic.id'))
    text = Column(Text)
