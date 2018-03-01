# Bedbugger Articles

View an example article and associated comments at <http://bedbugger.com/2017/06/02/911-dispatch-centers-bed-bugs-jackson/>. This repository collects all articles from the Bedbugger Archives along with associated comments and places them in local storage.


# Aquisition

The website is a WordPress.org application with the JSON API active. Local storage is the "bedbugger" schema within the "bedbugs" database on the PostgreSQL research.sesync.org server. The database tables were defined and populated using the Python SQLAlchemy and requests modules, and can be recreated by executing.

```
> export $(cat .Renviron)
> python3 bedbugger.py
```

The table definitions are specified through the ORM in bedbugger_orm.py.

# Annotation

The "BedbuggerCoder" folder contains a Shiny app, with a dependency on "BedbuggerCoder/bedbugger.RData". The dependency is exported and pre-processed tables from the "bedbugs.bedbugger" schema and can be created by running "bedbugger_export.R" (note that the Rproj must be opened or the .Renviron otherwise loaded). The app with data can be distributed as a ZIP to the research assistants, who's annotations will be stored in a local "codes.RData" file. The process for combinging multiple assistant's work is to be done manually and in conjunction with the app's export / import feature.
