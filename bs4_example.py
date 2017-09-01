"""Demonstrate scraping into a database using the ORM defined in
adjacent orm_example.py."""

import requests
from bs4 import BeautifulSoup
from sqlalchemy import create_engine
from orm_example import Base, Topic, Post
from sqlalchemy.orm import sessionmaker

# Execute HTML GET request
response = requests.get('http://bedbugger.com/forum/')

# Convert to a tree of HTML tags
soup = BeautifulSoup(response.content)
latest = soup.find('table', attrs={'id':'latest'})
topics = [tr.td.a['href'] for tr in latest.find_all('tr') if tr.td]

# Convert stings into instances of class Topic
topics = [Topic(url=url) for url in topics]

# Create Post for each Topic
for topic in topics:
    response = requests.get(topic.url)
    soup = BeautifulSoup(response.content)
    posts = soup.find_all('div', attrs={'class':'post'})
    topic.posts = [Post(text=post.text) for post in posts]
    # TESTING ONLY Go easy on the server while you work
    # on your code, and break after first iteration.
    break
    
# Write the scraped topics to a database

## TESTING ONLY Create a in-memory database and a
## session generator.
engine = create_engine('sqlite:///:memory:', echo=True)
Base.metadata.create_all(engine)
Session = sessionmaker(bind=engine)

# Use a database session to write topics to database
session = Session()
session.add_all(topics)
session.commit()

# Use the session object to query
one_post = session.query(Post).limit(1).one()
print('id: {}\ntopic_id: {}\ntext: {}\n'.format(
    one_post.id, one_post.topic_id, one_post.text))

session.close()
