# Data integration scripts

A collection of scripts (mainly Bash, Awk, and SQL) to document and
automate the integration of data resources for this project.

In general, each stage of resource conversion and/or integration is
achieved via scripts in a separate directory. The main work is
performed by a well-commented script named `README.sh` (or
`README.sql`) that doubles as documentation.  The top-level script is
`README.sh` in this directory; this script will run all the others. (I
thought about using `Makefile`s rather than Bash scripts, but the
syntax of Bash scripts is easier, and few -- if anyone -- will be
editing and rebuilding parts of the whole build-tree.)

Many steps in this integration process require manual
intervention. However, setting `$AKFLORA_AUTO` to `1` will substitute
a pre-calculated intermediate file.

## Steps/directories

 * [ALA](./ALA): The ALA Herbarium checklist 
 * [ACCS](./ACCS): The ACCS Alaska checklist 
 * [PAF](./PAF): The Panarctic Flora checklist
 * [FNA](./FNA): The Flora of North America

## Dependencies

To run all the scripts as they are written, the following set-up is
required,

 * `bash`
 * `gawk` (> v.4.2) with `gawkextlib`, and `aregex` and `json` extensions
 * `matchnames`
 * `xqilla`
 * `curl`
 * `mysqld` and `mysql` client, with an account than can create DBs
 * `iconv`

## Environment variables
 
 * Executable programs must be findable via `$PATH`
 * Gawk binary libraries must be findable via `$AWKLIBPATH`
 * Gawk scripts libraries must be findable via `$AWKPATH`
 * To run scripts without manual intervention, `$AKFLORA_AUTO` must be
   set to `1`
