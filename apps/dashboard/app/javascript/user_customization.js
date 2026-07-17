import { attachPathSelectors } from './path_selector/path_selector';

export default function attachUserCustomizations() {
  attachPathSelectors('#new_favorite_path');
  // To get the path selector modal to render properly, we move it outside the offcanvas
  $('#new_favorite_path .modal').appendTo('body');
}