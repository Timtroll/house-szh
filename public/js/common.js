/*
  функция чтения шаблона и вызова нужной функции
*/
async function ReadFile(url, className, targetFunction) {
  try {
    const response = await fetch(url);
    const Data = await response.text();
    if ( targetFunction ) {
      targetFunction(targetName, Data);
    }
  } catch (err) {
    console.error(err);
  }
}
