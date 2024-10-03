import {analyticsPath} from "./config";

export function cssBadgeForState(state){
  switch (state) {
    case 'completed':
      return 'bg-success';
    case 'running':
      return 'bg-primary'
    case 'queued':
      return 'bg-info';
    case 'queued_held':
      return 'bg-warning';
    case 'suspended':
      return 'bg-warning';
    default:
      return 'bg-warning';
  }
}

export function capitalizeFirstLetter(string) {
  return string.charAt(0).toUpperCase() + string.slice(1);
}

export function startOfYear() {
  const now = new Date();
  const past = new Date();
  past.setDate(1);
  past.setMonth(0);
  past.setFullYear(now.getFullYear());
  return `${past.getFullYear()}-${past.getMonth()+1}-${past.getDate()}`;
}

export function thirtyDaysAgo() {
  const now = new Date();
  const past = new Date();
  past.setDate(now.getDate() - 30);
  return `${past.getFullYear()}-${past.getMonth()+1}-${past.getDate()}`;
}

export function today() {
  const now = new Date();
  return `${now.getFullYear()}-${now.getMonth()+1}-${now.getDate()}`;
}

function showSpinner() {
  $('body').addClass('modal-open');
  $('#full-page-spinner').removeClass('d-none');
}

export function bindFullPageSpinnerEvent() {
  $('.full-page-spinner').each((index, element) => {
    const $element = $(element);
    if($element.is('a')) {
      $element.on('click', showSpinner);
    } else {
      $element.closest('form').on('submit', showSpinner);
    }
  });
}

// open links in javascript and display an alert
export function openLinkInJs(event) {
  event.preventDefault();
  const href = event.target.href;

  // do nothing if there's no href.
  if(href == null){
    return;
  }

  if(window.open(href) == null) {
    // link was not opened in new window, so display error msg to user
    const html = document.getElementById('js-alert-danger-template').innerHTML;
    const msg = "This link is configured to open in a new window, but it doesn't seem to have opened. " +
          "Please disable your popup blocker for this page and try again.";

    // replace message in alert and add to main div of layout
    const mainDiv = document.querySelectorAll('div[role="main"]')[0];
    const alertDiv = document.createElement('div');
    alertDiv.innerHTML = html.split("ALERT_MSG").join(msg);
    mainDiv.prepend(alertDiv);
  }
}

// Helper method to set an element's innerHTML property
// and evaluate any <script> tags that may exist within it.
// Just setting innerHTML of an html element does not re-evaluate
// the <script> tags that it may hold.
export function setInnerHTML(element, html) {
  element.innerHTML = html;
  const scripts = Array.from(element.querySelectorAll("script"));

  scripts.forEach(currentElement => {
    const newElement = document.createElement("script");

    Array.from(currentElement.attributes).forEach( attr => {
      newElement.setAttribute(attr.name, attr.value);
    });

    const scriptText = document.createTextNode(currentElement.innerHTML);
    newElement.appendChild(scriptText);

    currentElement.parentNode.replaceChild(newElement, currentElement);
  });
}

// Helper method to report errors from the front end via AJAX
export function reportErrorForAnalytics(path, error) {
  // error - report back for analytics purposes
  const analyticsUrl = new URL(analyticsPath(path), document.location);
  analyticsUrl.searchParams.append('error', error);
  // Fire and Forget
  fetch(analyticsUrl);
}
