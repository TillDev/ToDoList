# TodoList MySQL

[![Swift 3 6-06](https://img.shields.io/badge/Swift%203-6/20 SNAPSHOT-blue.svg)](https://swift.org/download/#snapshots)

A MySQL implementation of the [TodoList](https://github.com/IBM-Swift/todolist-boilerplate)

## Quick start for developing locally on macOS:

- Download the [Swift DEVELOPMENT 06-20 snapshot](https://swift.org/download/#snapshots)
- Clone the TodoList MySQL repository 
 
  `git clone https://github.com/IBM-Swift/todolist-mysql`

- Install MySQL

  `brew install mysql`
  `brew link mysql`
  `mysql.server start`
  
- Link MySQL during swift build

  `swift build -Xswiftc -I/usr/local/include/mysql -Xlinker -L/usr/local/lib`

-I tells the compiler where to find the MySQL header files, and -L tells the linker where to find the library. This is required to compile and run on macOS.

- Create your database table:

 `mysql -u root -p`

  ```sql 
  CREATE DATABASE todolist;
  USE todolist;
  CREATE TABLE todos (tid INT NOT NULL AUTO_INCREMENT PRIMARY KEY, title TEXT, owner_id VARCHAR(256), completed INT, orderno INT);
  ```

## Compile and run tests:

1. Clone the Tests to your project:

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`

2. Build the project: 

  `swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib`

3. Run the tests:

  `swift test`
