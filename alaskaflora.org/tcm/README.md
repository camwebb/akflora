# tcm: a web app for managing taxon concepts and their interrelationships

_The problem_: taxonomic names are incomplete keys for referencing the
circumscription of a group of organisms, because the same name may be
used differently by different taxonomists. The complete key is _name +
accordingTo_, known as a taxon concept, or taxonomic name
usage. Despite this serious issue for communication in biodiversity
science, few databases handle taxon concepts.

_A solution_: the `tcm` web app enables:

 1. The defining of taxonomic concepts (“Taxon Concept” tab), linking
    a taxonomic name (“Name” tab) with a publication (“Publication”
    tab).
 2. A way to record their interrelationships (“TC Relationships” tab):
    taxon concepts represent sets of organisms and can thus be related
    using set relationship terms: _is congruent with_, _includes_,
    _overlaps with_, _intersects_ and _is disjunct from_.
 3. Visualization of taxon concept relationships (“Graph” tab).
 4. Export of taxon concept definitions and relationships as RDF.

## Installation

Prerequisites:

 * GNU Awk (`gawk`)
 * A CGI-enabled web server (e.g., `apache`)
 * The MySQL/MariaDB command line client (`mysql`)
 * The Graphviz command line client (`dot`)

Download the latest release from the [releases/](releases) directory.

### 1. Script

The web app is a single Awk script (GNU Awk flavor), called
`tcm`. (You can rename it to anything else - just make sure to adjust
the `.htaccess` file (see below), and change the config variable
`APPNAME` in the script.)

 1. Make sure the first (hashbang) line of the script points to the
    installed location of `gawk`. You can test that the script is
    running OK, independent of web server access, by i) making sure
    the script is executable (`chmod u+x tcm`), and ii) typing `./tcm` -
    you should see an HTML output.
 2. Create a world-writable directory `tmp/` for the graphviz image
    outputs (created by web server user `http` or `apache`): `mkdir
    tmp && chmod a+rw tmp`

### 2. MySQL database

 1. Log into the MySQL (or MariaDB) server. Create a database with 
    `CREATE DATABASE tcm CHARSET 'utf8' COLLATE 'utf8_bin';` 
 2. Create the database structure by executing SQL commands in `tcm.sql`.
    E.g., `mysql -u <user> -p<password> -h <host> tcm < tcm.sql`
 3. Configure the database access credentials in `pw.awk`. Copy
    `pw_template.awk` to `pw.awk` and enter the hostname, username,
    password and the name of the database (`tcm` by default, but just
    adjust this file to match the actual DB name).

### 3. .htaccess

The `.htaccess` file performs local configuration of the apache web
server. Adapt for use with other web servers (`nginx`, etc).  

Copy `htaccess_template` to `.htaccess` in this directory, and edit as
needed. Note that cookie-based filtering by genus in `tcm` requires
the `session_module` and `session_cookie_module` to be loaded (in
`httpd.conf`).
