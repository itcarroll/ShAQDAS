# Bedbugger Articles

View an example article and associated comments at <http://bedbugger.com/2017/06/02/911-dispatch-centers-bed-bugs-jackson/>. This repository collects all articles from the Bedbugger Archives along with associated comments and places them in local storage.


# Aquisition

The website is a WordPress.org application with the JSON API active. Local storage is the "bedbugger" schema within the "bedbugs" database on the PostgreSQL research.sesync.org server. The database tables were defined and populated using the Python SQLAlchemy and requests modules, and can be recreated by executing.

```
> export PGSERVICEFILE=/nfs/bedbugs-data/pg_service.conf
> python3 bedbugger.py
```

The table definitions are specified through the ORM in bedbugger_orm.py.

# Annotation

