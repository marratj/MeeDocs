function setKeyValue(key, value) {
    var db = openDatabaseSync("Meecasa", "1.0", "KeyValueStorage", 100000);
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS ' +
                     'KeyValueStorage(keyName TEXT, textValue TEXT)');
       var rs = tx.executeSql('SELECT keyName FROM KeyValueStorage WHERE keyName = "' + key + '"');
       var sql = "";
       var data = [ value, key ];
       if(rs.rows.length>0) {
           sql = "UPDATE KeyValueStorage SET textValue = '" + value + "' WHERE keyName = '" + key + "'";
       } else {
           sql = "INSERT INTO KeyValueStorage(textValue, keyName) VALUES ('" + value + "','" + key + "')";
       }
       tx.executeSql(sql);
    });
}

/** Get value from storage */
function getKeyValue(key) {
    var db = openDatabaseSync("Meecasa", "1.0", "KeyValueStorage", 100000);
    var result = "";
    db.transaction(function(tx) {
       tx.executeSql('CREATE TABLE IF NOT EXISTS KeyValueStorage(keyName TEXT, textValue TEXT)');

       var rs = tx.executeSql('SELECT textValue FROM KeyValueStorage WHERE keyName = "' + key + '"');
       for (var i = 0; i < rs.rows.length; i++) {
           result = rs.rows.item(i).textValue;
           // callback(key,result);
       }
       if(rs.rows.length==0) {
           // callback(key,"");
       }
    });
    return result;
}

