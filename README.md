# TodoList MySQL

[![Build Status](https://travis-ci.org/IBM-Swift/TodoList-MySQL.svg?branch=master)](https://travis-ci.org/IBM-Swift/TodoList-MySQL)
![](https://img.shields.io/badge/Swift-3.0.2%20RELEASE-orange.svg?style=flat)
![](https://img.shields.io/badge/platform-Linux,%20macOS-blue.svg?style=flat)


## Table of Contents
* [Summary](#summary)
* [Quick start](#quick-start)
* [Deploy to Bluemix](#setup-mysql-service-in-bluemix)
* [Compile and run tests](#compile-and-run-tests)

## Summary

A MySQL implementation of the [TodoList](https://github.com/IBM-Swift/todolist-boilerplate)

## Quick start:

2. Clone the TodoList MySQL repository 
 
  `git clone https://github.com/IBM-Swift/TodoList-MySQL.git`

3. Install and start MySQL

  For macOS:
  
  ```
  brew install mysql
  brew link mysql
  mysql.server start
  ```
  
  For Linux:
  
  ```
  sudo apt-get install clang-3.8 lldb-3.8 libmysqlclient-dev mysql-server
  sudo service mysql start
  ```
  
4. Link MySQL during swift build

    For macOS:
  
    `swift build -Xswiftc -I/usr/local/include/mysql -Xlinker -L/usr/local/lib -Xswiftc -DNOJSON` 

    -I tells the compiler where to find the MySQL header files, and -L tells the linker where to find the library. This is required to compile and run on macOS.
  
    For Linux:
  
    `swift build -Xswiftc -DNOJSON`

5. Create your database table:

 `sudo mysql`

  ```sql 
  CREATE DATABASE todolist;
  USE todolist;
  CREATE TABLE todos (tid INT NOT NULL AUTO_INCREMENT PRIMARY KEY, title TEXT, owner_id VARCHAR(256), completed INT, orderno INT);
  ```
 
6. Open the [TodoList Client](http://www.todobackend.com/client/index.html?http://localhost:8090)

## Deploying to Bluemix:

### Deploy to Bluemix Button

You can use this button to deploy TodoList to your Bluemix account, all from the browser. The button will create the application, create and bind any services specified in the manifest.yml file and deploy.

[![Deploy to Bluemix](https://bluemix.net/deploy/button.png)](https://bluemix.net/deploy?repository=https://github.com/IBM-Swift/TodoList-MySQ)

### Manually

1. Create the service

  ```
  cf create-service cleardb spark TodoList-MySQL
  ```

2. Push your application if you haven't already

  ```
  cf push
  ```


  Note: The uploading droplet stage should take several minutes. If it worked correctly, it should say:
  
  ```
  1 of 1 instances running
  App started
  ```

  The application will automatically bind to your ClearDB database.

  If you already have pushed your application, you can bind the service:

  ```
  cf bind-service TodoList-MySQLApp Todo-MySQL
  cf restage TodoList-MySQL
  ```

3. Get your credentials for the ClearDB database:

  ```
  cf env TodoList-MySQL
  ```

  Note the username, password, and hostname.

4. Create your database table from the command line with the following commands:

  ```
  mysql -u <username> -p -h <hostname>
  ```
  
  You’ll be prompted for your password

  ```
  show databases;
  ```
  
  Look for the database name that was assigned for you. For example, it will look similiar to: "ad_ec426ec34c4e649".
  
  ```
  use <database name>;
  CREATE TABLE todos (tid INT NOT NULL AUTO_INCREMENT PRIMARY KEY, title TEXT, owner_id VARCHAR(256), completed INT, orderno INT);
  ```

## Compile and run tests:

1. Ensure MySQL is running and the scheme is populated from the quick start [instructions above](#quick-start).
2. Run the tests:

  For macOS:

  `swift test -Xswiftc -I/usr/local/include/mysql -Xlinker -L/usr/local/lib -Xswiftc -DNOJSON`
  
  For Linux:
  
    `swift test -Xswiftc -DNOJSON`
