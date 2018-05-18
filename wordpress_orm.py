"""Create the ORM for a database schema with tables for holding
the full text content of posts on a wordpress site. Learn more at
http://docs.sqlalchemy.org/en/latest/."""

from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy import Column, String, Text, Integer, ForeignKey, DateTime

Base = declarative_base()

class Author(Base):
    __tablename__ = 'author'
    id = Column(Integer, primary_key = True)
    name = Column(String)
    
    posts = relationship('Post', backref = 'author')
    comments = relationship('Comment', backref = 'author')

class Post(Base):
    __tablename__ = 'post'
    id = Column(Integer, primary_key = True)
    date_gmt = Column(DateTime)
    link = Column(String)
    title = Column(String)
    author_id = Column(Integer, ForeignKey('author.id'))
    content = Column(Text)

    comments = relationship("Comment", backref = "post")

class Comment(Base):
    __tablename__ = 'comment'
    id = Column(Integer, primary_key = True)
    post_id = Column(Integer, ForeignKey('post.id'))
    parent = Column(Integer)
    author_id = Column(Integer, ForeignKey('author.id'))
    author_name = Column(String())
    date_gmt = Column(DateTime)
    content = Column(Text)
