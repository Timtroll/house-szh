export function getSelect(Id) {
console.log('getSelect');
    let Value = {
        'option': document.getElementById( Id ).value,
        'val':    document.getElementById( Id + 'Index' ).value
    };

    return Value;
}

// преобразование всех элементов в select в хэш
export function getSelectHash(Id) {
console.log('getSelectHash');
  let List = {};
  document.getElementById( Id ).childNodes.forEach(
    (element) => { List[ element.getAttribute('data-id') ] = element.textContent }
  );

  return List;
}

export function createSelect(Id, Class, Placeholder, Values, defaultValue) {

  let Select = document.createElement("div");
  Select.className = Class;

  let Input = document.createElement("input");
      Input.type = 'text';
      Input.id = Id;
      Input.className = 'Select';
      Input.placeholder = Placeholder;
  Select.appendChild(Input);

  // событие показать список опций select 
  Input.addEventListener("click", (event) => ShowList(Id) );

  // событие поиск опции по шаблону из input 
  Input.addEventListener("input", () => filterFunction(Id) );

  let DivCh = document.createElement("div");
      DivCh.id = Id + 'Choise';
      DivCh.className = 'Select';
      DivCh.style.visible = "hidden";
  Select.appendChild(DivCh);
  // событие клик по выбранным элементам, чтобы выпал список
  DivCh.addEventListener("click", () => toggleInput(Id) );

  let InputH = document.createElement("input");
      InputH.type = 'hidden';
      InputH.id = Id + 'Index';
  Select.appendChild(InputH);

  let Div = document.createElement("div");
      Div.id = Id + 'Dropdown';
      Div.className = Class + '-content';
      Div.style.visibility = 'hidden';

  // создаем выпадающий список
  Values.forEach(function(val) {
    let Span = document.createElement("span");
    for ( let key in val ) {
      Span.setAttribute('data-id', key);
      Span.className = 'choose';
      Span.textContent = val[key];
      if (defaultValue && defaultValue == key) {
        Span.classList.add('dropdown-selected');
        Input.value = val[key];
        InputH.value = key;
      }

      // событие выбора из select
      Span.addEventListener('click', (event) => chooseFunction(Id, Span, key));
    }
    Div.appendChild(Span);
  });
  Select.appendChild(Div);

  return Select;
}

function createChoose(Id, Text, DataId) {
  let SpanCh = document.createElement("span");
      SpanCh.className = 'Select-choice';
      SpanCh.textContent = Text;
      SpanCh.setAttribute('data-id', DataId);
  let SpanDel = document.createElement("span");
      SpanDel.className = 'icon-del';
      SpanDel.textContent = 'X';
      SpanDel.setAttribute('data-id', DataId);
  SpanCh.appendChild(SpanDel);

  // событие удаление выбранного элемента
  SpanDel.addEventListener("click", (event) => deleteChoice(Id) );

  // добавляем отображение выбранных элементов
  document.getElementById( Id + 'Choise' ).appendChild(SpanCh);
}

function deleteChoice(Id) {
console.log('deleteChoice');
  let data = event.target.parentElement.getAttribute('data-id');

  // удаляем выбранный элемент
  event.target.parentElement.remove();
  // пересоздаем список выбранных элементов
  // ????????

  toggleInput(Id);
}

export function toggleInput(Id) {
  // скрываем input и показываем список выбранных элементов, если из более 1
console.log('toggleInput');
console.log( Id );
  let Select = document.getElementById( Id );                // input по умолчанию
  let Choise = document.getElementById( Id + 'Choise' );     // обертка списка span выбранных элементов

  let Dropdown = document.getElementById( Id + 'Dropdown' ); // обертка списка
  let Index = document.getElementById( Id + 'Index');        // список выбранных keys через запятую

  // делаем массив из выбранных элементов
  let listIndex = Index.value.split(',');

  // удаляем span в обертке выбранных элементов
  while (Choise.lastElementChild) {
    Choise.removeChild(Choise.lastElementChild);
  }


console.log( InputH.value );
console.log( listIndex.length );
return;
  // if ( listCh.length > 0 && Input.style.visible === 'hidden' ) {
//   if ( listCh.length > 0 ) {
//     Input.style.visible = "hidden";
//     SelectCh.style.visible = "visible";
// console.log('---1--listCh----');
//   }
//   else {
// console.log('---2-listCh-----');
//     InputH.style.visible = "visible";
//     SelectCh.style.visible = "hidden";
//   }

//   if ( typeof( Select.style.visible ) !== null && Select.style.visible === 'hidden' ) {
//     Select.style.visible = "visible";
//     Input.style.visible = "hidden";
// console.log('---2------');
//   }
//   else {
//     Select.style.visible = "hidden";
//     Input.style.visible = "visible";
//   }
}

function listChoosen( Id ) {
console.log('listChoosen');
  let InputH = document.getElementById( Id + 'Index');
  let listCh = InputH.value.split(',');

  let List = {};
  listCh.forEach(
    (element) => { List[ element ] = 1 }
  );

  return List;
}

function createChoosen( Id, List ) {
console.log('createChoosen');
}

function chooseFunction(Id, Item, index) {
console.log('chooseFunction');

  // singleselect 
  // if ( !event.ctrlKey ) {
    document.getElementById( Id + 'Dropdown' ).style.visible = 'hidden';
  //   document.getElementById( Id ).value = Item.textContent;
  //   document.getElementById( Id + 'Index' ).value = index;
  // }
  // else {
  //   toggleInput(Id);

  // }

  let Div = document.getElementById( Id + 'Dropdown' );
  let Span   = Div.childNodes;
 
  // запоминаем выбранный элемент
  // document.getElementById( Id + 'Index').value += ',' + event.target.getAttribute('data-id');

  // получим хэш выбранных элементов
  let List = listChoosen( Id );
console.log(List);
console.log(event.target.getAttribute('data-id'));

  // let List = getSelectHash('Select'+ 'Choise');
  // document.getElementById( Id + 'Dropdown' ).childNodes.forEach( function(Item) {
  //   // multiselect 
  //   if ( event.ctrlKey ) {
  //     // если выбираемый элемент не был добален ранее, то добавляем его
  //     if ( event.target.getAttribute('data-id') == Item.getAttribute('data-id') && !List[ Item.getAttribute('data-id') ]) {
  //       // помечаем выбранный элемент
  //       event.target.classList.add('dropdown-selected');

  //       // запоминаем выбранный элемент
  //       document.getElementById( Id + 'Index').value += ',' + event.target.getAttribute('data-id');

  //       createChoose(Id, event.target.textContent, event.target.getAttribute('data-id'));
  //     }
  //   }
  //   // singleselect
  //   else {
  //     if ( Item.className != 'choose') Item.classList.remove('dropdown-selected');
  //   }
  // });
}

export function ShowList(Id) {
console.log(event);
  // multiselect 
  if ( typeof(event) != "undefined" && event.ctrlKey ) {
console.log('ctrlKey ShowList');
  }
  // singleselect
  else {
    console.log('ShowList');
    let Select = document.getElementById( Id ).value;
    let SelectIndex = document.getElementById( Id + 'Index' ).value;

    let Div  = document.getElementById( Id + 'Dropdown' );

    Div.style.visible = 'visible';
    Div.childNodes.forEach(
      function(Item) {
// Item.style.visible = "";
        if ( Item.className != 'choose') {
            Item.classList.remove('dropdown-selected');
        }
        if (Item.getAttribute('data-id') == SelectIndex) {
            Item.classList.add('dropdown-selected');
        }
      }
    );
  }
}

// поиск по шаблону
function filterFunction(Id) {
console.log('filterFunction');
  let filter = document.getElementById(Id).value.toUpperCase();
  let Div  = document.getElementById( Id + 'Dropdown' );

  // показываем весь список
  Div.style.visible = 'visible';

  // скрываем не найденные элементы
  let Span   = Div.childNodes;
  for (let i = 0; i < Span.length; i++) {
    txtValue = Span[i].textContent || Span[i].innerText;
    Span[i].style.visible = ( txtValue.toLowerCase().indexOf( filter.toLowerCase() ) !== -1 ) ? 'visible' : 'hidden';
  }
}

