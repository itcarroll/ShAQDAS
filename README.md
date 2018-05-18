# ShAQDAS

The "Shiny Assisted Qualitative Data Analysis Software" app is a
multi-user [CAQDAS] built with R Shiny.

The pilot contained in this repository originated as a project to
collect and code a blog, that happened to be a Wordpress.org site. So
is [wilwheaton.net], and so here we are. This repository contains
Python code to scrape the content from the Wordpress API into a
database and a Shiny app to allow users to view and assign codes to
excerpts. A small portion of the scraped data is included for an
easy demo.

## Shiny App

The single-file [app.R](app.R) and a tiny bit of [CSS](app.css) and
[JavaScript](app.js) comprise the coding tool.  The app currently
stores the user-assigned codes in a local "codes.RData" file. A
planned feature, making ShAQDAS actually multi-user, is to allow
annotations to be stored in one database for real-time collaboration.

### Useage

Once launched, ShAQDAS displays three tabs: two for the pupose of
coding articles and one for importing / exporting the entered codes.
The "Post" and "Comments" tab work the same way: copy text you want to
code into the text form, optionally compose a memo, and choose a code.
Highlighting would be nice; any idea how to implement?

#### The “Post” Tab

A selected article's main "post" is visible in this tab, and the
associated author and publication date show in the sidebar. Any codes
added in the sidebar are associated with the content visible in this
tab.

#### The “Comments” Tab

All comments on a selected article are visible in this tab, the
selected comment is highlighted with a red border, and the associated
author and publication date show in the sidebar. Any codes added in
the sidebar are associated with the content within the red box visible
in this tab.

#### The “Codes” Tab

There are two tables that can be imported or exported (both are stored
locally within a "RData" file). The "Codebook" is a table that
determines which codes are available in the drop down menu for code
entry. Additional records can be appended one-at-a-time here. The
"Codes" table holds all entered codes. Uploading either one **will
overwrite** the tables in the app, so always "Download" a copy as a
backup before uploading a replacement.

## Data Aquisition

The app is currently limited to data from a website running the
WordPress.org REST API. Local storage is in a SQLite database, but
would be changed to PostgreSQL in production. Local database tables
are defined and populated using the Python SQLAlchemy and requests
modules, and can be recreated by executing `python
wordpress_scrape.py`. Caution: Wil Wheaton writes [alot of blogs]; I
killed this after the database topped a few Mb, then cleaned up
foreign keys in the sample. The site URL and database name are
hard-coded in this pilot, but could easily be changed. The table
definitions are specified through the ORM in
[wordpress_orm.py](wordpress_orm.py). It's not entirely necessary that
the data be offlined all-at-once like this, or even at all, but is
perhaps good for reproducibility (bad for updating).

[wilwheaton.net]: http://wilwheaton.net
[alot of blogs]: http://hyperboleandahalf.blogspot.com/2010/04/alot-is-better-than-you-at-everything.html
[CAQDAS]: https://en.wikipedia.org/wiki/Computer-assisted_qualitative_data_analysis_software
