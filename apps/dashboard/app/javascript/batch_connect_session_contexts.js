'use strict';

import { attachPathSelectors } from './path_selector/path_selector';
import { prefillTemplatesHandler } from './prefill_templates/prefill_templates';
import { prefillSubmitHandler } from './prefill_templates/prefill_submit';
import { isBCDynamicJSEnabled } from './config';
import { makeChangeHandlers } from './dynamic_forms';


jQuery(function() {
  if(isBCDynamicJSEnabled()){
    makeChangeHandlers('batch_connect_session_context');
  }

  attachPathSelectors();
  prefillTemplatesHandler();
  prefillSubmitHandler();
});