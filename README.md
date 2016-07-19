# TodoList (MySQL)
MySQL implementation of TodoList

Quick start on MacOS:

- Download the [Swift DEVELOPMENT 06-06 snapshot](https://swift.org/download/#snapshots)
- Install MySQL

  `brew install mysql`
  `brew link mysql`
  `mysql.server start`
  
- Link MySQL during swift build

  `swift build -Xswiftc -I/usr/local/include/mysql -Xlinker -L/usr/local/lib`

-I tells the compiler where to find the MySQL header files, and -L tells the linker where to find the library. This is required to compile and run on macOS.

- Create your database table

  `CREATE TABLE todos (tid INT NOT NULL AUTO_INCREMENT PRIMARY KEY, title TEXT, owner_id VARCHAR(256), completed INT, orderno INT)`

## Compile and run tests:

1. Clone the Tests to your project:

  `git clone https://github.com/IBM-Swift/todolist-tests Tests`

2. Build the project: 

  `swift build -Xcc -I/usr/local/include -Xlinker -L/usr/local/lib`

3. Run the tests:

  `swift test`
