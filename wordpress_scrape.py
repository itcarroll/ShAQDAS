"""Scrape a wordpress.org website into a database using the ORM defined in
adjacent wordpress_orm.py."""

from requests import get
from datetime import datetime
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from wordpress_orm import Base, Post, Comment, Author
from psycopg2 import IntegrityError
from time import sleep

# # Overview
# 
# Execute GET requests on WordPress REST API, which has endpoints for
# posts, comments and authors. We go through each one in turn: first getting
# the array, then getting the entries and building the database.

# parameters for wordpress.org API
api = 'http://wilwheaton.net/wp-json/wp/v2/'
params = {
    'page': 1,       # starting page, to increment
    'per_page': 100, # number of items to request at a time
    }
nice = 1             # delay between api calls

# database connection
engine = create_engine('sqlite:///wilwheaton.db', echo=False)
Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)
session = Session()

# users endpoint
while True:
    print("Authors page {}".format(params['page']), flush = True)
    response = get(api + 'users', params = params)
    if not response.ok or response.text == '[]': break
    records = []
    for user in response.json():
        records.append(Author(
            id = user['id'],
            name = user['name'],
            ))
    params['page'] += 1
    records = [session.merge(r) for r in records]
    session.add_all(records)
    session.commit()
    sleep(nice)

# posts endpoint
params['page'] = 1
while True:
    print("Posts page {}".format(params['page']), flush = True)
    response = get(api + 'posts', params = params)
    if not response.ok or response.text == '[]': break
    records = []
    for post in response.json():
        author = session.query(Author).filter_by(id = post['author']).first()
        records.append(Post(
            id = post['id'],
            date_gmt = datetime.strptime(post['date_gmt'], "%Y-%m-%dT%H:%M:%S"),
            link = post['link'],
            title = post['title']['rendered'],
            author = author,
            content = post['content']['rendered'],
            ))
    params['page'] += 1
    records = [session.merge(r) for r in records]
    session.add_all(records)
    session.commit()
    sleep(nice)

# comments endpoint
params['page'] = 1
while True:
    print("Comments page {}".format(params['page']), flush = True)
    response = get(api + 'comments', params = params)
    if not response.ok or response.text == '[]': break
    records = []
    for comment in response.json():
        post = session.query(Post).filter_by(id = comment['post']).first()
        if not post: continue
        author = session.query(Author).filter_by(id = comment['author']).first()
        if comment['id'] == 1: continue
        records.append(Comment(
            id = comment['id'],
            post = post,
            parent = comment['parent'],
            author = author,
            author_name = comment['author_name'],
            date_gmt = datetime.strptime(comment['date_gmt'], "%Y-%m-%dT%H:%M:%S"),
            content = comment['content']['rendered'],
            ))
    params['page'] += 1
    records = [session.merge(r) for r in records]
    session.add_all(records)
    session.commit()
    sleep(nice)

session.close()
