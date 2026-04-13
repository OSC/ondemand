'use strict';

/**
 * Collapsible Batch Connect sidebar:
 * Cards start collapsed and clicking the header toggles the visibility of the 
 * app list
 */

const CARD_SELECTOR = '[data-collapsible-sidebar-card]';
const TOGGLE_SELECTOR = '.collapsible-app-card-toggle';

/**
 * Updates a card's open/closed state for assistive tech
 * @param {HTMLElement} card - The root element
 * @param {boolean} isOpen - Whether the card's app list should be visible
 */
function setCardState(card, isOpen) {
  const toggle = card.querySelector(TOGGLE_SELECTOR);
  if (!toggle) return;

  toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  card.classList.toggle('is-open', isOpen);
}

/**
 * Resets a card to the default collapsed state
 * @param {HTMLElement} card - The root element
 */
function initializeCard(card) {
  setCardState(card, false);
}

/**
 * Toggles open/closed state
 * @param {HTMLButtonElement} button - The card header toggle control
 */
function toggleCardFromButton(button) {
  const card = button.closest(CARD_SELECTOR);
  if (!card) return;

  const isOpen = button.getAttribute('aria-expanded') === 'true';
  const nextOpen = !isOpen;

  setCardState(card, nextOpen);
}

/**
 * Finds all sidebar cards on the current page and initializes them collapsed.
 */
function setupCollapsibleSidebar() {
  const cards = document.querySelectorAll(CARD_SELECTOR);
  if (!cards.length) return;

  cards.forEach(initializeCard);
}

document.addEventListener('click', function onCollapsibleSidebarClick(event) {
  const button = event.target.closest(TOGGLE_SELECTOR);
  if (!button) return;

  toggleCardFromButton(button);
});

document.addEventListener('DOMContentLoaded', setupCollapsibleSidebar);
document.addEventListener('turbo:load', setupCollapsibleSidebar);
