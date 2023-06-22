import json


def genDict(dict,key,value):
    dict[key]=value
    return dict
    
userName = tableName = sqlQuery = None
#processData = []
processDataDict = {}
def jsonparseer(input_file):
    f= open(input_file)
    data=json.load(f)
    userName= data['user']
    print(userName)
    for i in data['tables']:
            tableName=i['tableName']
            sqlQuery=i['sqlQuery']
            #processData=[tableName,sqlQuery]
            processDict=genDict(processDataDict,tableName,sqlQuery)
            #print(processDataDict)
    #print(len(processDict))
            
    return processDataDict
