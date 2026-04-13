'use strict';

const CARD_SELECTOR = '[data-collapsible-sidebar-card]';
const TOGGLE_SELECTOR = '.collapsible-app-card-toggle';

function setCardState(card, isOpen) {
  const toggle = card.querySelector(TOGGLE_SELECTOR);
  if (!toggle) return;

  toggle.setAttribute('aria-expanded', isOpen ? 'true' : 'false');
  card.classList.toggle('is-open', isOpen);
}

function initializeCard(card) {
  setCardState(card, false);
}

function toggleCardFromButton(button) {
  const card = button.closest(CARD_SELECTOR);
  if (!card) return;

  const isOpen = button.getAttribute('aria-expanded') === 'true';
  const nextOpen = !isOpen;

  setCardState(card, nextOpen);
}

function setupCollapsibleSidebar() {
  const cards = document.querySelectorAll(CARD_SELECTOR);
  if (!cards.length) return;

  cards.forEach(initializeCard);
}

document.addEventListener('click', function(event) {
  const button = event.target.closest(TOGGLE_SELECTOR);
  if (!button) return;

  toggleCardFromButton(button);
});

document.addEventListener('DOMContentLoaded', setupCollapsibleSidebar);
document.addEventListener('turbo:load', setupCollapsibleSidebar);
