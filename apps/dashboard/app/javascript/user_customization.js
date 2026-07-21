import { attachPathSelectors } from './path_selector/path_selector';

export default function attachUserCustomizations() {
  attachPathSelectors('#new_favorite_path');
  // To get the path selector modal to render properly, we move it outside the offcanvas
  $('#new_favorite_path .modal').appendTo('body');

  document.getElementById('new_favorite_button').addEventListener('click', addFavorite);
  document.querySelectorAll('[data-delete-favorite]').forEach(el => {
    el.addEventListener('click', (e) => removeFavorite(e));
  })
}

function addFavorite() {
  console.log('adding favorite');
  const titleInput = document.getElementById('favorite_path_title');
  const pathInput =  document.getElementById('favorite_path_path');
  const title = titleInput.value;
  const path = pathInput.value;
  if(path.trim().length == 0) {
    markInvalidPath();
    return;
  }

  const demoItem = document.querySelector('[data-favorite-demo]');
  const newItem = demoItem.cloneNode(true);
  newItem.removeAttribute('data-favorite-demo');
  newItem.style = '';
  newItem.setAttribute('data-favorite-title', title);
  newItem.setAttribute('data-favorite-path', path);
  const textDiv = newItem.querySelector('div');
  const deleteButton = newItem.querySelector('[data-delete-favorite]');
  const hasTitle = (title.trim().length == 0);
  textDiv.textContent = hasTitle ? `${path}` : `${title} (${path})`;
  deleteButton.title = `Remove custom favorite ${hasTitle ? title : path}`;
  deleteButton.addEventListener('click', (e) => removeFavorite(e));
  newItem.style = '';
  textDiv.append(deleteButton);
  newItem.append(textDiv);
  document.getElementById('current_favorites').insertBefore(newItem, document.getElementById('new_favorite_item'));

  const newValue = {"title": title, "path": path};
  const hiddenInput = document.getElementById('user_customization_custom_files_favorites')
  const currentValue = hiddenInput.value;
  const parsed = JSON.parse(currentValue);
  parsed.push(newValue);
  const stringVal = JSON.stringify(parsed);
  hiddenInput.value = stringVal;
  console.log(hiddenInput.value);
  titleInput.value = '';
  pathInput.value = '';
  document.querySelector('[data-bs-target="#new_favorite_path"]').click();
}

function removeFavorite(e) {
  console.log(e.target)
  const item = e.target.closest('[data-favorite-path]');
  const hiddenInput = document.getElementById('user_customization_custom_files_favorites');
  const values = JSON.parse(hiddenInput.value);

  const title = item.getAttribute('data-favorite-title');
  const path = item.getAttribute('data-favorite-path');
  const new_values = values.filter(value => (value.title !== title) || (value.path !== path))
  hiddenInput.value = JSON.stringify(new_values);
  item.remove();
}

function markInvalidPath() {
  const pathInput = document.getElementById('favorite_path_path');
}