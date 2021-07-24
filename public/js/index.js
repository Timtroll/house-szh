window.onload = () => {
    let _table_ = document.createElement('table'),
        _tr_ = document.createElement('tr'),
        _th_ = document.createElement('th'),
        _td_ = document.createElement('td');
        _showId_ = true;
        _showCom_ = true;

    // Builds the HTML Table out of myList json data from Ivy restful service.
    function buildHtmlTable(TableData) {
        let table = _table_.cloneNode(false),
        columns = addAllColumnHeaders(TableData, table);
        for (let i = 0, maxi = TableData.length; i < maxi; ++i) {
            let tr = _tr_.cloneNode(false);
            for (let j = 0, maxj = columns.length; j < maxj ; ++j) {
                    // skip id if need
                if ( !_showId_ && columns[j] === 'id') {
                    continue;
                }
                let td = _td_.cloneNode(false);
                cellValue = TableData[i][columns[j]];
                td.appendChild(document.createTextNode(TableData[i][columns[j]] || ''));
                tr.appendChild(td);
            }
            table.appendChild(tr);
        }
        return table;
    }
     
    // Adds a header row to the table and returns the set of columns.
    // Need to do union of keys from all records as some records may not contain
    // all records
    function addAllColumnHeaders(TableData, table)
    {
        let columnSet = [],
        tr = _tr_.cloneNode(false);
        for (let i = 0, l = TableData.length; i < l; i++) {
            for (let key in TableData[i]) {
                if (TableData[i].hasOwnProperty(key) && columnSet.indexOf(key) === -1) {
                    // skip id if need
                    if ( !_showId_ && key === 'id') {
                        continue;
                    }
                    columnSet.push(key);
                    let th = _th_.cloneNode(false);
                    th.appendChild(document.createTextNode(key));
                    tr.appendChild(th);
                }
            }
        }
         table.appendChild(tr);
         return columnSet;
    }


/*
    Основной блок
*/
    let TableData = [
        {"id" : 1, "name" : "abc", "age" : 50 },
        {"id" : 2, "age" : "25", "hobby" : "swimming", "command" : [] },
        {"id" : 3, "name" : "xyz", "hobby" : "programming", "command" : [] }
    ];
    let Command = [ "add", "edit", "del", "hide", "show", "info" ];

    // document.body.appendChild(buildHtmlTable([
    document.getElementById("Table").appendChild(
        buildHtmlTable(TableData, Command)
    );
}