# pinport

Pinport is a PIN importing command line utility written in Ruby.

Currently supports importing to a MySQL database.

## Installation

``` sh
gem install pinport
```


## Configuration

A `config.yml` file specifying details for your MySQL database is required.  Pinport uses this file to determine how connect to your database and which table/column to insert imported PINs into. It is recommended that you use `pinport generate` to generate this file so that it is appropriately formatted.

### Generating a config.yml file

Use `pinport generate` to generate the required `config.yml` file in the current directory.

Pinport uses the `mysql2` gem to establish the connection to the database. For available database connection options, refer to: https://github.com/brianmario/mysql2#connection-options.


## Usage

### Importing a single .txt file:

``` sh
pinport import FILE
```

FILE should contain one line per item to be imported.

### Importing a folder of .txt files:
``` sh
pinport import FOLDER
```


## Development
Clone this repository using `git clone`.

Navigate to the directory of cloned repository and run `rake` to compile and install the gem from
source.

To do the tasks separately:

- `rake build` to compile the gem
- `rake install` to install the gem.