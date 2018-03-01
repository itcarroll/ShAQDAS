# BedbuggerCoder Docs

RStudio is a program that (among many other things) runs "apps" that are created using [Shiny](https://shiny.rstudio.com/). BedbuggerCoder is an app created to facilitate annotation of the articles published on "http://bedbugger.com".

## Installation

1. Install [RStudio Desktop](https://www.rstudio.com/products/rstudio/download/#download)
1. Open RStudio
    1. Find “Tools > Install Packages …” in the menu bar.
    1. Install “shiny” and “dplyr”:  
       ![](images/package.png)
1. Download [BedbuggerCoder.zip](http://sesync.us/xa1f3) using password 'islandcreek'.
1. Unzip “BedbuggerCoder.zip”, move the "BedbuggerCoder" folder to your preferred directory.
1. Open the “app.R” file with RStudio.
1. Set “Run App” to "Run in Window":  
   ![](images/runapp.png)
1. Click "Run App" to launch the app.

## Useage

BedbuggerCoder has three tabs: two for the pupose of coding articles and one for importing / exporting the entered codes.

### The “Post” Tab

A selected article's main "post" is visible in this tab, and the associated author and publication date show in the sidebar. Any codes added in the sidebar are associated with the content visible in this tab.

### The “Comments” Tab

All comments on a selected article are visible in this tab, the selected comment is highlighted with a red border, and the associated author and publication date show in the sidebar. Any codes added in the sidebar are associated with the content within the red box visible in this tab.

### The “Codes” Tab

There are two tables that can be imported or exported (both are stored locally within the "BedbuggerCoder" folder). The "Codebook" is a table that determines which codes are available in the drop down menu for code entry. The "Codes" table holds all entered codes. Uploading either one **will overwrite** the tables in the app, so always "Download" a copy as a backup before uploading a replacement.

