# ShAQDAS

The "Shiny Assisted Qualitative Data Analysis Software" app is a
multi-user [CAQDAS] built with R Shiny."

The pilot contained in this repository originated as a project to
collect and code a blog, that happened to be a Wordpress.org site. So
is [wilwheaton.net], enough said. This repository contains Python code
to scrape the content from the Wordpress API into a database and a
Shiny app to allow users to view and assign codes to excerpts.

## Data Aquisition

The website is a WordPress.org application with the JSON API
active. Local storage is in a SQLite database, but would be changed to
PostgreSQL in production. The database tables are defined and
populated using the Python SQLAlchemy and requests modules, and can be
recreated by executing `python wordpress_scrape.py`. Caution: Wil
Wheaton writes [alot of blogs]. The site URL and database name are
hard-coded in this pilot. The table definitions are specified through
the more generic ORM in [wordpress_orm.py](wordpress_orm.py).

## App Useaage

The single-file [app.R](app.R) and a tiny bit of CSS and JavaScript
comprise the coding tool.  The app currently stores the user-assigned
codes in a local "codes.RData" file. A planned feature, making ShAQDAS
actually multi-user, is to allow annotations to be stored in one
database for real-time collaboration.

## Useage

Once launched, ShAQDAS displays three tabs: two for the pupose of
coding articles and one for importing / exporting the entered codes.

### The “Post” Tab

A selected article's main "post" is visible in this tab, and the
associated author and publication date show in the sidebar. Any codes
added in the sidebar are associated with the content visible in this
tab.

### The “Comments” Tab

All comments on a selected article are visible in this tab, the
selected comment is highlighted with a red border, and the associated
author and publication date show in the sidebar. Any codes added in
the sidebar are associated with the content within the red box visible
in this tab.

### The “Codes” Tab

There are two tables that can be imported or exported (both are stored
locally within a "RData" file). The "Codebook" is a table
that determines which codes are available in the drop down menu for
code entry. The "Codes" table holds all entered codes. Uploading
either one **will overwrite** the tables in the app, so always
"Download" a copy as a backup before uploading a replacement.

[wilwheaton.net]: http://wilwheaton.net
[ALOT]: http://hyperboleandahalf.blogspot.com/2010/04/alot-is-better-than-you-at-everything.html
[CAQDAS]: https://en.wikipedia.org/wiki/Computer-assisted_qualitative_data_analysis_software
