import parsejson
import sqlite3
import logging
import sys
import time

class ShrinkDB:
    dbInfo={}
    dbCursor = None
    connection =None
    def __init__(self,dbName) -> None:
          self.dbName =dbName
      
    def DbConnection(self):
        self.connection = sqlite3.connect(self.dbName, isolation_level=None)
        self.connection.execute('pragma journal_mode=wal')
        cursor = self.connection.cursor()
        return cursor   
    def executequery(self, user_input_file):
        input_file=user_input_file
        self.dbInfo=parsejson.jsonparseer(input_file)
        self.dbCursor=self.DbConnection()
        index=1
        for key in self.dbInfo.keys():
            #print(len(keys))
            print(index)
            value = self.dbInfo[key]
            index +=1
            #selectQuery= 'SELECT count(*) FROM ' + key
            try:
             self.dbCursor.execute(value)
             #print(self.dbCursor.fetchone())
             print("Executed sucessfully")
            except Exception as e:
             print("Exception occured",e)
        print("All query executes succefully")
        # self.connection.commit()
        self.dbCursor.execute("VACUUM")
        self.connection.close()    
        print("Connection close successfully")

start_time = time.time()

user_db_file=sys.argv[1]
user_input_file=sys.argv[2]
print("user_db_file", user_db_file)
print("user_input_file", user_input_file)
shrinkdb=ShrinkDB(user_db_file).executequery(user_input_file)

print("--- %s seconds ---" % (time.time() - start_time))