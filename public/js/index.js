window.onload = () => {
/*
    Общие настройки
*/
    let _table_ = document.createElement('table'),
        _thead_ = document.createElement('thead'),
        _tbody_ = document.createElement('tbody'),
        _tr_    = document.createElement('tr'),
        _th_    = document.createElement('th'),
        _td_    = document.createElement('td'),
        _span_  = document.createElement('span'),

        _showId_        = true,  // колонка с id
        _showHead_      = true,  // шапка таблицы с названием колонок
        _showCommands_  = true,  // колонка с command ( командами )
        _showSort_      = true,  // сортировка при клике по названию колонки
        _separator_     = ' ';   // сепаратор для списка команд

/*
    формирование команды
*/

    function buildCommand(el, val, tData, data) {
        el.textContent = data[val];
        el.setAttribute('id', tData['id']);
        el.className += " command " + data[val];
    }
/* --------------------- */

/*
    Строим html таблицу на основе json данных
*/

    function buildTable(ElementId, TableData, Commands) {
        let table = _table_.cloneNode(false);
        let tbody = _tbody_.cloneNode(false);
        tbody = table.appendChild(tbody);

        addColumnHeaders(TableData, table);
        columns = Object.keys(TableData[0]);
        for (let i = 0, maxi = TableData.length; i < maxi; ++i) {
            let tr = _tr_.cloneNode(false);
            for ( let key in columns ) {
                let td = _td_.cloneNode(false);

                cellValue = TableData[i][columns[key]];
                // формируем ячейку с командами
                let commandSet = [];
                if ( _showCommands_ && columns[key] === 'command' ) {
                    if (cellValue.constructor === Array) {
                        for ( let val in cellValue ) {
                            let span = _span_.cloneNode(false);
                            buildCommand(span, val, TableData[i], cellValue);
                            td.appendChild(span);
                        }
                    }
                }

                // skip id or command column if need
                if ( ( !_showCommands_ && columns[key] === 'command' ) || ( !_showId_ && columns[key] === 'id') ) {
                    continue;
                }

                // если это не ячейка команд - выводим значение
                if (cellValue.constructor !== Array) {
                    td.appendChild(document.createTextNode(cellValue || ''));
                }
                tr.appendChild(td);
            }
            tbody.appendChild(tr);
        }
        table.className += " table_sort";

        document.getElementById( ElementId ).appendChild( table );

        // добавляем сортировку к таблице
        if ( _showSort_ )
            document.querySelectorAll('.table_sort thead').forEach(tableTH => tableTH.addEventListener('click', () => getSort(event)));

        // Привязываем события к командам
        if ( _showCommands_ ) {
            document.querySelectorAll('.add').forEach(add   => add.addEventListener('click',  () => Add(event)));
            document.querySelectorAll('.edit').forEach(edit => edit.addEventListener('click', () => Edit(event)));
            document.querySelectorAll('.del').forEach(del   => del.addEventListener('click',  () => Del(event)));
            document.querySelectorAll('.hide').forEach(hide => hide.addEventListener('click', () => Hide(event)));
            document.querySelectorAll('.show').forEach(show => show.addEventListener('click', () => Show(event)));
            document.querySelectorAll('.info').forEach(info => info.addEventListener('click', () => Info(event)));
        }

        return;
    }
/* --------------------- */

/*
    Сообщение об ошибке
*/
    function showError(message) {
        errorMessage = document.getElementById("ModalError");
        toggleModalError();
        errorMessage.innerHTML = message;
        setTimeout( function () {
            toggleModalError();
            errorMessage.innerHTML = '';
        }, 2000);
    }

/*
    Функции для работы с данными таблицы
*/
    const Login = ({ target }) => {
// console.log(target);
// var data = new FormData();
var dat = JSON.stringify( {"login":"wqew", "pass":"wqew"} );
// console.log( dat );

        fetch('/auth/login', {
            method: 'post',
            headers: {
                'Accept': 'application/json, text/plain, */*',
                'Content-Type': 'application/json'
            },
            // contentType: 'application/json',
            // headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: dat
        }).then(async response => {
            try {
                const data = await response.json();
console.log('response data?', data)
            } catch(error) {
                showError('Error happened here!' + error)
            }
        });
    };

    const Close = ({ target }) => {
        // document.getElementById("openModal").style.opacity = 0;
        // document.getElementById("Modal").innerHTML = '';
        // document.getElementById("errorMessage").innerHTML = '';
    };

    const Add = ({ target }) => {
        ReadFile('http://house/tmpl/user.html', 'name');
        toggleModal();
    };

    const Edit = ({ target }) => {
let nn = 'name';
console.log(target.id);
console.log(target.id);
        const dat = JSON.stringify( { 'id': target.id} );
        fetch('/user/edit', {
            method: 'post',
            headers: {
                'Accept': 'application/json, text/plain, */*',
                'Content-Type': 'application/json'
            },
            // contentType: 'application/json',
            // headers: {'Content-Type':'application/x-www-form-urlencoded'},
            body: dat
        }).then(async response => {
            try {
                const data = await response.json();
console.log('response data?', data)
            } catch(error) {
                showError('Error happened here!' + error)
            }
        });

    };

    const Save = ({ target }) => {
let nn = 'name';
console.log(target.id);
console.log(target.id);
//         fetch('/user/save', {
//             method: 'post',
//             headers: {
//                 'Accept': 'application/json, text/plain, */*',
//                 'Content-Type': 'application/json'
//             },
//             // contentType: 'application/json',
//             // headers: {'Content-Type':'application/x-www-form-urlencoded'},
//             body: dat
//         }).then(async response => {
//             try {
//                 const data = await response.json();
// console.log('response data?', data)
//             } catch(error) {
//                 showError('Error happened here!' + error)
//             }
//         });

    };

    const Del = ({ target }) => {
let nn = 'name';
console.log(target.id);

    };

    const Hide = ({ target }) => {
let nn = 'name';
console.log(target.id);

    };

    const Show = ({ target }) => {
let nn = 'name';
console.log(target.id);

    };

    const Info = ({ target }) => {
let nn = 'name';
console.log(target.id);

    };
/* --------------------- */

/*
    Добавляем строку заголовка в таблицу и возвращаем набор столбцов.
*/
    function addColumnHeaders(TableData, table) {
        let thead = _thead_.cloneNode(false);
        thead = table.appendChild(thead);

        let columnSet = [];
        if ( _showHead_ ) {
            let tr = _tr_.cloneNode(false);
            for (let i = 0, l = TableData.length; i < l; i++) {
                for ( let key in TableData[i] ) {
                    // skip id or command column if need
                    if ( ( !_showCommands_ && key === 'command' ) || ( !_showId_ && key === 'id' ) ) {
                        continue;
                    }
                    if ( TableData[i].hasOwnProperty(key) && columnSet.indexOf(key) === -1 ) {
                        columnSet.push(key);
                        let th = _th_.cloneNode(false);

                        th.appendChild(document.createTextNode(key));
                        tr.appendChild(th);
                    }
                }
            }
            thead.appendChild(tr);
        }
        return columnSet;
    }
/* --------------------- */

/*
    Скрипт сортирующий таблицу
*/
    const getSort = ({ target }) => {
        const order = (target.dataset.order = -(target.dataset.order || -1));
        const index = [...target.parentNode.cells].indexOf(target);
        const collator = new Intl.Collator(['en', 'ru'], { numeric: true });
        const comparator = (index, order) => (a, b) => order * collator.compare(
            a.children[index].innerHTML,
            b.children[index].innerHTML
        );
        
        for(const tBody of target.closest('table').tBodies)
            tBody.append(...[...tBody.rows].sort(comparator(index, order)));

        for(const cell of target.parentNode.cells)
            cell.classList.toggle('sorted', cell === target);
    };


    async function ReadFile(url, targetName) {
      try {
        const response = await fetch(url);
        const data = await response.text();
        document.getElementById('Modal').innerHTML = data;
console.log(data);
console.log(
    document.getElementsByName(targetName)[0].value
);
      } catch (err) {
        console.error(err);
      }
    }
/* --------------------- */

/*
    управление модыльным окном
*/
    const modal = document.querySelector(".modal");
    const modalError = document.querySelector(".modalError");
//????
    const closeButton = document.querySelector(".close-button");
    const trigger = document.querySelector(".trigger");

    function toggleModal() {
        modal.classList.toggle("show-modal");
    }

    function toggleModalError() {
        modalError.classList.toggle("show-modal");
    }

    function windowOnClick(event) {
        if (event.target === modal) {
            toggleModal();
        }
    }
/* --------------------- */

/*
    Изменение ширины центрального и правого блока
*/
    function resizeRight() {
        let content = document.getElementById('content');
        let rightBlock = document.getElementById('right-block');
        if ( document.getElementById('content').className === 'w60') {
            content.className = "w85";
            rightBlock.className = "w0";
        }
        else {
            content.className = "w60";
            rightBlock.className = "w25";
        }
    }

    trigger.addEventListener("click", resizeRight);
/* --------------------- */

/*
    Показ/закрытие модального окна
*/
    // trigger.addEventListener("click", toggleModal);
    closeButton.addEventListener("click", toggleModal);
/* --------------------- */

    // document.addEventListener("keydown", ({key}) => {  if (key === "Escape") { toggleModal() } })
    window.addEventListener("click", windowOnClick);
/*
    ===================================================================
    Основной блок
    ===================================================================
*/
    let TableData = [
        {"id" : 1, "name" : "abc", "age" : 50,   "hobby" : "ва ыв",       "command" : ["add", "edit"] },
        {"id" : 2, "name" : "xyz", "age" : "25", "hobby" : "swimming",    "command" : ["add", "edit"] },
        {"id" : 3, "name" : "xyz", "age" : "25", "hobby" : "programming", "command" : ["add", "edit", "hide"] }
    ];
/*
    Команды, доступные в таблице
*/

    let Commands = [
        "add",
        "edit",
        "del",
        "hide",
        "show",
        "info"
    ];
// ???????
    let inputType = [
        {"id"   :'hidden'},
        {"name" :'text'},
        {"age"  :'select'},
        {"hobby":'radio'}
    ];

    // закрытие модального окна
    document.querySelectorAll('.close').forEach(close => close.addEventListener('click', () => Close(event)));

    buildTable("Table", TableData, Commands);

    // ReadFile('http://house/tmpl/test.html', 'name');
// toggleModalError();

}