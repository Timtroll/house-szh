// const Select = ReadFile('http://house/tmpl/select.html', 'test');
// console.log(Select);

import { getSelect, createSelect, getSelectHash, 
  toggleInput, ShowList } from './select.js';

function Init() {
  // закрываем открытые дропдауны select-ов при клике на "пустом месте"
  document.querySelector('html').addEventListener('click', function(e) {
    if(e.target.id !== 'Select' && e.target.id !== 'SelectChoise' && e.target.className !== 'choose' && !e.ctrlKey){
console.log( 'html' );
// console.log( e.target.id );
      // document.getElementById( "SelectDropdown" ).style.display = "none";
    }
  });

  // рисуем select
  let Parent = document.getElementById('test');
  let list = [
    {'1': 'О Нас'},
    {'2': 'Базовый'},
    {'3': 'Базовый1'},
    {'4': 'Базовый2'},
    {'5': 'Базовый3'},
    {'6': 'Базовый4'},
    {'7': 'Базовый5'},
    {'8': 'Базовый6'},
    {'9': 'Базовый7'},
    {'10': 'Базовый8'},
    {'11': 'Базовый9'},
    {'12': 'Базовый10'}
  ];
  let Select = createSelect( 'Select', 'dropdown', 'Поиск..', list, '3' );
  document.getElementById('test').appendChild(Select);
}

Init();
toggleInput( 'Select' );

// getItems('Select'+ 'Dropdown');

// let Select = getSelect('Select');
// console.log(Select);
