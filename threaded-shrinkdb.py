from threading import Thread
from queue import Queue
import sys
import time
import sqlite3
import parsejson

class MultiThreadOK(Thread):
    def __init__(self, db):
        super(MultiThreadOK, self).__init__()
        self.db=db
        self.reqs=Queue()
        self.start()
    def run(self):
        cnx = sqlite3.connect(self.db, isolation_level=None, check_same_thread = False)
        cnx.execute('pragma journal_mode=wal')
        cursor = cnx.cursor()
        while True:
            req, arg, res = self.reqs.get()
            if req=='--close--': break
            try:
                print("Executing", req)
                cursor.execute(req, arg)
                print("Completed: ", req)
                if res:
                    for rec in cursor:
                        res.put(rec)
                    res.put('--no more--')
            except Exception as e:
                print("Exception occured",e)
        cnx.execute("VACUUM")
        cnx.close()
    def execute(self, req, arg=None, res=None):
        self.reqs.put((req, arg or tuple(), res))
    def select(self, req, arg=None):
        res=Queue()
        self.execute(req, arg, res)
        while True:
            rec=res.get()
            if rec=='--no more--': break
            yield rec
    def close(self):
        self.execute('--close--')

if __name__=='__main__':
    start_time = time.time()
    user_db_file=sys.argv[1]
    user_input_file=sys.argv[2]
    print("user_db_file", user_db_file)
    print("user_input_file", user_input_file)
    db=user_db_file
    
    
    input_file=user_input_file
    dbInfo=parsejson.jsonparseer(input_file)
    nr_of_threads=5
    current_thread=0
    sql_threads = list()
    for x in range(nr_of_threads):
        sql_threads.append(MultiThreadOK(db))

    for key in dbInfo.keys():
        value = dbInfo[key]
        sql=sql_threads[current_thread]
        sql.execute(value)
        current_thread=current_thread+1
        if current_thread == nr_of_threads:
            current_thread=0

    for x in range(nr_of_threads):
        sql_threads[current_thread].close()
        sql_threads[current_thread].join()

    print("--- %s seconds ---" % (time.time() - start_time))