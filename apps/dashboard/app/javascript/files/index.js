import {} from './clip_board.js';
import {} from './data_table.js';
import {} from './file_ops.js';
import {} from './sweet_alert.js';
import {} from './uppy_ops.js';
import { setPageLoadState } from './page_load';
import { initSendToTarget } from './send_to_target';

addEventListener("DOMContentLoaded", (_event) => {
  setPageLoadState();
  initSendToTarget();
});
